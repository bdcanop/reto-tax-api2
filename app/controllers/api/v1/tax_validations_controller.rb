module Api::V1
  class TaxValidationsController < ApplicationController
    def validate
      validator = Validators::PipelineValidator.new(params[:country_code], params[:tax_number]).run

      render json: {
        valid: validator.valid?,
        tax_type: "#{params[:country_code].downcase}_vat",
        formatted_tax_number: validator.formatted_tax_number,
        business_registration: validator.business_data,
        external_service_message: validator.external_service_message,
        errors: validator.errors
      }
    end
  end
end
