class Role < ApplicationRecord
  paginates_per 10

  ## validation inputs
  validates :name, :code, uniqueness: true
  validates :name, :code, presence: true

  # References
  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles, dependent: :destroy
  has_many :permissions

  scope :active, -> { where(active: true) }

  ## doin before_save and update_save
  before_create :default_values
  before_update :default_values
  def default_values
    self.active ||= false
    self.default ||= false
    self.name = name.capitalize.delete(' ')
    self.code = code.upcase.delete(' ')
    # validate_default
  end

  def validate_default
    Role.where(default: true).each do |role|
      role.update(default: false)
      puts role.to_json
    end
  end
end
