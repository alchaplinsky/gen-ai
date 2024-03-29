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

    def value(format = :raw)
      case format
      when :raw
        values.first
      when :base64
        Base64.encode64(values.first)
      else
        raise "Unsupported format: #{format}"
      end
    end

    def prompt_tokens
      usage['prompt_tokens']
    end

    def completion_tokens
      return usage['completion_tokens'] if usage['completion_tokens']

      total_tokens.to_i - prompt_tokens.to_i if total_tokens && prompt_tokens
    end

    def total_tokens
      usage['total_tokens']
    end

    private

    def usage
      raw['usage'] || {
        'prompt_tokens' => nil,
        'completion_tokens' => nil,
        'total_tokens' => nil
      }
    end
  end
end
