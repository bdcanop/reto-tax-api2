module Validators
  class PipelineValidator
    attr_reader :errors, :formatted_tax_number, :business_data, :external_service_message

    def initialize(country_code, raw_number)
      @country_code = country_code
      @raw_number = raw_number
      @errors = []
    end

    def run
      case @country_code
      when "US"
        format = Format::UsEinFormat.new(@raw_number).call
        add_errors(format.errors)
        @formatted_tax_number = format.formatted if errors.empty?
      when "GB"
        format = Format::GbVatFormat.new(@raw_number).call
        add_errors(format.errors)
        checksum = Checksum::GbVatChecksum.new(format.normalized_number).call if errors.empty?
        add_errors(checksum.errors) if checksum
        @formatted_tax_number = format.formatted if errors.empty?
      when "DE"
        format = Format::DeVatFormat.new(@raw_number).call
        add_errors(format.errors)
        checksum = Checksum::DeVatChecksum.new(format.normalized_number).call if errors.empty?
        add_errors(checksum.errors) if checksum
        @formatted_tax_number = format.formatted if errors.empty?
      else
        @errors << "Unsupported country code"
      end

      # External validation (if format + checksum passed)
      if errors.empty? && @formatted_tax_number
        external = External::ExternalRegistryChecker.new(@formatted_tax_number).call
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

    def add_errors(new_errors)
      @errors += new_errors if new_errors
    end
  end
end
