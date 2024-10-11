# frozen_string_literal: true

module GenAI
  class Chat
    extend Forwardable

    def_delegators :@chat, :start, :message, :history

    def initialize(provider, token, options: {})
      build_chat(provider, token, options)
    end

    private

    def build_chat(provider, token, options)
      klass = GenAI::Chat.constants.find do |const|
        const.to_s.downcase == provider.to_s.downcase.gsub('_', '')
      end

      raise UnsupportedProvider, "Unsupported Chat provider '#{provider}'" unless klass

      @chat = GenAI::Chat.const_get(klass).new(provider:, token:, options:)
    end
  end
end
