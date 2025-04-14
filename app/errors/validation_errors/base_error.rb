module ValidationErrors
  class BaseError < StandardError
    attr_reader :message

    def initialize(message = nil)
      @message = message || default_message
    end

    def default_message
      "Validation error occurred"
    end
  end
end
