module ValidationErrors
  class ExternalServiceError < BaseError
    def default_message
      "Could not reach the external VAT registry"
    end
  end
end
