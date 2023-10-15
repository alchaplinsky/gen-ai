# frozen_string_literal: true

module GenAI
  class Language
    class GooglePalm < Base
      def initialize(token:, options: {})
        depends_on 'google_palm_api'

        @client = ::GooglePalmApi::Client.new(api_key: token)
      end
    end
  end
end
