# frozen_string_literal: true

module GenAI
  class Chat
    class OpenAI < Base
      def build_history(messages, context, examples)
        history = []
        history << { role: 'system', content: context } if context
        history.concat(examples)
        history.concat(messages)
        history
      end

      def role(message)
        message[:role]
      end
    end
  end
end
