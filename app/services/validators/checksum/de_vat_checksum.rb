module Validators
  module Checksum
    class DeVatChecksum < BaseValidator
      def initialize(normalized_number)
        @normalized_number = normalized_number
        @errors = []
      end

      def call
        return self unless @normalized_number.length == 9

        expected = (@normalized_number[0..7].chars.map(&:to_i).sum * 3) % 10
        actual = @normalized_number[8].to_i

        if expected != actual
          errors << "Checksum validation failed: expected check digit #{expected} but found #{actual}."
        end

        self
      end
    end
  end
end
