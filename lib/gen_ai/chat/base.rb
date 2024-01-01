# frozen_string_literal: true

module GenAI
  class Chat
    class Base < GenAI::Base
      def initialize(provider:, token:, options: {})
        @model = GenAI::Language.new(provider, token, options: options)
        @history = []
        @context = nil
        @examples = []
      end

      def start(history: [], context: nil, examples: [])
        @history = history
        @context = context
        @examples = examples
      end

      def message(message)
        result = @model.chat(message, history: @history, context: @context, examples: @examples)
        @history << { role: 'user', content: message }
        @history << { role: 'assistant', content: result.value }
        result
      end
    end
  end
end
