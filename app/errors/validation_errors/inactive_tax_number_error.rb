module ValidationErrors
  class InactiveTaxNumberError < BaseError
    def default_message
      "Number not active in registry"
    end
  end
end
