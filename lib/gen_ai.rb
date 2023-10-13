# frozen_string_literal: true

require_relative "version"

module GenAI
  class Error < StandardError; end
  class UnsupportedConfiguration < Error; end
  # Your code goes here...
end

require_relative "language/google_palm"
require_relative "language/open_ai"
require_relative "language"
