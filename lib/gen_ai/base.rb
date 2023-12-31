# frozen_string_literal: true

module GenAI
  class Base
    include GenAI::Dependency

    private

    attr_reader :client

    def handle_errors
      response = yield
      return if !response || response.empty?

      raise GenAI::ApiError, "#{api_provider_name} API error: #{response.dig('error', 'message')}" if response['error']

      response
    end

    def provider_name
      api_provider_name.gsub(/(.)([A-Z])/, '\1_\2').downcase
    end

    def api_provider_name
      self.class.name.split('::').last
    end

    def build_result(model:, raw:, parsed:)
      GenAI::Result.new(provider: provider_name.to_sym, model: model, raw: raw, values: parsed)
    end
  end
end
