module Validators
  module Format
    class UsEinFormat < BaseValidator
      def call
        digits = raw_number.gsub(/\D/, "")
        @normalized_number = digits

        unless digits.match?(/^\d{9}$/)
          errors << "Must contain exactly 9 numeric digits"
        end

        self
      end

      def formatted
        "#{@normalized_number[0..1]}-#{@normalized_number[2..-1]}"
      end
    end
  end
end
