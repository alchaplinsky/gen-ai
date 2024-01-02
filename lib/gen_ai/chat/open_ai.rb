# frozen_string_literal: true

module GenAI
  class Chat
    class OpenAI < Base
      SYSTEM_ROLE = 'system'

      private

      def build_history(messages, context, examples)
        history = []
        history << { role: SYSTEM_ROLE, content: context } if context
        history.concat(examples)
        history.concat(messages)
        history
      end

      def role(message)
        message[:role]
      end

      def transform_message(message)
        message
      end

      def append_to_message(message)
        @history.last[:content] = "#{@history.last[:content]}\n#{message}"
      end
    end
  end
end
