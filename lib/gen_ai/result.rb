# frozen_string_literal: true

module GenAI
  class Result
    attr_reader :raw, :provider, :model, :values

    def initialize(provider:, model:, raw:, values:)
      @raw = raw
      @provider = provider
      @model = model
      @values = values
    end

    def value
      values.first
    end

    def prompt_tokens
      usage['prompt_tokens']
    end

    def completion_tokens
      usage['completion_tokens'] || (total_tokens - prompt_tokens)
    end

    def total_tokens
      usage['total_tokens']
    end

    private

    def usage
      raw['usage']
    end
  end
end
