# frozen_string_literal: true

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect("gen_ai" => "GenAI", "open_ai" => "OpenAI")
loader.setup

module GenAI
  class Error < StandardError; end
  class UnsupportedConfiguration < Error; end
end
