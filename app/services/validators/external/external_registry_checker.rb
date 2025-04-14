module Validators
  module External
    class ExternalRegistryChecker
      attr_reader :formatted_number, :errors, :business_data, :external_message

      def initialize(formatted_number)
        @formatted_number = formatted_number
        @errors = []
      end

      def call
        result = ExternalRegistryClient.lookup(formatted_number.delete(" "))

        if !result[:success]
          @external_message = result[:error]
          errors << result[:error]
        elsif !result[:active]
          errors << "Number not active in registry"
        else
          @business_data = {
            name: result[:name],
            address: result[:address]
          }
        end
        self
      end
    end
  end
end
