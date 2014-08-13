WordNet Populator

This Ruby project creates a Document Collection Changefile that contains
English word data from WordNet (http://wordnet.princeton.edu/), including definitions,
parts of speech, and synonyms.

To run:

  bundle install
  ruby populate.rb

should create the file wordnet-doc.json.bz2, which can be uploaded to
Solve for All as a Document Collection Changefile.

For more documentation on Document Collections see
https://solveforall.com/docs/developer/document_collection

Any enhancements are welcome! Please submit your pull request and if accepted, it will
improve the content on Solve for All.

