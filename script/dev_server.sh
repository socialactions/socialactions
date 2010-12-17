#!/bin/sh
#rake ultrasphinx:daemon:start
rake sunspot:solr:start
script/server -p 3000
#rake ultrasphinx:daemon:stop
rake sunspot:solr:stop
