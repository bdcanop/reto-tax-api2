module ValidationErrors
  class UnsupportedCountryError < BaseError
    def default_message
      "Unsupported country code"
    end
  end
end
