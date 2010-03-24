#!/bin/sh
rake ultrasphinx:daemon:start
script/server -p 3002
rake ultrasphinx:daemon:stop
