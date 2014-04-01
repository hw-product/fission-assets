require 'fission-assets'

module Fission
  module Assets
    module Provider
      autoload :Local, 'fission-assets/provider/local'
      autoload :Aws, 'fission-assets/provider/aws'
    end
  end
end
