module GenAI
  class Language
    class OpenAI
      include GenAI::Dependency

      def initialize(token:, options: {})
        depends_on 'ruby-openai'

        @client = ::OpenAI::Client.new(access_token: token)
      end
    end
  end
end
