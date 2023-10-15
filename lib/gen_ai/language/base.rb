# frozen_string_literal: true

module GenAI
  class Language
    class Base
      include GenAI::Dependency

      DEFAULT_ROLE = 'user'

      def embed(...)
        raise NotImplementedError, "#{self.class.name} does not support embedding"
      end

      def complete(...)
        raise NotImplementedError, "#{self.class.name} does not support completion"
      end

      def chat(...)
        raise NotImplementedError, "#{self.class.name} does not support conversations"
      end

      private

      attr_reader :client

      def handle_errors
        response = yield
        return if response.empty?

        if response['error']
          raise GenAI::ApiError, "#{api_provider_name} API error: #{response.dig('error', 'message')}"
        end

        response
      end

      def api_provider_name
        self.class.name.split('::').last
      end
    end
  end
end
