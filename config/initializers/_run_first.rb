# http://thewebfellas.com/blog/2010/7/15/rails-2-3-8-rack-1-1-and-the-curious-case-of-the-missing-quotes
Dir[File.join(Rails.root, "lib", "patches", "**", "*.rb")].sort.each { |patch| require(patch) }
