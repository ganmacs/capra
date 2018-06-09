require 'optparse'
require 'capra/dsl'
require 'capra/application'

module Capra
  class CLI
    DEFAULT_CONFIG_PATH = 'capra.ru'.freeze

    def self.run(argv)
      new.run(argv)
    end

    def run(argv)
      parse!(argv)
      config = DSL.evaulate(@opts, @config_path)
      Application.run(config)
    end

    private

    def initialize
      @opts = {}
    end

    def parse!(argv)
      parser.parse!(argv)
      @config_path = argv.first || DEFAULT_CONFIG_PATH
    end

    def parser
      @parser ||= OptionParser.new do |opts|
        opts.banner = 'capra [OPTIONS] [FILE]'
        opts.version = VERSION
        opts.on('--adder', 'address') { |v| @opts[:addr] = v }
        opts.on('--port',  'port') { |v| @opts[:port] = v }
      end
    end
  end
end
