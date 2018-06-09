require 'fileutils'
require 'serverengine'
require 'capra/server_builder'
require 'capra/worker_builder'

module Capra
  class Application
    def self.run(opts)
      new(opts).run
    end

    def initialize(opts)
      @opts = opts
    end

    def run
      setup
      worker = build_worker
      server = build_server
      ServerEngine.create(server, worker, @opts).run
    end

    private

    def setup
      mkdir_if_not_exist(@opts[:pid_path])
      mkdir_if_not_exist(@opts[:log])

      Capra.build_logger(@opts[:log], @opts[:log_level])
    end

    def mkdir_if_not_exist(path)
      if path && path.is_a?(String)
        dir = File.dirname(path)
        unless File.directory?(dir)
          FileUtils.mkdir_p(dir)
        end
      end
    end

    def build_worker
      worker_run = @opts.delete(:worker_run) { |_| raise 'worker_run not found' }
      worker_stop = @opts.delete(:worker_stop) { |_| raise 'worker_stop not found' }

      Capra::WorkerBuilder.build(
        run_method: worker_run,
        stop_method: worker_stop,
      )
    end

    def build_server
      addr = @opts.delete(:addr) { |_| raise 'addr not found' }
      port = @opts.delete(:port) { |_| raise 'port not found' }
      workers = @opts.delete(:workers) { |_| raise 'workers not found' }
      backend_type = @opts.delete(:backend_type) { |_| raise 'backend_type not found' }

      Capra::ServerBuilder.build(
        addr: addr,
        port: port,
        workers: workers,
        backend_type: backend_type,
      )
    end
  end
end
