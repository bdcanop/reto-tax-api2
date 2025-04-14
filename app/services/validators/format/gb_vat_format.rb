module Validators
  module Format
    class GbVatFormat < BaseValidator
      def call
        cleaned = raw_number.gsub(/[^A-Za-z0-9]/, "").upcase
        # Agregamos el prefijo "GB" si falta
        cleaned = "GB#{cleaned}" unless cleaned.start_with?("GB")
        digits = cleaned.sub(/^GB/, "")

        @normalized_number = digits

        unless digits.match?(/^\d+$/)
          errors << "Invalid characters detected: VAT number must contain only numeric digits"
        end

        errors << "Incorrect length: expected 9 digits but found #{digits.length}" if digits.length != 9
        self
      end

      def formatted
        # Formateo: GB 123 4567 89
        "GB #{normalized_number[0, 3]} #{normalized_number[3, 4]} #{normalized_number[7, 2]}"
      end
    end
  end
end
