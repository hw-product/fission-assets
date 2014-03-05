require 'fileutils'
require 'fission-assets/errors'

module Fission
  module Assets
    module Providers
      module Local

        def setup(args={})
          @bucket ||= '/tmp/fission-assets'
          require 'fileutils'
          FileUtils.mkdir_p(bucket)
        end

        def delete(key)
          if(File.exists?(path = File.join(bucket, key)))
            File.delete(path)
          else
            raise Fission::Assets::Error::NotFound.new(key)
          end
        end

        def get(key)
          path = File.join(bucket, key)
          if(File.exists?(path))
            file = Tempfile.new(key.tr('/', '-'))
            file.binmode
            File.open(File.join(bucket, key), 'rb') do |f|
              while(data = f.read(2048))
                file.write data
              end
            end
            file.flush
            file.fsync
            file.rewind
            file
          else
            raise Fission::Assets::Error::NotFound.new(key)
          end
        end

        def put(key, file)
          unless(file.respond_to?(:read))
            file = File.open(file.to_s, 'rb')
          end
          storage_path = File.join(bucket, key)
          FileUtils.mkdir_p(File.dirname(storage_path))
          File.open(storage_path, 'wb') do |f|
            while(data = file.read(2048))
              f.write data
            end
          end
          true
        end

      end
    end
  end
end
