module GenAI
  class Language
    def initialize(provider, token, options: {})
      @llm = build_llm(provider, token, options)
    end

    def answer(question, context: {})
    end

    def completion(prompt, options: {})
    end

    def conversation(prompt, options: {})
    end

    def embedding(text)
    end

    def sentiment(text)
    end

    def keywords(text)
    end

    def summarization(text)
    end

    def translation(text, target:)
    end

    def correction(text)
    end

    private

    def build_llm(provider, token, options)
      case provider
      when :openai
        GenAI::Language::OpenAI.new(token: token)
      when :google_palm
        GenAI::Language::GooglePalm.new(token: token)
      else
        raise UnsupportedConfiguration.new "Unknown LLM provider"
      end
    end
  end
end
