require "logger"

module Zir
  class Logger
    @@logger : Logger?
    @@quite  : Bool = false

    def initialize
    end

    def self.set_quite(@@quite : Bool)
    end

    def self.i(msg)
      @@logger = Logger.new if @@logger.nil?
      @@logger.not_nil!.i(msg)
    end

    def i(msg)
      puts "\e[36m[zir]\e[m #{msg}" unless @@quite
    end

    def self.w(msg)
      @@logger = Logger.new if @@logger.nil?
      @@logger.not_nil!.w(msg)
    end

    def w(msg)
      puts "\e[33m[zir]\e[m #{msg}" unless @@quite
    end

    def self.e(msg)
      @@logger = Logger.new if @@logger.nil?
      @@logger.not_nil!.e(msg)
    end

    def e(msg)
      puts "\e[31m[zir]\e[m #{msg}" unless @@quite
    end
  end
end
