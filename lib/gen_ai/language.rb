# frozen_string_literal: true

module GenAI
  class Language
    def initialize(provider, token, options: {})
      build_llm(provider, token, options)
    end

    def embedding(text)
      llm.embedding(text)
    end

    def answer(question, context: {})
      llm.completion(prompt, options: options)
    end

    def conversation(prompt, options: {})
      llm.completion(prompt, options: options)
    end

    def sentiment(text)
    end

    def keywords(text)
    end

    def summarization(text)
    end

    def translation(text, target:)
    end

    def correction(text)
    end

    private

    attr_reader :llm

    def build_llm(provider, token, options)
      klass = GenAI::Language.constants.find do |const|
        const.to_s.downcase == provider.to_s.downcase.gsub(/_/, '')
      end

      raise UnsupportedProvider.new "Unsupported LLM provider '#{provider}'" unless klass

      @llm = GenAI::Language.const_get(klass).new(token: token, options: options)
    end
  end
end
