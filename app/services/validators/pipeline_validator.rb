module Validators
  class PipelineValidator
    attr_reader :errors, :formatted_tax_number, :business_data, :external_service_message

    def initialize(country_code, raw_number)
      @country_code = country_code
      @raw_number = raw_number
      @errors = []
    end

    def run
      format_validator = format_validator_for(@country_code)
      checksum_validator = checksum_validator_for(@country_code)

      if format_validator.nil?
        @errors << "Unsupported country code"
        return self
      end

      # Fase 1: Validación de formato
      format_result = format_validator.call
      add_errors(format_result.errors)

      # Siempre intentamos guardar el formateado si pasa la fase 1 (aunque luego falle en checksum o externo)
      @formatted_tax_number = format_result.formatted if format_result.errors.empty?

      # Fase 2: Checksum (si aplica)
      if checksum_validator && format_result.errors.empty?
        checksum_result = checksum_validator.new(format_result.normalized_number).call
        add_errors(checksum_result.errors)
      end

      # Fase 3: Validación externa (solo si las anteriores pasaron)
      if errors.empty? && formatted_tax_number
        external = External::ExternalRegistryChecker.new(formatted_tax_number).call
        add_errors(external.errors)
        @business_data = external.business_data
        @external_service_message = external.external_message
      end

      self
    end

    def valid?
      errors.empty?
    end

    private

    def format_validator_for(country)
      {
        "US" => Format::UsEinFormat,
        "GB" => Format::GbVatFormat,
        "DE" => Format::DeVatFormat
      }[country]&.new(@raw_number)
    end

    def checksum_validator_for(country)
      {
        "GB" => Checksum::GbVatChecksum,
        "DE" => Checksum::DeVatChecksum
      }[country]
    end

    def add_errors(new_errors)
      @errors += new_errors if new_errors && !new_errors.empty?
    end
  end
end
