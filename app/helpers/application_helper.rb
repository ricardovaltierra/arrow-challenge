module ApplicationHelper
  def set_bg_color
    routes_bg_green = [user_session_path,
                       new_user_registration_path,
                       new_user_password_path,
                       '/users/sign_in.turbo_stream']

    if routes_bg_green.include? request.env['PATH_INFO']
      'bg-ic-green'
    else 
      'bg-secondary-light'
    end
  end
end
