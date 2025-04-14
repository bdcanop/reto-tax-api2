module ValidationErrors
  class FormatError < BaseError
    def default_message
      "Invalid format"
    end
  end
end
