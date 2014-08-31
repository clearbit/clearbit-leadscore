require 'thread/pool'

module Clearbit
  module LeadScore
    class Async
      def self.instance
        @instance ||= self.new
      end

      def self.lookup(email, &block)
        instance.lookup(email, &block)
      end

      def self.finish
        instance.finish
        @instance = nil
      end

      attr_reader :pool

      def initialize(options = {})
        @pool = options[:pool] || Thread.pool(8)
      end

      def lookup(email, &block)
        pool.process do
          block.call LeadScore.lookup(email)
        end
      end

      def finish
        pool.shutdown
      end
    end
  end
end