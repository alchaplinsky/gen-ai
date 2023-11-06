# frozen_string_literal: true

require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect(
  'gen_ai' => 'GenAI',
  'open_ai' => 'OpenAI',
  'stability_ai' => 'StabilityAI'
)
loader.ignore("#{__dir__}/gen")
loader.setup

module GenAI
  class Error < StandardError; end
  class ApiError < Error; end
  class UnsupportedProvider < Error; end
end
