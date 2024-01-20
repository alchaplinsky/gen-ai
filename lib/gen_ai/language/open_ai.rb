# frozen_string_literal: true

module GenAI
  class Language
    class OpenAI < Base
      include GenAI::Api::Format::OpenAI

      EMBEDDING_MODEL = 'text-embedding-ada-002'
      COMPLETION_MODEL = 'gpt-3.5-turbo-1106'

      def initialize(token:, options: {})
        depends_on 'ruby-openai'

        @client = ::OpenAI::Client.new(access_token: token)
      end

      def embed(input, model: nil)
        parameters = { input: input, model: model || EMBEDDING_MODEL }

        response = handle_errors { client.embeddings(parameters: parameters) }

        build_result(model: parameters[:model], raw: response, parsed: extract_embeddings(response))
      end

      def complete(prompt, options = {})
        chat_request build_completion_options(prompt, options)
      end

      def chat(messages, options = {}, &block)
        parameters = build_chat_options(messages, options)

        block_given? ? chat_streaming_request(parameters, block) : chat_request(parameters)
      end

      private

      def build_chat_options(messages, options)
        build_options(messages.map(&:deep_symbolize_keys), options)
      end

      def build_completion_options(prompt, options)
        build_options([{ role: DEFAULT_ROLE, content: prompt }], options)
      end

      def build_options(messages, options)
        {
          messages: messages,
          model: options.delete(:model) || COMPLETION_MODEL
        }.merge(options)
      end

      def chat_request(parameters)
        response = handle_errors { client.chat(parameters: parameters) }

        build_result(model: parameters[:model], raw: response, parsed: extract_completions(response))
      end

      def chat_streaming_request(parameters, block)
        chunks = {}

        parameters[:stream] = chunk_process_block(chunks, block)

        client.chat(parameters: parameters)

        build_result(
          model: parameters[:model],
          parsed: chunks.values.map { |group| group.map(&:value).join },
          raw: build_raw_response(chunks)
        )
      end

      def chunk_process_block(chunks, block)
        proc do |data|
          chunk = build_chunk(chunk_params_from_streaming(data))

          unless chunk.value.nil? || chunk.value.empty?
            block.call chunk

            chunks[chunk.index] = [] unless chunks[chunk.index]
            chunks[chunk.index] << chunk
          end
        end
      end
    end
  end
end
