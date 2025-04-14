module Validators
  module Format
    class UsEinFormat < BaseValidator
      def call
        # Eliminamos cualquier carácter que no sea dígito
        digits = raw_number.gsub(/\D/, "")
        @normalized_number = digits

        unless digits.match?(/^\d{9}$/)
          errors << "Must contain exactly 9 numeric digits"
        end

        self
      end

      def formatted
        # Formateo: NN-NNNNNNN
        "#{@normalized_number[0, 2]}-#{@normalized_number[2, 7]}"
      end
    end
  end
end
