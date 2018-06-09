require 'serverengine'
require 'logger'

require 'capra/version'
require 'capra/server_builder'

module Capra
  class << self
    def run(addr, port, worker, opts = {})
      option = {
        daemonize: false,
        daemon_process_name: 'capra server',
        log: 'myserver.log',
        pid_path: 'myserver.pid',
        worker_type: 'process',
        workers: 2,
        backend_type: 'round_robin',
      }.merge(opts)

      build_logger

      server = Capra::ServerBuilder.build(
        addr,
        port,
        workers: option[:workers],
        backend_type: option[:backend_type]
      )

      ServerEngine.create(server, worker, option).run
    end

    def build_logger(dev = STDOUT, level = :debug)
      @logger = Logger.new(dev, level: level)
    end

    def logger
      @logger ||= build_logger
    end
  end
end
