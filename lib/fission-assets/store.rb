require 'tempfile'
require 'fission-assets/errors'
require 'carnivore/config'

module Fission
  module Assets
    class Store

      attr_reader :provider, :arguments, :bucket

      def initialize(args={})
        @bucket = args.delete(:bucket) || Carnivore::Config.get(:fission, :assets, :bucket)
        @provider = args.fetch(:provider, Carnivore::Config.get(:fission, :assets, :connection, :provider) || :local).to_sym
        @arguments = args
        require "fission-assets/providers/#{provider}"
        extend Fission::Assets::Providers.const_get(provider.to_s.split('_').map(&:capitalize).join)
        setup(args)
      end

      def get(key)
        raise NotImplementedError.new "`#get` has not been implemented for #{provider} provider"
      end

      def put(key, file)
        raise NotImplementedError.new "`#put` has not been implemented for #{provider} provider"
      end

      def delete(key)
        raise NotImplementedError.new "`#delete` has not been implemented for #{provider} provider"
      end

      def url(key, expires=nil)
        raise NotImplementedError.new "`#url` has not been implemented for #{provider} provider"
      end

    end
  end
end
