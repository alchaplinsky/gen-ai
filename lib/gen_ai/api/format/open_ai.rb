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

        def chunk_params_from_streaming(chunk)
          {
            model: chunk['model'],
            index: chunk.dig('choices', 0, 'index'),
            value: chunk.dig('choices', 0, 'delta', 'content'),
            raw: chunk
          }
        end

        def build_raw_response(chunks)
          { 'choices' => build_raw_choices(chunks),
            'usage' => { 'completion_tokens' => chunks.values.map(&:size).sum } }
        end

        def build_raw_choices(chunks)
          chunks.map do |key, values|
            {
              'index' => key,
              'logprobs' => nil,
              'finish_reason' => 'stop',
              'message' => { 'role' => 'asssistant', 'content' => values.map(&:value).join }
            }
          end
        end
      end
    end
  end
end
