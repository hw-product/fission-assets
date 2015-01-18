require 'jackal-assets'

module Fission
  # Asset storage helper
  module Assets
    autoload :Packer, 'fission-assets/packer'
    autoload :Provider, 'fission-assets/provider'
    autoload :Store, 'fission-assets/store'
    autoload :Error, 'fission-assets/errors'
  end
end

require 'fission-assets/version'
