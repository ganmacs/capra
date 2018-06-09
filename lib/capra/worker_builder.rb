module Capra
  class WorkerBuilder
    class Context
      attr_reader :run_method, :stop_method

      def run(&block)
        @run_method = block
      end

      def stop(&block)
        @stop_method = block
      end
    end

    def self.build(&block)
      new(block).build
    end

    def initialize(block)
      @block = block
    end

    def build
      c = Context.new
      @block.call(c)

      Module.new do
        define_method(:_run, c.run_method)
        define_method(:_stop, c.stop_method)

        def run
          Capra.logger.info("start worker")
          _run('127.0.0.1', 8000 + worker_id, worker_id)
        end

        def stop
          Capra.logger.info("start stop")
          _stop
        end
      end
    end
  end
end
