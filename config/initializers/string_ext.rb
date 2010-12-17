class String

  # Transform (http) URI's so that Lucene tokenization doesn't break them up.
  # Replacing all non-word characters with a period character.
  #
  # This is a workaround until implementation of Lucene NewStandardTokenizer,
  # not available as of 2010-11-26.
  # See http://www.gossamer-threads.com/lists/lucene/java-user/102828

  def block_uri_tokenization
#    CGI.escape(self).gsub(/%2B/, '+').gsub(/%22/, '"').gsub(/%5E/, '^').gsub(/\+/, ' ').gsub(/%/, '.')
    gsub(/https?\:\S+/){|m| CGI.escape(m).gsub(/%22/, '"').gsub(/%5E/, '^').gsub(/\+/, ' ').gsub(/%/, '.')}
  end

end
