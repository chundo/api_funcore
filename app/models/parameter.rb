class Parameter < ApplicationRecord
  paginates_per 10

  belongs_to :user
  belongs_to :my_model

  validates :name, :code, :value, uniqueness: true
  validates :name, :code, :value, :is_public, presence: true

  ## doin before_save and update_save
  before_save :default_values
  before_create :default_values
  before_update :default_values
  def default_values
    self.active ||= false
    self.is_public ||= false
  end
end
