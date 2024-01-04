# frozen_string_literal: true

module GenAI
  module Api
    module Format
      module Anthropic
        def format_messages(messages)
          messages.map(&:deep_symbolize_keys)
        end

        def extract_completions(response)
          if response['type'] == 'completion'
            [response['completion'].strip]
          else
            response['content'].map { |item| item['text'] }
          end
        end
      end
    end
  end
end
