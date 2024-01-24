# frozen_string_literal: true

module GenAI
  module Api
    module Format
      module Gemini
        USER_ROLE = 'user'
        ASSISTANT_ROLE = 'model'

        def format_messages(messages)
          messages.map { |message| transform_message(message.deep_symbolize_keys) }
        end

        def transform_message(message)
          if message.keys == %i[role content]
            { role: role_for(message), parts: [text: message[:content]] }
          else
            message
          end
        end

        def extract_completions(responses)
          responses
            .map do |response|
              response['candidates'].map { |candidate| candidate.dig('content', 'parts', 0, 'text') }
            end.flatten
        end

        private

        def role_for(message)
          message[:role] == 'user' ? USER_ROLE : ASSISTANT_ROLE
        end
      end
    end
  end
end
