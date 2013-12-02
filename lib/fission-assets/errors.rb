module Fission
  module Assets
    class Error < StandardError
      class NotFound < Error
      end
    end
  end
end
