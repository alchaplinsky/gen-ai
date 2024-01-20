# frozen_string_literal: true

require 'zeitwerk'
require 'active_support/core_ext/hash/keys'

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect(
  'gen_ai' => 'GenAI',
  'open_ai' => 'OpenAI',
  'stability_ai' => 'StabilityAI'
)
loader.ignore("#{__dir__}/gen")
loader.collapse("#{__dir__}/gen_ai/core")
loader.setup

module GenAI
  class Error < StandardError; end
  class ApiError < Error; end
  class UnsupportedProvider < Error; end
end
