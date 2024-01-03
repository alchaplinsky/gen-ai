# frozen_string_literal: true

module GenAI
  module Api
    module Format
      module OpenAI
        def extract_embeddings(response)
          response['data'].map { |datum| datum['embedding'] }
        end

        def extract_completions(response)
          response['choices'].map { |choice| choice.dig('message', 'content') }
        end
      end
    end
  end
end
