class MagicLink < ApplicationRecord
  belongs_to :user
  #after_create :send_email

  def self.generate(email)
    user = User.find_by(email: email)
    return nil if !user

    create(user: user, expires_at: Date.today + 1.day, token: generate_token, active: true)
  end

  def self.generate_token
    Devise.friendly_token.first(16)
  end

  private
   def send_email
    # EmailLinkMailer.sing_in_mail(self).deliver_now
   end
end
