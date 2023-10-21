# frozen_string_literal: true

require 'faraday'

module GenAI
  module Api
    class Client
      def initialize(url:, token:)
        @connection = Faraday.new(url: url, headers: {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{token}"
        })
      end

      def post(path, body)
        payload = JSON.generate(body)

        handle_response do
          @connection.post(path, payload)
        end
      end

      def get(path, options)
        handle_response do
          @connection.get(path, options)
        end
      end

      private

      def handle_response
        response = yield

        raise GenAI::ApiError, "API error: #{JSON.parse(response.body)}" unless response.success?

        JSON.parse(response.body)
      end
    end
  end
end
