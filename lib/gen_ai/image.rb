# frozen_string_literal: true

module GenAI
  class Image
    extend Forwardable

    def_delegators :@client, :generate, :variations, :edit, :upscale

    def initialize(provider, token, options: {})
      build_client(provider, token, options)
    end

    private

    def build_client(provider, token, options)
      klass = GenAI::Image.constants.find do |const|
        const.to_s.downcase == provider.to_s.downcase.gsub('_', '')
      end

      raise UnsupportedProvider, "Unsupported Image provider '#{provider}'" unless klass

      @client = GenAI::Image.const_get(klass).new(token:, options:)
    end
  end
end
