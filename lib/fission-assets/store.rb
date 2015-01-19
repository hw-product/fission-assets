require 'fission-assets'

module Fission
  module Assets
    class Store < Jackal::Assets::Store

      # @return [String] name of bucket
      def bucket_name
        super ||
          Carnivore::Config.get(:fission, :assets, :bucket)
      end

      # @return [Smash] connection arguments
      def connection_arguments
        result = super
        if(result.empty?)
          result = Carnivore::Config.fetch(:fission, :assets, :connection, result)
        end
        result
      end

    end
  end
end
