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
        if examples.any?
          chunks << examples.map do |example|
            "#{example[:role]}: #{example[:content]}"
          end.join("\n")
        end
        chunks << message[:content] if message
        chunks.join("\n")
      end

      def role(message)
        message[:role] == 'user' ? USER_ROLE : ASSISTANT_ROLE
      end

      def transform_message(message)
        {role: role(message), parts: [text: message[:content]]}
      end
    end
  end
end
