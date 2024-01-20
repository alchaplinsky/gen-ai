# frozen_string_literal: true

module GenAI
  class Chunk
    attr_reader :raw, :provider, :model, :value, :index

    def initialize(provider:, model:, index:, raw:, value:)
      @raw = raw
      @index = index
      @provider = provider
      @model = model
      @value = value
    end
  end
end
