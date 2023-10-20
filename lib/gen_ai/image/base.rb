# frozen_string_literal: true

module GenAI
  class Image
    class Base
      include GenAI::Dependency

      private

      def handle_errors
        response = yield
        return if response.empty?

        if response['error']
          raise GenAI::ApiError, "#{api_provider_name} API error: #{response.dig('error', 'message')}"
        end

        response
      end
    end
  end
end
