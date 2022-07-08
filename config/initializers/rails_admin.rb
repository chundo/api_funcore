RailsAdmin.config do |config|
  config.asset_source = :sprockets

  config.main_app_name = proc { |controller| ['Super ', "admin - #{controller.params[:action].try(:titleize)}"] }

  config.navigation_static_links = {
    'Google' => 'http://www.google.com',
    'Migrate Models' => '/my_models/migrate'
  }

  config.model 'MyModel' do
    navigation_label 'Main Models'
  end

  config.model 'Role' do
    navigation_label 'Main Models'
  end

  config.model 'UserRole' do
    navigation_label 'Main Models'
  end

  config.model 'Permission' do
    navigation_label 'Main Models'
  end

  config.model 'Parameter' do
    navigation_label 'Main Models'
  end

  config.model 'User' do
    navigation_label 'Main Models'
  end

  config.authenticate_with do
    warden.authenticate! scope: :user
  end
  config.current_user_method(&:current_user)

  config.authorize_with do
    if User.is_super?(current_user)
      # if current_user
      true
    else
      redirect_to main_app.root_path
    end
  end

  ### Popular gems integration

  ## == Devise ==
  # config.authenticate_with do
  #   warden.authenticate! scope: :user
  # end
  # config.current_user_method(&:current_user)

  ## == CancanCan ==
  # config.authorize_with :cancancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/railsadminteam/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  # config.show_gravatar = true

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end
end
