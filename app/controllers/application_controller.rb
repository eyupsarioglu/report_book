class ApplicationController < ActionController::Base
  protect_from_forgery
  def after_sign_in_path_for(resource)
    session[:user] = current_user
    if current_user.role == "admin"
      user_index_path
    else
      probations_path
    end
  end

  def after_sign_up_path_for(resource)
    probations_path
  end

  def after_sign_out_path_for(resource_or_scope)
    session[:user] = nil
    home_index_path
  end
end
