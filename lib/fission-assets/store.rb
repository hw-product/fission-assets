require 'tempfile'
require 'carnivore/config'

module Fission
  module Assets
    class Store

      attr_reader :provider, :arguments, :bucket, :connection

      def initialize(args={})
        @bucket = args.delete(:bucket) || Carnivore::Config.get(:fission, :assets, :bucket)
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

      # key:: Key path to item
      # Returns Tempfile instance with object contents
      def get(key)
        case provider
        when :local
          local_get(key)
        else
          s3_get(key)
        end
      end

      # key:: Key path to item
      # file:: IO instance or path to file
      def put(key, file)
        case provider
        when :local
          local_put(key, file)
        else
          s3_put(key, file)
        end
      end

      protected

      def local_get(key)
        file = Tempfile.new(key)
        File.open(File.join(bucket, key), 'r') do |f|
          while(data = f.read(2048))
            file.write data
          end
        end
        file.rewind
        file
      end

      def local_put(key, file)
        unless(file.respond_to?(:read))
          file = File.open(file.to_s, 'r')
        end
        File.open(File.join(bucket, key), 'w') do |f|
          while(data = file.read(2048))
            f.write data
          end
        end
        true
      end

      def s3_get(key)
        object = @connection.get_object(bucket, key)
        file = Tempfile.new(key)
        file.write object.body
        file.flush
        file.rewind
        file
      end

      def s3_put(key, file)
        unless(file.respond_to?(:read))
          file = File.open(file.to_s, 'r')
        end
        @connection.put_object(bucket, key, file)
        true
      end
    end
  end
end
