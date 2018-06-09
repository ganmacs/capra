require 'socket'
require 'timeout'
require 'capra/backends'

module Capra
  class LoadBlancer
    def initialize(addr, port, backends)
      @addr = addr
      @port = port
      @backends = backends
    end

    def run
      @sock = listen(@addr, @port)

      loop do
        Thread.new(@sock.accept) do |sock|
          do_request(sock)
        end
      end
    end

    def stop
      @sock.close
    end

    private

    def do_request(sock)
      Timeout.timeout(5) do
        bc = @backends.select
        Capra.logger.debug("Connect to #{bc[:addr]}:#{bc[:port]}")
        upstream = TCPSocket.open(bc[:addr], bc[:port])

        begin
          t1 = Thread.new { copy(sock, upstream) }
          t2 = Thread.new { copy(upstream, sock) }

          t1.join
          Capra.logger.debug("t1 Finish #{bc[:addr]}:#{bc[:port]}")
          t2.join

          Capra.logger.debug("Finish #{bc[:addr]}:#{bc[:port]}")
        rescue => e
          Capra.logger.error(e)
        end
      end
    rescue Timeout::Error
    # DO
    ensure
      sock.close
    end

    def copy(src, dest)
      IO.copy_stream(src, dest)
    rescue Errno::EBADF => _
    # ok
    ensure
      src.close
      dest.close
    end

    def listen(addr, port)
      Capra.logger.info("capra: listen #{addr}:#{port}")
      sock = TCPServer.new(addr, port)
      sock.listen(1000)
      sock
    end
  end
end
