class AppController < ActionController::API
  # protect_from_forgery with: :null_session
  before_action :doorkeeper_authorize!, if: -> { validate_is_public }
  before_action :set_user_public, if: -> { validate_is_public }

  around_action :switch_locale
  def switch_locale(&action)
    locale = params[:locale] || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  def count(page, model, active)
    @model = if active
               model.to_s.constantize.where(active: true)
             else
               model.to_s.constantize.all
             end

    count = @model.count || 0
    limit_value = @model.page(page).limit_value || 0
    total_pages = @model.page(page).total_pages || 0
    current_page = @model.page(page).current_page || 0
    next_page = @model.page(page).next_page || 0
    prev_page = @model.page(page).prev_page || 0
    first_page = @model.page(page).first_page?
    last_page = @model.page(page).last_page?
    out_of_range = @model.page(page).out_of_range?

    response = {
      model: model,
      count: count,
      limit_value: limit_value, total_pages: total_pages,
      current_page: current_page, next_page: next_page,
      prev_page: prev_page, first_page: first_page,
      last_page: last_page, out_of_range: out_of_range
    }
  end

  def count_serach(page, model, response_model)
    @model = response_model
    count = @model.count || 0
    limit_value = @model.page(page).limit_value || 0
    total_pages = @model.page(page).total_pages || 0
    current_page = @model.page(page).current_page || 0
    next_page = @model.page(page).next_page || 0
    prev_page = @model.page(page).prev_page || 0
    first_page = @model.page(page).first_page?
    last_page =  @model.page(page).last_page?
    out_of_range = @model.page(page).out_of_range?

    response = {
      model: model,
      count: count,
      limit_value: limit_value, total_pages: total_pages,
      current_page: current_page, next_page: next_page,
      prev_page: prev_page, first_page: first_page,
      last_page: last_page, out_of_range: out_of_range
    }
  end

  # verify for main
  def validate_is_public
    return if is_public

    true
  end

  def is_public
    public = false
    my_model = MyModel.includes(:permissions).find_by(value: controller_name)
    if my_model
      permissions_user = my_model.permissions.includes(:my_model).where(active: true, action: action_name)
    elsif action_name
      permissions_user = Permission.includes(:my_model).where(active: true, action: action_name)
    else
      permissions_user ||= Permission.includes(:my_model).where(active: true)
    end

    permissions_user.each do |permission|
      next unless permission.public

      public = validation_permissions(permission)
      break if public
    end

    unless public
      @user = User.includes(:roles, :user_roles, :profile).find(doorkeeper_token.resource_owner_id) if doorkeeper_token
      public = permissions_public(@user)
    end

    public
  end

  def permissions_public(user)
    @user = user
    has_permission = false
    has_permission = false
    if @user
      @user.roles.includes(permissions: { role: [:user_roles] }).where(active: true).each do |role|
        next if role.permissions.includes(:roles).where(active: true).empty?

        role.permissions.includes({ role: [:user_roles] }).where(active: true).each do |permission|
          if permission.role.user_roles.where(user_id: @user.id, active: true).count.positive?
            if !permission.is_expired
              has_permission = validation_permissions(permission)

              break if has_permission
            else
              has_expired = false
              case permission.expired_type
              when 'date'
                if permission.expired_value.to_datetime.after?(DateTime.now)
                  has_permission = validation_permissions(permission)

                  break if has_permission
                else
                  has_expired = true
                end
              when 'petitions'
                if permission.expired_value.to_i >= 1
                  has_permission = validation_permissions(permission)

                  break if has_permission
                else
                  has_expired = true
                end
              end

              permission.update(active: false) if has_expired
            end
          end
        end
      end
      has_permission = true if !has_permission && is_super
    else
      permissions = Permission.includes(:my_model).where(active: true, public: true)
      permissions.each do |permission|
        if !permission.is_expired
          has_permission = validation_permissions(permission)

        else
          has_expired = false
          case permission.expired_type
          when 'date'
            if permission.expired_value.to_datetime.after?(DateTime.now)
              has_permission = validation_permissions(permission)
            else
              has_expired = true
            end
          when 'petitions'
            if permission.expired_value.to_i >= 1
              # permission.update(expired_value: permission.expired_value.to_i - 1)
              has_permission = validation_permissions(permission)
            else
              has_expired = true
            end
          end

          permission.update(active: false) if has_expired
        end
      end
    end

    if has_permission
      true
    else
      false
    end
  end

  def set_user_public
    @user = User.includes(:roles, :user_roles, :profile).find(doorkeeper_token.resource_owner_id) if doorkeeper_token

    if permissions_public || permissions_public(@user)
      permissions
    else
      response = { response: 'Does not have permissions 2', status: 422 }
      render json: response, status: :unprocessable_entity
    end
  end

  def set_user
    @user = User.includes(:roles, :user_roles, :profile).find(doorkeeper_token.resource_owner_id) if doorkeeper_token
    permissions
  end

  # verify for user
  def permissions
    has_permission = false
    if @user
      @user.roles.where(active: true).each do |role|
        next if role.permissions.where(active: true).empty?

        role.permissions.includes(:role, :my_model).where(active: true).each do |permission|
          if permission.role.user_roles.where(user_id: @user.id, active: true).count.positive?
            if !permission.is_expired
              has_permission = validation_permissions(permission)
              break if has_permission
            else
              has_expired = false
              case permission.expired_type
              when 'date'
                if permission.expired_value.to_datetime.after?(DateTime.now)
                  has_permission = validation_permissions(permission)
                  break if has_permission
                else
                  has_expired = true
                end
              when 'petitions'
                if permission.expired_value.to_i >= 1
                  permission.update(expired_value: permission.expired_value.to_i - 1)
                  has_permission = validation_permissions(permission)
                  break if has_permission
                else
                  has_expired = true
                end
              end

              permission.update(active: false) if has_expired
            end
          end
        end
      end

      has_permission = true if !has_permission && is_super
    else
      has_permission = false

      permissions = Permission.includes(:my_model, :roles).where(active: true, public: true)
      permissions.each do |permission|
        if !permission.is_expired
          has_permission = validation_permissions(permission)

          break if has_permission
        else
          has_expired = false
          case permission.expired_type
          when 'date'
            if permission.expired_value.to_datetime.after?(DateTime.now)
              has_permission = validation_permissions(permission)

              break if has_permission
            else
              has_expired = true
            end
          when 'petitions'
            if permission.expired_value.to_i >= 1
              permission.update(expired_value: permission.expired_value.to_i - 1)
              has_permission = validation_permissions(permission)
            else
              has_expired = true
            end
          end

          permission.update(active: false) if has_expired
        end
      end
    end

    not_expire if @user.user_roles.where(is_expired: true, active: true).count.positive?

    if has_permission
      true
    else
      response = { response: 'Does not have permissions 1', status: 422 }
      render json: response, status: :unprocessable_entity
    end
  end

  def is_super
    @if_super = (User.is_super?(@user) if @user) || false
  end

  def validation_permissions(permission)
    has_permission = false
    if (permission.my_model.value.eql?(controller_name) && permission.active) && (permission.action.eql?('all') && permission.method.eql?(request.request_method))
      has_permission = true
    elsif (permission.my_model.value.eql?(controller_name) && permission.active) && permission.allow
      has_permission = true
    elsif (permission.my_model.value.eql?(controller_name) && permission.active) && (permission.action.eql?(action_name) && permission.method.eql?(request.request_method))
      has_permission = true
    end
    has_permission
  end

  def not_expire
    current_model = MyModel.find_by(value: controller_name, active: true)
    current_permission = Permission.where(my_model_id: current_model.id, active: true)

    has_permission = false
    has_expired = false
    current_permission.each do |permision|
      role = UserRole.find_by(role_id: permision.role_id, user_id: @user.id, active: true, is_expired: true)

      next unless role

      has_expired = false
      case role.expired_type
      when 'date'
        if role.expired_value.to_datetime.after?(DateTime.now)
          # has_permission = true
        else
          role.update(active: false)
          has_permission = false
          has_expired = true
        end
      when 'petitions'
        if role.expired_value.to_i >= 1
          role.update(expired_value: role.expired_value.to_i - 1)
          # has_permission = true
        else
          role.update(active: false)
          has_permission = false
          has_expired = true
        end
      end
    end

    # has_permission
    has_expired
  end
end
