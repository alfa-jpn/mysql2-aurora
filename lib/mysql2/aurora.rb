require 'mysql2/aurora/version'
require 'mysql2'

module Mysql2
  # mysql2 aurora module
  # @note This module patch Mysql2::Client
  module Aurora
    # Implement client patch
    class Client
      attr_reader :client

      # Initialize class
      # @note [Override] with reconnect options
      # @param [Hash] opts Options
      # @option opts [Integer] aurora_max_retry Max retry count, when failover. (Default: 5)
      # @option opts [Bool] aurora_disconnect_on_readonly, when readonly exception hit terminate the connection (Default: false)
      def initialize(opts)
        @opts = Mysql2::Util.key_hash_as_symbols(opts)
        @max_retry = @opts.delete(:aurora_max_retry) || 5
        @disconnect_only = @opts.delete(:aurora_disconnect_on_readonly) || false
        reconnect!
      end

      # Execute query with reconnect
      # @note [Override] with reconnect.
      def query(*args)
        try_count = 0

        begin
          client.query(*args)
        rescue Mysql2::Error => e
          raise e unless e.message&.include?('--read-only')

          try_count += 1

          if @disconnect_only
            warn '[mysql2-aurora] Database is readonly, Aurora failover event likely occured, closing database connection'
            disconnect!
          elsif try_count <= @max_retry
            retry_interval_seconds = [1.5 * (try_count - 1), 10].min

            warn "[mysql2-aurora] Database is readonly. Retry after #{retry_interval_seconds}seconds"
            sleep retry_interval_seconds
            reconnect!
            retry
          end

          raise e
        end
      end

      # Reconnect to database and Set `@client`
      # @note If client is not connected, Connect to database.
      def reconnect!
        query_options = (@client&.query_options&.dup || {})

        disconnect!

        @client = Mysql2::Aurora::ORIGINAL_CLIENT_CLASS.new(@opts)
        @client.query_options.merge!(query_options)
      end

      # Close connection to database server
      def disconnect!
        @client&.close
      rescue StandardError
        nil
      end

      # Delegate method call to client.
      # @param [String] name  Method name
      # @param [Array]  args  Method arguments
      # @param [Proc]   block Method block
      def method_missing(name, *args, &block) # rubocop:disable Style/MethodMissingSuper, Style/MissingRespondToMissing
        client.public_send(name, *args, &block)
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

      # Delegate const definition to class.
      # @param [Symbol] name Const name
      def self.const_defined?(name)
        Mysql2::Aurora::ORIGINAL_CLIENT_CLASS.const_defined?(name)
      end
    end

    # Swap Mysql2::Client
    ORIGINAL_CLIENT_CLASS = Mysql2.send(:remove_const, :Client)
    Mysql2.const_set(:Client, Mysql2::Aurora::Client)
  end
end
