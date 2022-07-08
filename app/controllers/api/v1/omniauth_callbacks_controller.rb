class Api::V1::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: %i[facebook github]
  skip_before_action :verify_authenticity_token

  def connector
    render json: request.env['omniauth.auth'].to_json
  end

  def passthru
    render json: request.env['omniauth.auth'].to_json
  end

  def failure
    begin
      user = User.from_omniauth(request.env['omniauth.auth'])
      user_result = request.env['omniauth.auth'].to_json
    rescue NoMethodError => e
      reponse = { user: nil, message: 'Error in petition, input null', error: e }
      render json: reponse, status: :unauthorized
    end

    client = OAuth2::Client.new(ENV['APP_UID'], ENV['SECREPP_APP'], site: ENV['URL'])

    begin
      if user
        token = client.password.get_token(user.email, user.uid)
        @user = User.find_by(email: user.email)
        if @user.active # && @user.mobile_verify
          render json: token, status: :ok
        else
          reponse = { user: nil, message: 'User is not enable' }
          render json: reponse, status: :unauthorized
        end
      end
    rescue OAuth2::Error => e
      reponse = { user: nil, message: 'La contraseña o el correo es incorrecto', error: e }
      render json: reponse, status: :unauthorized
    end
  end

  def destroy
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    set_flash_message! :notice, :signed_out if signed_out
    yield if block_given?

    # respond_to_on_destroy
    render json: 'logout ok'
  end

  def respond_to_on_destroy
    # We actually need to hardcode this as Rails default responder doesn't
    # support returning empty response on GET request
    respond_to do |format|
      format.all { head :no_content }
      format.any(*navigational_formats) { redirect_to after_sign_out_path_for(resource_name) }
    end
  end
end
