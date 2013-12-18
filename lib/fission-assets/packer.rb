require 'fileutils'
require 'tempfile'
require 'zlib'
require 'archive/tar/minitar'

module Fission
  module Assets
    class Packer
      class << self

        # directory:: directory path
        # Pack the given directory in a tarball and return `File`
        def pack(directory)
          file = Tempfile.new(File.basename(directory))
          file.binmode
          Dir.chdir(directory) do
            Archive::Tar::Minitar.pack('.', file)
          end
          if(file.closed?)
            file = File.open(file.path, 'r')
          else
            file.rewind
          end
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
            Dir.chdir(destination) do
              Archive::Tar::Minitar.unpack(object.path, '.')
            end
            destination
          end
        end

      end
    end
  end
end
