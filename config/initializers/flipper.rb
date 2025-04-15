Flipper.configure do |config|
  config.default do
    adapter = Flipper::Adapters::Memory.new
    flipper = Flipper.new(adapter)

    if ENV["USE_EXTERNAL_VALIDATION"] == "false"
      flipper.disable(:use_external_validation)
    else
      flipper.enable(:use_external_validation)
    end

    if ENV["ENABLE_CHECKSUM_VALIDATION"] == "false"
      flipper.disable(:enable_checksum_validation)
    else
      flipper.enable(:enable_checksum_validation)
    end

    flipper
  end
end
