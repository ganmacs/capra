require 'load_balancer'
require 'optparse'
require 'pathname'

module Capra
  class CLI
    def self.run(args)
      new.run(args)
    end

    def run
      parse!
    end

    private

    def parse!
      @config_path = 'capra'
      @host = '127.0.0.1'
      @port = '8000'
      @backends = []
      parser.parse!(argv)
    end

    def parser
      @parser ||= OptionParser.new do |opts|
        opts.banner = 'capra'
        opts.version = VERSION
        opts.on('-c', '--config', 'config file path') { @config_path = true }
        opts.on('--adder', 'address') { |v| @addr = v }
        opts.on('--port',  'port') { |v| @port = v }
      end
    end
  end
end
