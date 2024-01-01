# frozen_string_literal: true

module GenAI
  class Language
    class GooglePalm < Base
      DEFAULT_ROLE = '0'
      EMBEDDING_MODEL = 'textembedding-gecko-001'
      COMPLETION_MODEL = 'text-bison-001'
      CHAT_COMPLETION_MODEL = 'chat-bison-001'

      def initialize(token:, options: {})
        depends_on 'google_palm_api'

        @client = ::GooglePalmApi::Client.new(api_key: token)
      end

      def embed(input, model: nil)
        responses = array_wrap(input).map do |text|
          handle_errors { client.embed(text: text, model: model) }
        end

        build_result(
          model: model || EMBEDDING_MODEL,
          raw: { 'data' => responses, 'usage' => {} },
          parsed: extract_embeddings(responses)
        )
      end

      def complete(prompt, options = {})
        parameters = build_completion_options(prompt, options)

        response = handle_errors { client.generate_text(**parameters) }

        build_result(
          model: parameters[:model],
          raw: response.merge('usage' => {}),
          parsed: extract_completions(response)
        )
      end

      def chat(message, context: nil, history: [], examples: [], **options)
        parameters = build_chat_options(message, context, history, examples, options)

        response = handle_errors { client.generate_chat_message(**parameters) }

        build_result(
          model: parameters[:model],
          raw: response.merge('usage' => {}),
          parsed: extract_chat_messages(response)
        )
      end

      private

      def build_chat_options(message, context, history, examples, options)
        {
          model: options.delete(:model) || CHAT_COMPLETION_MODEL,
          messages: history.append(build_message(message, history)),
          examples: compose_examples(examples),
          context: context
        }.merge(options)
      end

      def build_completion_options(prompt, options)
        {
          prompt: prompt,
          model: options.delete(:model) || COMPLETION_MODEL
        }.merge(options)
      end

      def compose_examples(examples)
        examples.each_slice(2).map do |example|
          {
            input: { content: symbolize(example.first)[:content] },
            output: { content: symbolize(example.last)[:content] }
          }
        end
      end

      def symbolize(hash)
        hash.transform_keys(&:to_sym)
      end

      def array_wrap(object)
        return [] if object.nil?

        object.respond_to?(:to_ary) ? object.to_ary || [object] : [object]
      end

      def build_message(message, messages)
        if message.is_a?(String)
          { author: messages.dig(0, :author) || DEFAULT_ROLE, content: message }
        else
          message
        end
      end

      def extract_embeddings(responses)
        responses.map { |response| response.dig('embedding', 'value') }
      end

      def extract_completions(response)
        response['candidates'].map { |candidate| candidate['output'] }
      end

      def extract_chat_messages(response)
        response['candidates'].map { |candidate| candidate['content'] }
      end
    end
  end
end
