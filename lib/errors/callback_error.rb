# lib/errors/callback_error.rb

require 'errors/errors'

module Mithril::Errors
  class CallbackError < StandardError
    # A hash of arrays. Each key corresponds to a callback that was attempted
    # to be set, and the array items the specific errors associated with that
    # callback.
    def errors
      @errors ||= {}
    end # method errors
  end # class CallbackError
end # module
