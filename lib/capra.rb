require 'logger'
require 'capra/cli'
require 'capra/version'

module Capra
  class << self
    def build_logger(dev = STDOUT, level = :info)
      @logger = Logger.new(dev, level: level)
    end

    def logger
      @logger ||= build_logger
    end
  end
end
