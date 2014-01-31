require 'fileutils'
require 'tempfile'
require 'zip'

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
              elsif(File.symlink?(path))
                zipfile.add(entry, path)
              else
                zipfile.get_output_stream(entry) do |content|
                  content << File.read(path)
                end
              end
            end
          end
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
            Zip::File.new(object.respond_to?(:path) ? object.path : object).each do |entry|
              new_dest = File.join(destination, entry.name)
              entry.extract(new_dest)
            end
            destination
          end
        end

      end
    end
  end
end
