# frozen_string_literal: true

module GenAI
  class Chat
    class Gemini < Base
      USER_ROLE = 'user'
      ASSISTANT_ROLE = 'model'

      private

      def build_history(messages, context, examples)
        history = [{ role: USER_ROLE, parts: [{text: build_first_message(context, examples, messages.first)}] }]

        messages.drop(1).each { |message| history << transform_message(message) }

        history
      end

      def build_first_message(context, examples, message)
        chunks = []
        chunks << context if context
        chunks << examples.map { |example| "#{example[:role]}: #{example[:content]}" }.join("\n") if examples.any?
        chunks << message[:content] if message
        chunks.join("\n")
      end

      def role(message)
        message[:role] == 'user' ? USER_ROLE : ASSISTANT_ROLE
      end

      def transform_message(message)
        {role: role(message), parts: [text: message[:content]]}
      end

      def append_to_message(message)
        @history.last[:parts][0][:text] << "\n" << message
      end
    end
  end
end
