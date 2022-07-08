class ExampleJob < ActiveJob::Base
  queue_as :default
  sidekiq_options retry: 5

  def perform(params, count)
    sleep count
    puts params
  end
end
