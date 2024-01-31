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

        def extract_completions(response)
          if response.is_a?(Array)
            response.map { |completion| extract_candidates(completion) }
          else
            extract_candidates(response)
          end
        end

        def chunk_params_from_streaming(chunk)
          {
            model: 'gemini-pro',
            index: chunk.dig('candidates', 0, 'index'),
            value: chunk.dig('candidates', 0, 'content', 'parts', 0, 'text'),
            raw: chunk
          }
        end

        private

        def extract_candidates(candidates)
          candidates['candidates'].map { |candidate| candidate.dig('content', 'parts', 0, 'text') }
        end

        def role_for(message)
          message[:role] == 'user' ? USER_ROLE : ASSISTANT_ROLE
        end
      end
    end
  end
end
