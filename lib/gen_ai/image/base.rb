# frozen_string_literal: true

module GenAI
  class Image
    class Base < GenAI::Base
      def generate(...)
        raise NotImplementedError, "#{self.class.name} does not support generate"
      end

      def variations(...)
        raise NotImplementedError, "#{self.class.name} does not support variations"
      end
    end
  end
end
