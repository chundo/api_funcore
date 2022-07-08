class MyModel < ApplicationRecord
  paginates_per 10

  validates :name, :code, :value, uniqueness: true
  validates :name, :code, :value, presence: true

  has_many :parameters, dependent: :destroy
  has_many :permissions, dependent: :destroy

  ## doin before_save and update_save
  before_create :default_values
  def default_values
    self.active ||= false
  end

  def all_models
    ActiveRecord::Base.connection.tables.map do |model|
      puts model.capitalize.singularize.camelize
    end
    puts ActiveRecord::Base.connection.tables.to_json
  end
end
