module Fission
  module Assets
    module Provider
      # Provider module for AWS S3 end point
      module Aws

        # Size of megabyte
        MEG = 1024 * 1024
        # Number of megabytes per chunk
        MULTIPART_MEG_CHUNK = 10

        # Set bucket
        #
        # @param bucket_name [String]
        # @return [String] bucket name
        def bucket=(bucket_name)
          @bucket = bucket_name
          init_bucket if bucket_name
          bucket_name
        end

        # Setup provider
        #
        # @param args [Hash]
        def setup(args={})
          fog_args = Smash.new(:provider => 'AWS')
          fog_args.merge!(Carnivore::Config.get(:fission, :assets, :connection) || {})
          fog_args.merge!(args)
          @provider = fog_args[:provider].to_s.downcase.to_sym
          @arguments = fog_args
          require 'fog'
          @connection = Fog::Storage.new(fog_args)
          init_bucket if bucket
        end

        # Delete object
        #
        # @param key [String]
        def delete(key)
          begin
            connection.delete_object(bucket, key)
          rescue Excon::Errors::NotFound
            raise Fission::Assets::Error::NotFound.new(key)
          end
        end

        # Fetch object
        #
        # @param key [String]
        # @return [File]
        def get(key)
          file = Tempfile.new(key.gsub('/', '-'))
          begin
            file.binmode
            connection.get_object(bucket, key) do |chunk|
              yield chunk if block_given?
              file.write chunk
            end
            file.flush
            file.rewind
            file
          rescue Excon::Errors::NotFound
            raise Fission::Assets::Error::NotFound.new(key)
          end
        end

        # Store object
        #
        # @param key [String]
        # @param file [File]
        def put(key, file)
          unless(file.respond_to?(:read))
            file = File.open(file.to_s, 'rb')
          end
          if((parts = file.size / (MEG * MULTIPART_MEG_CHUNK)) > 0)
            parts += 1
            init = connection.initiate_multipart_upload(bucket, key)
            uploads = parts.times.map do |i|
              upload_chunk = file.read(MEG * MULTIPART_MEG_CHUNK)
              connection.upload_part(
                bucket, key, init.body['UploadId'], i+1, upload_chunk
              ).headers['ETag']
            end
            connection.complete_multipart_upload(bucket, key, init.body['UploadId'], uploads)
          else
            connection.put_object(bucket, key, file)
          end
          file.close
          true
        end

        # URL for object
        #
        # @param key [String]
        # @param expires_in [Numeric] number of seconds url is valid
        # @return [String]
        def url(key, expire_in=30)
          connection.get_object_url(bucket, key, Time.now.to_i + expire_in.to_i)
        end

        protected

        # Initialize bucket
        def init_bucket
          unless(bucket == :none)
            begin
              connection.get_bucket(bucket)
            rescue Excon::Errors::NotFound
              begin
                connection.put_bucket(bucket)
              rescue Excon::Errors::BadRequest => e
                if(connection.region && e.response.body.include?("IllegalLocationConstraintException"))
                  args = arguments.dup
                  args.delete(:region)
                  @connection = Fog::Storage.new(args)
                  retry
                else
                  raise
                end
              end
            rescue Excon::Errors::MovedPermanently
              if(connection.region)
                args = arguments.dup
                if(args.include?(:region))
                  args.delete(:region)
                  @connection = Fog::Storage.new(args)
                else
                  raise
                end
                retry
              else
                raise
              end
            end
          end
        end

      end
    end
  end
end
