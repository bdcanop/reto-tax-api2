module Validators
  module Checksum
    class GbVatChecksum < BaseValidator
      def initialize(normalized_number)
        @normalized_number = normalized_number
        @errors = []
      end

      def call
        expected = @normalized_number[0..7].chars.map(&:to_i).sum % 10
        actual = @normalized_number[8].to_i

        errors << "Checksum validation failed: expected #{expected}, got #{actual}" if expected != actual
        self
      end
    end
  end
end
