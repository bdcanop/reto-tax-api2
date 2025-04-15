ActiveSupport::Notifications.subscribe("external_registry.validate") do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)

  Rails.logger.info "[ExternalRegistry] Number=#{event.payload[:number]} | Status=#{event.payload[:status]} | Duration=#{event.payload[:duration].round(3)}s"

  # Podría enviar a Datadog o algo por el estilo
end
