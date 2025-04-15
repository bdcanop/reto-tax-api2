module Validators
  module External
    class ExternalRegistryChecker
      attr_reader :formatted_number, :errors, :business_data, :external_message

      def initialize(formatted_number)
        @formatted_number = formatted_number
        @errors = []
      end

      def call
        start = Time.now
        result = ExternalRegistryClient.lookup(formatted_number)

        duration = Time.now - start

        payload = {
          number: formatted_number,
          duration: duration,
          status: if result[:success]
                    result[:active] ? "success" : "inactive"
                  else
                    "error"
                  end
        }

        ActiveSupport::Notifications.instrument("external_registry.validate", payload)

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
