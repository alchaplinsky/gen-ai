# frozen_string_literal: true

module GenAI
  class Language
    class Base < GenAI::Base
      DEFAULT_ROLE = 'user'

      def embed(...)
        raise NotImplementedError, "#{self.class.name} does not support embedding"
      end

      def complete(...)
        raise NotImplementedError, "#{self.class.name} does not support completion"
      end

      def chat(...)
        raise NotImplementedError, "#{self.class.name} does not support conversations"
      end
    end
  end
end
