$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__)) + '/lib/'
require 'fission-assets/version'
Gem::Specification.new do |s|
  s.name = 'fission-assets'
  s.version = Fission::Assets::VERSION.version
  s.summary = 'Fission Asset Interface'
  s.author = 'Heavywater'
  s.email = 'fission@hw-ops.com'
  s.homepage = 'http://github.com/heavywater/fission-assets'
  s.description = 'Fission Assets'
  s.require_path = 'lib'
  s.add_dependency 'fission'
  s.add_dependency 'fog'
  s.add_dependency 'rubyzip'
  s.files = Dir['{lib}/**/**/*'] + %w(fission-assets.gemspec README.md CHANGELOG.md)
end
