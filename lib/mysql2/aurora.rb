require 'mysql2/aurora/version'
require 'mysql2'

module Mysql2
  # mysql2 aurora module
  # @note This module patch Mysql2::Client
  module Aurora
    # Implement client patch
    class Client
      RETRY_INTERVAL_SECONDS = 1.5

      attr_reader :client

      # Initialize class
      # @note [Override] with reconnect options
      # @param [Hash] opts Options
      # @option opts [Integer] aurora_max_retry Max retry count, when failover. (Default: 5)
      def initialize(opts)
        @opts      = Mysql2::Util.key_hash_as_symbols(opts)
        @max_retry = @opts.delete(:aurora_max_retry) || 5
        reconnect!
      end

      # Execute query with reconnect
      # @note [Override] with reconnect.
      def query(*args)
        try_count = 0

        begin
          client.query(*args)
        rescue Mysql2::Error => e
          try_count += 1

          if e.message&.include?('--read-only') && try_count <= @max_retry
            warn "[mysql2-aurora] Database is readonly. Retry after #{RETRY_INTERVAL_SECONDS}seconds"
            sleep RETRY_INTERVAL_SECONDS
            reconnect!
            retry
          else
            raise e
          end
        end
      end

      # Reconnect to database and Set `@client`
      # @note If client is not connected, Connect to database.
      def reconnect!
        begin
          @client&.close
        rescue StandardError
          nil
        end
        @client = Mysql2::Aurora::ORIGINAL_CLIENT_CLASS.new(@opts)
      end

      # Delegate method call to client.
      # @param [String] name  Method name
      # @param [Array]  args  Method arguments
      # @param [Proc]   block Method block
      def method_missing(name, *args, &block) # rubocop:disable Style/MethodMissingSuper, Style/MissingRespondToMissing
        @client.public_send(name, *args, &block)
      end

      # Delegate method call to Mysql2::Client.
      # @param [String] name  Method name
      # @param [Array]  args  Method arguments
      # @param [Proc]   block Method block
      def self.method_missing(name, *args, &block) # rubocop:disable Style/MethodMissingSuper, Style/MissingRespondToMissing
        Mysql2::Aurora::ORIGINAL_CLIENT_CLASS.public_send(name, *args, &block)
      end

      # Delegate const reference to class.
      # @param [Symbol] name Const name
      def self.const_missing(name)
        Mysql2::Aurora::ORIGINAL_CLIENT_CLASS.const_get(name)
      end
    end

    # Swap Mysql2::Client
    ORIGINAL_CLIENT_CLASS = Mysql2.send(:remove_const, :Client)
    Mysql2.const_set(:Client, Mysql2::Aurora::Client)
  end
end
