module Validators
  module Format
    class DeVatFormat < BaseValidator
      def call
        cleaned = raw_number.gsub(/[^A-Za-z0-9]/, "").upcase
        # Agregamos el prefijo "DE" si falta
        cleaned = "DE#{cleaned}" unless cleaned.start_with?("DE")
        digits = cleaned.sub(/^DE/, "")

        @normalized_number = digits

        unless digits.match?(/^\d+$/)
          errors << "Invalid characters: must contain numeric digits after 'DE'"
        end

        errors << "Incorrect length: expected 9 digits but found #{digits.length}" if digits.length != 9
        self
      end

      def formatted
        # Formateo: "DE " seguido de los 9 dígitos sin agrupar (ej: "DE 123456788")
        "DE #{@normalized_number}"
      end
    end
  end
end
