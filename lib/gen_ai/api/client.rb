# frozen_string_literal: true

require 'faraday'
require 'faraday/multipart'

module GenAI
  module Api
    class Client
      def initialize(url:, token:, headers: {})
        @url = url
        @token = token
        @headers = headers
      end

      def post(path, body, options = {})
        multipart = options.delete(:multipart) || false
        payload = multipart ? body : JSON.generate(body)

        handle_response do
          connection(multipart:).post(path, payload)
        end
      end

      def get(path, options)
        handle_response do
          connection.get(path, options)
        end
      end

      private

      attr_reader :url, :token, :headers

      def connection(multipart: false)
        Faraday.new(url:, headers: build_headers(token, headers, multipart)) do |conn|
          conn.request :multipart if multipart
          conn.request :url_encoded
        end
      end

      def build_headers(token, headers, multipart)
        hash = {
          'Accept' => 'application/json',
          'Content-Type' => multipart ? 'multipart/form-data' : 'application/json'
        }
        hash['Authorization'] = "Bearer #{token}" if token
        hash.merge(headers)
      end

      def handle_response
        response = yield

        raise GenAI::ApiError, "API error: #{JSON.parse(response.body)}" unless response.success?

        JSON.parse(response.body)
      end
    end
  end
end
