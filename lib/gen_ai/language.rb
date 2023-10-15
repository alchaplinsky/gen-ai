# frozen_string_literal: true

module GenAI
  class Language
    def initialize(provider, token, options: {})
      build_llm(provider, token, options)
    end

    def embed(text)
      llm.embed(text)
    end

    def answer(prompt, _context: {})
      llm.complete(prompt)
    end

    def chat(prompt, options: {})
      llm.complete(prompt, options: options)
    end

    def sentiment(text); end

    def keywords(text); end

    def summarization(text); end

    def translation(text, _target:); end

    def correction(text); end

    private

    attr_reader :llm

    def build_llm(provider, token, options)
      klass = GenAI::Language.constants.find do |const|
        const.to_s.downcase == provider.to_s.downcase.gsub('_', '')
      end

      raise UnsupportedProvider, "Unsupported LLM provider '#{provider}'" unless klass

      @llm = GenAI::Language.const_get(klass).new(token: token, options: options)
    end
  end
end
