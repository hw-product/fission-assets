module Fission
  module Assets
    module Providers
      module Aws

        def setup(args={})
          fog_args = {:provider => 'AWS'}
          fog_args.merge!(Carnivore::Config.get(:fission, :assets, :connection) || {})
          fog_args.merge!(args)
          @provider = fog_args[:provider].to_s.downcase.to_sym
          @arguments = fog_args
          if(provider == :local)
            require 'fileutils'
            FileUtils.mkdir_p(bucket)
          else
            require 'fog'
            @connection = Fog::Storage.new(fog_args)
          end

        end

        def delete(key)
          @connection.delete_object(bucket, key)
        end

        def get(key)
          object = @connection.get_object(bucket, key)
          file = Tempfile.new(key)
          file.binmode
          file.write object.body
          file.flush
          file.rewind
          file
        end

        def put(key, file)
          unless(file.respond_to?(:read))
            file = File.open(file.to_s, 'r')
          end
          @connection.put_object(bucket, key, file)
          true
        end
      end
    end
  end
end
