module Validators
  module External
    class ExternalRegistryClient
      BASE_URL = "http://localhost:4567"
      CIRCUIT_NAME = "external_vat_registry"

      def self.lookup(number)
        circuit = Circuitbox.circuit(
          CIRCUIT_NAME,
          exceptions: [ Faraday::Error, Faraday::TimeoutError ],
          sleep_window: 10,
          volume_threshold: 2,
          error_threshold: 50,
          time_window: 60
        )


        response = circuit.run do
          connection.get("/api/validate", { number: number })
        end

        return handle_failure("Circuit open or request failed") if response.nil?

        case response.status
        when 200
          data = JSON.parse(response.body)
          {
            success: true,
            active: data["active"],
            name: data["name"],
            address: data["address"]
          }
        when 404
          handle_failure("Number not found in registry")
        when 500
          handle_failure("Could not reach the external VAT registry")
        else
          handle_failure("Unexpected error (#{response.status})")
        end

      rescue Faraday::TimeoutError
        handle_failure("Request to registry timed out")
      rescue StandardError => e
        handle_failure("Unhandled error: #{e.message}")
      end

      def self.handle_failure(message)
        { success: false, error: message }
      end

      def self.connection
        Faraday.new(url: BASE_URL, request: { timeout: 2 }) do |conn|
          conn.request :retry, max: 2, interval: 0.1, interval_randomness: 0.2, backoff_factor: 2
          conn.response :logger if Rails.env.development?
          conn.adapter Faraday.default_adapter
        end
      end
    end
  end
end
