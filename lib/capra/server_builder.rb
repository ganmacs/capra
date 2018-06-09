require 'capra/load_balancer'
require 'capra/backends'

module Capra
  class ServerBuilder
    def self.build(addr:, port:, workers:, backend_type:)
      new(
        addr: addr,
        port: port,
        workers: workers,
        backend_type: backend_type,
      ).build
    end

    def initialize(addr:, port:, workers:, backend_type:)
      @addr = addr
      @port = port
      @workers = workers
      @backend_type = backend_type
    end

    def build
      @backend = build_backend

      lb = LoadBlancer.new(@addr, @port, 128, 5, @backend) # XXX
      lb_value = Proc.new { lb }

      Module.new do
        define_method(:_load_blancer, lb_value)

        def before_run
          @lb = _load_blancer
          @t = Thread.new do
            @lb.run
          end
        end

        def after_run
          @lb.stop
          @t.join
        end
      end
    end

    def build_backend
      be = (0...@workers).map do |id|
        { addr: '127.0.0.1', port: 8000 + id }
      end

      backend_class.new(be)
    end

    def backend_class
      t = @backend_type.to_sym
      if t == :round_robin
        Capra::Backends::RoundRobin
      else
        raise 'not support yet'
      end
    end
  end
end
