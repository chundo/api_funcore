class UserRole < ApplicationRecord
  paginates_per 10

  belongs_to :role
  belongs_to :user
  belongs_to :admin, class_name: 'User', optional: true

  # scope :active, -> { where(active: true) }
  scope :active, -> { includes(:role).where(active: true) }
  scope :user, ->(user_id) { includes(:role).find(user_id) }

  # enum expired_type: %i[date peticions time datatime]
  enum expired_type: { date: 'date', petitions: 'petitions' }

  ## validation inputs
  validates :user_id, uniqueness: { scope: [:role_id] }
  validates :is_expired,
            uniqueness: { scope: %i[expired_type expired_value] }
  # validates :expired_type, uniqueness: { scope:  %i[expired_value] }
  # validates :active, :is_expired, :expired_type, :expired_value, presence: true

  before_create :default_values
  before_update :default_values
  def default_values
    self.active ||= false
    self.is_expired ||= false
  end
end
