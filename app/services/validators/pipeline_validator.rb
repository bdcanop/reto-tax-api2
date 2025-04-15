module Validators
  class PipelineValidator
    attr_reader :errors, :formatted_tax_number, :business_data, :external_service_message

    def initialize(country_code, raw_number)
      @country_code = country_code.upcase
      @raw_number = raw_number
      @errors = []
    end

    def run
      begin
        format_validator = format_validator_for(@country_code)
        raise ValidationErrors::UnsupportedCountryError if format_validator.nil?

        format_result = format_validator.call
        raise ValidationErrors::FormatError, format_result.errors.join(", ") unless format_result.errors.empty?

        @formatted_tax_number = format_result.formatted

        if Flipper.enabled?(:enable_checksum_validation) && (checksum_validator = checksum_validator_for(@country_code))
          checksum_result = checksum_validator.new(format_result.normalized_number).call
          raise ValidationErrors::ChecksumError, checksum_result.errors.join(", ") unless checksum_result.errors.empty?
        else
          Rails.logger.info "Checksum validation skipped due to feature flag"
        end

        if Flipper.enabled?(:use_external_validation)
          external = External::ExternalRegistryChecker.new(@formatted_tax_number).call

          unless external.errors.empty?
            external.errors.each do |err|
              if err.include?("not active")
                raise ValidationErrors::InactiveTaxNumberError
              else
                raise ValidationErrors::ExternalServiceError, err
              end
            end
          end

          @business_data = external.business_data
          @external_service_message = external.external_message
        else
          Rails.logger.info "External validation skipped due to feature flag"
        end

      rescue ValidationErrors::BaseError => e
        @errors << e.message
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
  end
end
