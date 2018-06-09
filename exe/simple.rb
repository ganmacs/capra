require 'logger'

require 'capra'
require 'capra/worker_builder'
require_relative 'simple_server'

ADDR = '127.0.0.1'
PORT = 3000

$logger = Logger.new(STDOUT)

worker = Capra::WorkerBuilder.build do |c|
  c.run do |addr, port, id|
    @server = SimpleServer.new(addr, port, $logger, id)
    @server.run
  end

  c.stop do
    @server.stop
  end
end

Capra.run(ADDR, PORT, worker, workers: 2)
