# frozen_string_literal: true

require 'faraday'
require 'faraday/multipart'

module GenAI
  module Api
    class Client
      def initialize(url:, token:)
        @url = url
        @token = token
      end

      def post(path, body, options = {})
        multipart = options.delete(:multipart) || false
        payload = multipart ? body : JSON.generate(body)

        handle_response do
          connection(multipart: multipart).post(path, payload)
        end
      end

      def get(path, options)
        handle_response do
          connection.get(path, options)
        end
      end

      private

      attr_reader :url, :token

      def connection(multipart: false)
        Faraday.new(url: url, headers: {
          'Accept' => 'application/json',
          'Content-Type' => multipart ? 'multipart/form-data' : 'application/json',
          'Authorization' => "Bearer #{token}"
        }) do |conn|
          conn.request :multipart if multipart
          conn.request :url_encoded
        end
      end

      def handle_response
        response = yield

        raise GenAI::ApiError, "API error: #{JSON.parse(response.body)}" unless response.success?

        JSON.parse(response.body)
      end
    end
  end
end
