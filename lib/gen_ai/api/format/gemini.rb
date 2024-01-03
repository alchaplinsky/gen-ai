# frozen_string_literal: true

module GenAI
  module Api
    module Format
      module Gemini
        def format_messages(messages)
          messages.map { |message| transform_message(message) }
        end

        def transform_message(message)
          { role: role_for(message), parts: [text: message[:content]] }
        end

        def extract_completions(response)
          response['candidates'].map { |candidate| candidate.dig('content', 'parts', 0, 'text') }
        end

        private

        def role_for(message)
          message[:role] == 'user' ? self.class::USER_ROLE : self.class::ASSISTANT_ROLE
        end
      end
    end
  end
end
