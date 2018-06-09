module Capra
  class WorkerBuilder
    def self.build(run_method:, stop_method:)
      new(
        run_method: run_method,
        stop_method: stop_method,
      ).build
    end

    def initialize(run_method:, stop_method:)
      @run_method = run_method
      @stop_method = stop_method
    end

    def build
      run_method = @run_method
      stop_method = @stop_method

      Module.new do
        define_method(:_run, run_method)
        define_method(:_stop, stop_method)

        def run
          Capra.logger.info("start worker")
          _run('127.0.0.1', 8000 + worker_id, worker_id, logger)
        end

        def stop
          Capra.logger.info("start stop")
          _stop(logger)
        end
      end
    end
  end
end
