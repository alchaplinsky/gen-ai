# frozen_string_literal: true

module GenAI
  class Language
    class GooglePalm < Base
      COMPLETION_MODEL = 'chat-bison-001'

      def initialize(token:, options: {})
        depends_on 'google_palm_api'

        @client = ::GooglePalmApi::Client.new(api_key: token)
      end

      def embed(input, model: nil)
        responses = array_wrap(input).map do |text|
          handle_errors { client.embed(text: text, model: model) }
        end

        responses.map { |response| response.dig('embedding', 'value') }
      end

      def complete(prompt, options: {})
        response = handle_errors do
          client.generate_chat_message(**chat_parameters(prompt, options))
        end

        response['candidates']
      end

      def chat(message, context: nil, history: [], examples: [], options: {})
        response = handle_errors do
          client.generate_chat_message(**build_options(message, context, history, examples, options))
        end

        response['candidates']
      end

      private

      def build_options(message, context, history, examples, options)
        {
          model: options.delete(:model) || COMPLETION_MODEL,
          messages: history.append({ author: '0', content: message }),
          examples: compose_examples(examples),
          context: context
        }.merge(options)
      end

      def chat_parameters(prompt, _options)
        {
          model: COMPLETION_MODEL,
          messages: [{ author: DEFAULT_ROLE, content: prompt }]
        }
      end

      def compose_examples(examples)
        examples.each_slice(2).map do |example|
          {
            input: { content: example.first['content'] || example.first[:content] },
            output: { content: example.last['content'] || example.last[:content] }
          }
        end
      end

      def array_wrap(object)
        return [] if object.nil?

        object.respond_to?(:to_ary) ? object.to_ary || [object] : [object]
      end
    end
  end
end
