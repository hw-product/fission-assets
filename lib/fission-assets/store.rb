require 'tempfile'
require 'fission-assets/errors'
require 'carnivore/config'

require 'fission-assets'

module Fission
  module Assets
    # Object storage helper
    class Store

      # @return [String] bucket name
      attr_accessor :bucket
      # @return [Symbol] provider type
      attr_reader :provider
      # @return [Hash] initializer arguments
      attr_reader :arguments
      # @return [Object] remote connection if applicable
      attr_reader :connection

      # Create new instance
      #
      # @param args [Hash]
      # @option args [String] :bucket bucket name
      # @option args [String] :provider provider name
      def initialize(args={})
        @bucket = args.delete(:bucket) || Carnivore::Config.get(:fission, :assets, :bucket)
        @provider = args.fetch(:provider, Carnivore::Config.get(:fission, :assets, :connection, :provider) || :local).to_sym
        @arguments = args
        extend Fission::Assets::Provider.const_get(provider.to_s.split('_').map(&:capitalize).join)
        setup(args)
      end

      # Fetch object
      #
      # @param key [String]
      # @return [File]
      def get(key)
        raise NotImplementedError.new "`#get` has not been implemented for #{provider} provider"
      end

      # Store object
      #
      # @param key [String]
      # @param file [File]
      def put(key, file)
        raise NotImplementedError.new "`#put` has not been implemented for #{provider} provider"
      end

      # Delete object
      #
      # @param key [String]
      def delete(key)
        raise NotImplementedError.new "`#delete` has not been implemented for #{provider} provider"
      end

      # URL for object
      #
      # @param key [String]
      # @param expires_in [Numeric] number of seconds url is valid
      # @return [String]
      def url(key, expires_in=nil)
        raise NotImplementedError.new "`#url` has not been implemented for #{provider} provider"
      end

    end
  end
end
