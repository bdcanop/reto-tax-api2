module ValidationErrors
  class ChecksumError < BaseError
    def default_message
      "Checksum validation failed"
    end
  end
end
