class Permission < ApplicationRecord
  paginates_per 10

  belongs_to :role
  belongs_to :my_model
  belongs_to :user

  validates :user_id, :my_model_id, :role_id, :action, :method, :expired_type,
            :expired_value, presence: true
  validates :role_id, uniqueness: { scope: %i[my_model_id action] }

  enum expired_type: { date: 'date', petitions: 'petitions' }
  enum method: { GET: 'GET', POST: 'POST', PATCH: 'PATCH', PUT: 'PUT', DELETE: 'DELETE' }
  # enum action: :actions_list

  before_create :default_values
  def default_values
    self.active ||= false
    self.allow ||= false
    self.public ||= false
    self.is_expired ||= false
  end

  # after_initialize :list
  def list
    constoller_list = []
    actions_list = []
    Rails.application.eager_load!
    AppController.descendants.each do |controller|
      constoller_list.push(controller)
      controller.action_methods.each do |action|
        actions_list.push(action)
      end
    end
    puts actions_list
  end
end
