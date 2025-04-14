module Validators
  class BaseValidator
    attr_reader :raw_number, :errors, :normalized_number

    def initialize(raw_number)
      @raw_number = raw_number
      @errors = []
    end

    def call
      raise NotImplementedError
    end
  end
end
