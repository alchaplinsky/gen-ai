# frozen_string_literal: true

require 'forwardable'

module GenAI
  class Language
    extend Forwardable

    def_delegators :@llm, :embed, :complete, :chat

    def initialize(provider, token, options: {})
      build_llm(provider, token, options)
    end

    private

    def build_llm(provider, token, options)
      klass = GenAI::Language.constants.find do |const|
        const.to_s.downcase == provider.to_s.downcase.gsub('_', '')
      end

      raise UnsupportedProvider, "Unsupported LLM provider '#{provider}'" unless klass

      @llm = GenAI::Language.const_get(klass).new(token: token, options: options)
    end
  end
end
