module Validators
  module Format
    class GbVatFormat < BaseValidator
      def call
        cleaned = raw_number.gsub(/[^A-Za-z0-9]/, "").upcase
        cleaned = "GB#{cleaned}" unless cleaned.start_with?("GB")
        digits = cleaned.sub(/^GB/, "")

        @normalized_number = digits

        unless digits.match?(/^\d+$/)
          errors << "Invalid characters detected: must be digits"
        end

        errors << "Incorrect length: expected 9 digits but found #{digits.length}" if digits.length != 9
        self
      end

      def formatted
        "GB #{@normalized_number}"
      end
    end
  end
end
