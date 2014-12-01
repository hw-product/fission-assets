require 'fileutils'
require 'tempfile'
require 'zip'

require 'fission-assets'

module Fission
  module Assets
    # Asset pack and unpacker
    class Packer
      class << self

        # Pack directory into compressed file
        #
        # @param directory [String]
        # @param name [String] tmp file base name
        # @return [File]
        def pack(directory, name=nil)
          tmp_file = Tempfile.new(name || File.basename(directory))
          file_path = "#{tmp_file.path}.zip"
          tmp_file.delete
          entries = Hash[
            Dir.glob(File.join(directory, '**', '{*,.*}')).map do |path|
              next if path.end_with?('.')
              [path.sub(%r{#{Regexp.escape(directory)}/?}, ''), path]
            end
          ]
          Zip::File.open(file_path, Zip::File::CREATE) do |zipfile|
            entries.keys.sort.each do |entry|
              path = entries[entry]
              if(File.directory?(path))
                zipfile.mkdir(entry.dup)
              else
                zipfile.add(entry, path)
              end
            end
          end
          file = File.open(file_path, 'rb')
          file
        end

        # Unpack object
        #
        # @param object [File]
        # @param destination [String]
        # @param args [Symbol] argument list (:disable_overwrite)
        # @return [String] destination
        def unpack(object, destination, *args)
          if(File.exists?(destination) && args.include?(:disable_overwrite))
            destination
          else
            unless(File.directory?(destination))
              FileUtils.mkdir_p(destination)
            end
            zfile = Zip::File.new(object.respond_to?(:path) ? object.path : object)
            zfile.restore_permissions = true
            zfile.each do |entry|
              new_dest = File.join(destination, entry.name)
              if(File.exists?(new_dest))
                FileUtils.rm_rf(new_dest)
              end
              entry.restore_permissions = true
              entry.extract(new_dest)
            end
            destination
          end
        end

      end
    end
  end
end
