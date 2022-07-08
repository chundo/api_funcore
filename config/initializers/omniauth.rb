Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer if Rails.env.development?
  provider :github, ENV['GIT_KEY'], ENV['GIT_SECRET'], scope: 'user,repo,gist'
  provider :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET'], token_params: { parse: :json }
end

OmniAuth.config.allowed_request_methods = [:get]
OmniAuth.config.silence_get_warning = true
