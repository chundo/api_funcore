class User < ApplicationRecord
  paginates_per 10

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: %i[facebook github]

  has_many :access_grants,
           class_name: 'Doorkeeper::AccessGrant',
           foreign_key: :resource_owner_id,
           dependent: :delete_all # or :destroy if you need callbacks

  has_many :access_tokens,
           class_name: 'Doorkeeper::AccessToken',
           foreign_key: :resource_owner_id,
           dependent: :delete_all # or :destroy if you need callbacks

  ## validation inputs
  validates :username, :phone, :uuid, uniqueness: true
  validates :username, :phone, :uuid, presence: true
  validates :verified_account, :active, :terms, presence: true
  ## ping referral_code uuid

  # References
  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles, dependent: :destroy
  has_many :parameters, dependent: :destroy
  has_one :profile, dependent: :destroy
  has_many :magic_links, dependent: :destroy

  enum user_type: { client: 'client', user: 'user', customer: 'customer', admin: 'admin' }

  def self.from_omniauth(auth)
    current_user = where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      case auth.provider
      when 'facebook'
        user.username = auth.info.name.delete(' ')
        user.email = auth.info.email
      when 'twitter'
        user.username = auth.info.nickname
        user.email = %(#{auth.info.nickname}@twitter.com)
      when 'google_oauth2'
        user.username = auth.info.name.delete(' ')
        user.email = auth.info.email
      else
        user.email = auth.info.email
        user.password = auth.uid || Devise.friendly_token[0, 20]
        user.username = auth.info.nickname # assuming the user model has a name
        # user.skip_confirmation!
      end
      user.phone = auth.info.email
      user.uuid = auth.uid
      user.active = true
      self.user_type = 'user'
      user.terms = true
      user.verified_account = true
      user.pin ||= generate_code(1, 9)
      user.referal_code ||= generate_code(1, 9)

      user.password = auth.uid || Devise.friendly_token[0, 20]
      user.save!
      user
    end

    role = Role.find_by(default: true)
    UserRole.where(user_id: current_user.id, role_id: role.id).first_or_create do |user_role|
      user_role.user_id = current_user.id
      user_role.role_id = role.id
      user_role.active = true
      user_role.admin_id = nil
      user_role.is_expired = false
      user_role.expired_type =  'date'
      user_role.expired_value = Time.now.strftime('%d/%m/%Y').to_s
      user_role.save!
    end

    Profile.where(user_id: current_user.id).first_or_create do |profile|
      profile.user_id = current_user.id
      profile.name = auth.info.name
      profile.active = true
      profile.save!
    end

    current_user
  end

  ## doin before_save and update_save
  before_save :default_values
  # before_create :default_values
  # before_update :default_values
  def default_values
    code_randon = [('A'..'Z'), (0..9)].map(&:to_a).flatten
    code = (2...9).map { code_randon[rand(code_randon.length)] }.join
    self.user_type ||= 'user'
    self.active ||= false
    self.terms ||= false
    self.verified_account ||= false
    self.pin ||= code
    self.referal_code ||= generate_code(1, 9)
    self.uid ||= generate_code(1, 9)
    self.uuid ||= generate_code(1, 9)

    # add role
    user_role = Role.find_by(default: true)
    UserRole.create(user_id: self, role_id: user_role.id, active: true, admin_id: nil, is_expired: false,
                    expired_type: 'date', expired_value: '')
  end

  def generate_code(a, b)
    code_randon = [('A'..'Z'), (0..9)].map(&:to_a).flatten
    (a...b).map { code_randon[rand(code_randon.length)] }.join
  end

  def code_confirmation(phone, verify_code)
    # @client = Twilio::REST::Client.new ENV['TWILLIO_ACCOUNT_SID'], ENV['TWILLIO_AUT_TOKEN']
    # @client.api.account.messages.create(from: ENV['TWILLIO_FROM'], to: "+#{phone}", body: "Hola tu codigo de verificacion es: #{verify_code}")
    # rescue Twilio::REST::RestError => e
    # twillio_error(true)
  end

  def code_reset_password(phone, verify_code)
    # @client = Twilio::REST::Client.new ENV['TWILLIO_ACCOUNT_SID'], ENV['TWILLIO_AUT_TOKEN']
    # @client.api.account.messages.create(from: ENV['TWILLIO_FROM'], to: "+#{phone}", body: "Hola tu codigo para recuperar la contraseña es: #{verify_code}")
    # rescue Twilio::REST::RestError => e
    # twillio_error(true)
  end

  def self.is_super?(user)
    state = false
    user.roles.where(active: true).each do |role|
      next unless role.code.eql?(ENV['SUPER_ROLE'])

      state = true if user.user_roles.find_by(role_id: role.id, active: true)
    end
    state
  end
end
