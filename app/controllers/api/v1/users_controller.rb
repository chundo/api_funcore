# frozen_string_literal: true

class Api::V1::UsersController < AppController
  # before_action :authenticate_user!, except: %i[login]
  # before_action :doorkeeper_authorize!, except: %i[login]
  before_action :set_user # , except: %i[login]

  def sing_up
    user = { **user_params, uuid: User.generate_code(1, 9), verified_account: true }
    @user = User.new(user)
    if @user.save
      profile(@user)
      responde = { user: @user }
      render json: @user, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def login
    client = OAuth2::Client.new(ENV['APP_UID'], ENV['SECREPP_APP'], site: ENV['URL'])

    begin
      token = client.password.get_token(params['user']['email'], params['user']['password'])
      @user = User.find_by(email: params['user']['email'])
      if @user.active && @user.verified_account
        render json: token, status: :ok
      else
        reponse = { user: nil, message: 'Usuario no activado o verificado' }
        render json: reponse, status: :unauthorized
      end
    rescue OAuth2::Error => e
      reponse = { user: nil, message: 'La contraseña o el correo es incorrecto' }
      render json: reponse, status: :unauthorized
    end
  end

  def me
    profile = {
      id: @user.profile.id,
      name: @user.profile.name
    }

    # Busco los modelos de los roles
    models = []
    @user.user_roles.each do |role|
      role.role.permissions.each do |model|
        models << model.my_model
      end
    end

    @models = MyModel.where(id: models.uniq.pluck(:id))

    responde = { user: @user, profile: profile, roles: @user.roles.where(active: true),
                 user_roles: @user.user_roles, models: @models }
    render json: responde, status: :created
  end

  def find_users
    if params['user']
      @user = User.where('username LIKE ? OR email LIKE ? OR phone LIKE ? OR referal_code LIKE ?',
                         "%#{params['user']}", "%#{params['user']}%", "%#{params['user']}%", "%#{params['user']}%")
      if @user
        render json: @user
      else
        render json: { user: %(User #{params['user']} no found ) }
      end
    else
      render json: { user: %(user parameter is null) }
    end
  end

  def find_user
    type = params['type']
    user = params['user']
    if user && type
      @user = case params['type']
              when 'username'
                User.find_by(username: user)
              when 'phone'
                User.find_by(phone: user)
              when 'email'
                User.find_by(email: user)
              else
                User.find_by(email: user)
              end

      if @user
        if @user.active
          render json: @user
        else
          render json: { user: %(User #{params['user']} is not active ) }
        end
      else
        render json: { user: %(User #{params['user']} no found ) }
      end
    else
      render json: { user: %(user parameter is null) }
    end
  end

  def magic_link
    @email_link = MagicLink.generate(params[:user][:email])

    if @email_link
      reponse = { messaje: 'Revisa tu email, enviamos un email para ingresar a tu cuenta' }
      # EmailLinkMailer.sing_in_mail(@email_link).deliver_now
      render json: reponse
    else
      reponse = { messaje: 'No existe un usuario con este email' }
      render json: reponse
    end
  end

  def sing_in_link
    email_link = MagicLink.where(token: params[:user][:token], active: true).first
    user = User.find_by(email: params[:user][:email])

    unless email_link
      reponse = { messaje: 'Link inválido o expiró' }
      render json: reponse
    end

    if email_link && user && email_link.expires_at > Time.now
      @user = User.find_by(email: email_link.user.email)
      client = OAuth2::Client.new(ENV['APP_UID'], ENV['SECREPP_APP'], site: ENV['URL'])

      begin
        token = client.password.get_token(@user.email, email_link.token)

        email_link.update(active: false)
        if @user.active && @user.verified_account
          render json: token, status: :ok
        else
          reponse = { user: nil, message: 'Usuario no activado o verificado' }
          render json: reponse, status: :unauthorized
        end
      rescue OAuth2::Error => e
        reponse = { user: nil, message: 'El token expito o es invalido', error: e }
        render json: reponse, status: :unauthorized
      end
    else
      false
    end
  end

  def phone_exist
    user = User.find_by(user_phone_params)
    if params[:user][:phone]
      if user && user.phone.eql?(params[:user][:phone])
        user = { phone: true, message: 'exist' }
        render json: user, status: :ok
      else
        user = { phone_number: false, message: 'does not exist' }
        render json: user, status: :found
      end
    else
      user = { phone_number: false, message: 'phone is null' }
      render json: user, status: :found
    end
  end

  def user_verify
    client = OAuth2::Client.new(ENV['APP_UID'], ENV['SECREPP_APP'], site: ENV['URL'])
    user = User.find_by(user_verify_acoun_params)
    user ||= User.find_by(email: params[:user][:email])

    if user
      message = if user.active && user.verified_account
                  'it has already been validated'
                else
                  'user validate'
                end

      begin
        token = client.password.get_token(user.email, user.verify_code)

        user.update(verified_account: true, active: true)
        render json: user = { user: user, message: message, token: token }
      rescue OAuth2::Error => e
        reponse = { user: nil, message: 'error al generar el token' }
        render json: reponse, status: :unauthorized
      end
    else
      user = { user: user, message: 'not found' }
      render json: user, status: :found
    end
  end

  def resend_code
    user = User.find_by(phone: params[:user][:phone])
    user ||= User.find_by(email: params[:user][:email])
    if user
      number_randon = [(0..9)].map(&:to_a).flatten
      verify_code = (0...6).map { number_randon[rand(number_randon.length)] }.join

      user.update(verify_code: verify_code)

      if user.phone.present? && user.phone.eql?(params[:user][:phone])
        user.code_confirmation(user.phone, verify_code)

        user = { phone: true, message: 'code send for phone' }
        render json: user, status: :ok
      elsif user.email.eql?(params[:user][:email])
        ## EmailLinkMailer.sing_up_mail(user).deliver_now
        user = { email: true, message: 'code send for email' }
        render json: user, status: :ok
      end
    else
      user = { phone: false, message: 'does not exist' }
      render json: user, status: :found
    end
  end

  def disable
    @user = User.find(params[:id], active: true)
    if @user
      @user.update(active: false, verify_code: false)
      result = { user: @user.email, menssage: 'User was successfully disable temporarily.' }
      render json: result
    else
      result = { user: @user.email, menssage: 'User is successfully disable temporarily.' }
      render json: result
    end
  end

  def reset_password
    user = User.find_by(email: params[:user][:email])
    if user
      code = user.send_reset_password_instructions
      user.update(verify_code: code)
      result = if params[:user][:method]
                 # user.code_reset_password(user.phone, code)
                 { "message": "Sending code to phone #{code}" }
               else
                 # EmailLinkMailer.reset_password(user).deliver_now
                 { "message": 'Sending url yo email' }
               end
      render json: result
    else
      result = { "message": 'Email is not valid' }
      render json: result, status: :unprocessable_entity
    end
  end

  def new_password
    # Valido email y token para cambiar el password
    user = User.find_by(email: params[:user][:email])
    verify_code = params[:user][:verify_code] # confirmation_token
    new_password = params[:user][:new_password]
    new_password_confirmation = params[:user][:new_password_confirmation]

    if user.verify_code.eql?(verify_code) && new_password.eql?(new_password_confirmation)
      user.update(verify_code: nil) # validar el password
      user = user.reset_password(new_password, new_password_confirmation)
      result = { "message": 'Password update' }
      render json: result
    else
      # reponder con otro codigo de error
      result = { "message": 'The code or password is not correct' }
      render json: result, status: :unprocessable_entity
    end
  end

  def update_password
    if @user.valid_password?(params[:user][:current_password])
      if @user.update(user_password_params)
        # Sign in the user by passing validation in case their password changed
        bypass_sign_in(@user)
        response = {
          user: @user,
          message: 'Password update'
        }
        render json: response, status: :ok
      else
        head(:unprocessable_entity)
      end
    else
      object_instance = {
        user: @user,
        message: 'incorrect current password '
      }
      render json: object_instance, status: :not_modified
    end
  end

  def update_user
    # @user = User.find_by(email: params["user"]["email"]) || User.find_by(phone_number: params["user"]["phone_number"])
    if @user.valid_password?(params[:user][:current_password])
      if @user.update(user_account_params)
        # Sign in the user by passing validation in case their password changed
        bypass_sign_in(@user)
        response = {
          user: @user,
          message: 'account update'
        }
        render json: response, status: :ok
      else
        head(:unprocessable_entity)
      end
    else
      object_instance = {
        user: @user,
        message: 'incorrect current password '
      }
      render json: object_instance, status: :not_modified
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation,
                                 :username, :terms, :active, :phone)
  end

  def profile(user)
    Profile.create(name: params['user']['name'], active: true, user_id: user.id)
  end

  def is_super
    @if_super = (User.is_super?(@user) if @user) || false
  end

  def set_user
    @user = User.includes(:roles, :user_roles, :profile).find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end

  def user_phone_params
    params.require(:user).permit(:phone)
  end

  def user_verify_acoun_params
    params.require(:user).permit(:phone, :verify_code)
  end

  def user_password_params
    # NOTE: Using `strong_parameters` gem
    params.require(:user).permit(:password, :password_confirmation)
  end

  def user_account_params
    # NOTE: Using `strong_parameters` gem
    params.require(:user).permit(:email)
  end

  # Find the user that owns the access token
  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end
