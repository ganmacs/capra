module Capra
  module Backends
    class RoundRobin
      def initialize(backends)
        @backends = backends
        @mutex = Mutex.new
        @size = backends.size
        @i = 0
      end

      def select
        bc = @backends[@i]

        @mutex.synchronize do
          @i += 1
          @i = 0 if @i >= @size
        end
        bc
      end
    end
  end
end
