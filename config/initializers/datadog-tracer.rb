# config/initializers/datadog-tracer.rb

# Rails.configuration.datadog_trace = {
#     auto_instrument: true,
#     auto_instrument_redis: true,
#     enabled: false
#   }

Datadog.configure do |c|
  c.use :rails
end