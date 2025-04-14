module Validators
  module Format
    class DeVatFormat < BaseValidator
      def call
        cleaned = raw_number.gsub(/[^A-Za-z0-9]/, "").upcase
        cleaned = "DE#{cleaned}" unless cleaned.start_with?("DE")
        digits = cleaned.sub(/^DE/, "")

        @normalized_number = digits

        unless digits.match?(/^\d+$/)
          errors << "Invalid characters: must be numeric digits after 'DE'"
        end

        if digits.length != 9
          errors << "Incorrect length: expected 9 digits but found #{digits.length}"
        end

        self
      end

      def formatted
        "DE #{@normalized_number}"
      end
    end
  end
end
