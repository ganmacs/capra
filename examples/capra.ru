require_relative 'simple_server'

addr '127.0.0.1'

port 3000

workers 3

log_level :debug

stdout_path STDOUT

worker_run do |addr, port, id, logger|
  logger.debug('call worker_run')
  @server = SimpleServer.new(addr, port, logger, id)
  @server.run
end

worker_stop do |logger|
  logger.debug('call worker_stop')
  @server.stop
end
