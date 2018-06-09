module Capra
  class DSL
    DEFAULT = {
      addr: '127.0.0.1',
      port: 3000,
      workers: 2,
      backend_type: :round_robin,
      server_name: 'capra server',
      worker_type: 'process',
      log_level: :info,
      daemonize: false,
      pid_path: 'tmp/capra.pid',
      log: 'log/capra_stdout.log',
    }

    def self.evaulate(opts, file_path)
      new(opts).tap { |dsl| dsl._load(file_path) }.options
    end

    attr_reader :options

    def initialize(opts = {})
      @options = DEFAULT.merge(opts)
    end

    %i[addr port workers backend_type server_name worker_type daemonize pid_path log_level].each do |name|
      define_method(name) do |v|
        @options[name] = v
      end
    end

    def stdout_path(v)
      @options[:log] = v
    end

    def worker_run(&block)
      @options[:worker_run] = block
    end

    def worker_stop(&block)
      @options[:worker_stop] = block
    end

    def _load(file_path)
      instance_eval(File.read(file_path), file_path)
    end
  end
end
