module Validators
  module External
    class ExternalRegistryClient
      include HTTParty
      base_uri "http://localhost:4567"

      def self.lookup(number)
        response = get("/api/validate", query: { number: number })

        case response.code
        when 200
          {
            success: true,
            active: response["active"],
            name: response["name"],
            address: response["address"]
          }
        when 404
          {
            success: false,
            error: "Number not found in registry"
          }
        when 500
          {
            success: false,
            error: "Could not reach the external VAT registry"
          }
        else
          {
            success: false,
            error: "Unexpected error (#{response.code})"
          }
        end
      rescue StandardError => e
        {
          success: false,
          error: "Connection error: #{e.message}"
        }
      end
    end
  end
end
