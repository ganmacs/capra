require 'thwait'
require 'socket'
require 'timeout'
require 'capra/backends'

module Capra
  class LoadBlancer
    def initialize(addr, port, thread_size, timeout, backends)
      @addr = addr
      @port = port
      @backends = backends
      @socks = Queue.new
      @metrics_que = Queue.new
      @thread_size = thread_size
      @timeout = timeout
    end

    def run
      # if debug?
      Thread.new { log_metrics }
      # end

      Thread.new { start_dispatcher }
      start_listener
    end

    def stop
      @stop = true
      @sock.close
    end

    private

    def log_metrics
      loop do
        sleep 0.5
        Capra.logger.debug("Stacked queue count: #{@metrics_que.size}, queued request: #{@socks.size}, free worker count: #{@socks.num_waiting}")
      end
    end

    def start_dispatcher
      @thread_size.times.map do
        Thread.new(@socks) do |socks|
          loop { do_request(socks.pop) }
        end
      end.each(&:join)
    rescue => e
      Capra.logger.error(e)
    end

    def start_listener
      @sock = listen(@addr, @port)
      loop do
        @metrics_que.enq 1
        @socks.enq @sock.accept
      end
    rescue => e
      Capra.logger.error(e) unless @stop
    end

    def do_request(sock)
      bc = @backends.select
      Capra.logger.debug("Connect to #{bc[:addr]}:#{bc[:port]}")

      upstream = nil
      upstream = Timeout.timeout(@timeout) do
        TCPSocket.open(bc[:addr], bc[:port])
      end

      t1 = Thread.new { copy_stream(sock, upstream) }
      t2 = Thread.new { copy_stream(upstream, sock) }

      threads = [t1, t2]
      thall = ThreadsWait.new(*threads)
      thall.next_wait # wait for first one thread
      Capra.logger.debug("Finish #{bc[:addr]}:#{bc[:port]}")
    rescue => e
      Capra.logger.error(e)
    ensure
      sock.close
      upstream.close if upstream
      @metrics_que.pop
      threads.each(&:kill)
    end

    def copy_stream(src, dest)
      IO.copy_stream(src, dest)
    rescue Errno::EBADF => _
    # nothing
    rescue => e
      Capra.logger.error(e)
    end

    def listen(addr, port)
      Capra.logger.info("capra: listen #{addr}:#{port}")
      sock = TCPServer.new(addr, port)
      sock.listen(1000)
      sock
    end
  end
end
