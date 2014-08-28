require 'json'
require 'wordnet'

class WordNetPopulator

  def initialize(source_filename, output_filename)
    @lex = WordNet::Lexicon.new("sqlite://#{source_filename}")
    @output_filename = output_filename
  end

  def populate
   first_document = true
   num_words_found = 0

    File.open(@output_filename, 'w:UTF-8') do |out|
      out.write <<-eos
{
  "metadata" : {
    "mapping" : {
      "_all" : {
        "enabled" : false
      },
      "properties" : {
        "name" : {
          "type" : "multi_field",
          "path" : "just_name",
          "fields" : {
            "name" : {
              "type" : "string",
              "index" : "analyzed"
            },
            "lowerCasedName" : {
              "type" : "string",
              "index" : "not_analyzed"
            }
          }
        },
        "senses" : {
          "properties" : {
            "partOfSpeech" : {
              "type" : "string",
              "index" : "no"
            },
            "definition" : {
              "type" : "string",
              "index" : "no"
            },
            "synonyms" : {
              "type" : "string",
              "index" : "not_analyzed",
              "search_analyzer" : "simple"
            }
          }
        }
      }
    }
  },
  "updates" : [
      eos

      words = WordNet::Word.dataset

      words.each do |word|
        if first_document
          first_document = false
        else
          out.write(",\n")
        end

        puts "**** #{word} ****"

        lemma = word.lemma

        synsets = @lex.lookup_synsets(word)

        doc = {
          name: word
        }

        senses = []

        synsets.each_with_index do |synset, index|
          sense = {
            partOfSpeech: synset.part_of_speech,
            definition: synset.definition,
            synonyms: synset.words.map( &:lemma ).reject { |w| w == lemma }
          }

          senses << sense
        end


        doc[:senses] = senses

        out.write(doc.to_json)

        num_words_found += 1
      end

      out.write("\n  ]\n}")
    end

    puts "Found #{num_words_found} words."
  end
end


source_filename = ARGV[0]
output_filename = ARGV[1] || 'wordnet-doc.json'

WordNetPopulator.new(source_filename, output_filename).populate()
system("bzip2 -kf #{output_filename}")