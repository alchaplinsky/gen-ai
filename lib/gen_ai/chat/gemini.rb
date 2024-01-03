# frozen_string_literal: true

module GenAI
  class Chat
    class Gemini < Base
      include GenAI::Api::Format::Gemini

      USER_ROLE = 'user'
      ASSISTANT_ROLE = 'model'

      private

      def build_history(messages, context, examples)
        history = format_messages(messages.drop(1))
        history.prepend({ role: USER_ROLE, parts: [{text: build_first_message(context, examples, messages.first)}] })
        history
      end

      def build_first_message(context, examples, message)
        chunks = []
        chunks << context if context
        chunks << examples.map { |example| "#{example[:role]}: #{example[:content]}" }.join("\n") if examples.any?
        chunks << message[:content] if message
        chunks.join("\n")
      end

      def append_to_message(message)
        @history.last[:parts][0][:text] << "\n" << message
      end
    end
  end
end
