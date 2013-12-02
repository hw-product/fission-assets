require 'tempfile'
require 'fission-assets/errors'
require 'carnivore/config'

module Fission
  module Assets
    class Store

      attr_reader :provider, :arguments, :bucket

      def initialize(args={})
        @bucket = args.delete(:bucket) || Carnivore::Config.get(:fission, :assets, :bucket)
        @provider = args.fetch(:provider, :local).to_sym
        @arguments = args
        require "fission-assets/providers/#{provider}"
        provider_module = Fission::Assets::Providers.const_get(provider.to_s.split('_').map(&:capitalize).join)
        extend provider_module
        setup(args)
        if(provider == :local)
          require 'fileutils'
          FileUtils.mkdir_p(bucket)
        else
          require 'fog'
          @connection = Fog::Storage.new(fog_args)
        end
      end

    end
  end
end
