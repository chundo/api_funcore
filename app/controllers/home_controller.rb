# frozen_string_literal: true

class HomeController < AppController
  def index
    job = ExampleJob.perform_later('ideardev', 2)
    jid = job.provider_job_id
    puts Sidekiq::Queue.all.to_json

    render json: { message: 'Hola' }, status: :ok
  end
end
