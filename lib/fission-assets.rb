require 'fission-assets/version'

module Fission
  module Assets
    autoload :Packer, 'fission-assets/packer'
    autoload :Provider, 'fission-assets/provider'
    autoload :Store, 'fission-assets/store'
    autoload :Error, 'fission-assets/error'
  end
end
