class ApplicationController < ActionController::Base
  # before_action :doorkeeper_authorize!, except: %i[]
  # before_action :set_user, except: %i[]
  protect_from_forgery with: :null_session

  def set_user
    @user = User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
    permissions
  end

  def permissions
    has_permission = false
    if @user
      @user.roles.where(active: true).each do |role|
        next if role.permissions.where(active: true).empty?

        role.permissions.where(active: true).each do |permission|
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

      has_permission = true if is_super
    else
      has_permission = false

      permissions = Permission.where(active: true, public: true)
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

  def is_super
    @if_super = (User.is_super?(@user) if @user) || false
  end
end
