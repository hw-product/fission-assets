require 'fileutils'
require 'tempfile'
require 'archive/zip'

module Fission
  module Assets
    class Packer
      class << self

        # directory:: directory path
        # Pack the given directory in a tarball and return `File`
        def pack(directory, name=nil)
          tmp_file = Tempfile.new(name || File.basename(directory))
          file_path = "#{tmp_file.path}.zip"
          tmp_file.delete
          Dir.chdir(directory) do
            raise "Failed to pack object" unless system("zip -q -r #{file_path} .")
          end
=begin
          file = File.open(file_path, 'wb')
          Dir.chdir(directory) do
            Archive::Zip.archive(file, './', :symlinks => true)
          end
          file.flush
          file.fsync
=end
          file = File.open(file_path, 'rb')
          file
        end

        # object:: `File` object
        # destination:: Destination path
        # Unpack the given object into the given destination
        def unpack(object, destination, *args)
          if(File.exists?(destination) && args.include?(:disable_overwrite))
            destination
          else
            unless(File.directory?(destination))
              FileUtils.mkdir_p(destination)
            end
            if(true) #RUBY_PLATFORM == 'java')
              # zlib bug in java causing buffer issues :(
              Dir.chdir(destination) do
                raise 'Failed to unpack object' unless system("unzip -q #{object.path} -d #{destination}")
              end
            else
              Archive::Zip.extract(object, File.join(destination, '.'), :symlinks => true)
            end
            destination
          end
        end

      end
    end
  end
end
