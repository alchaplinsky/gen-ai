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

      def edit(...)
        raise NotImplementedError, "#{self.class.name} does not support editing"
      end

      def upscale(...)
        raise NotImplementedError, "#{self.class.name} does not support upscaling"
      end
    end
  end
end
