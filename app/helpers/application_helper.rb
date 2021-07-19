module ApplicationHelper
  def set_bg_color
    routes_bg_green = [user_session_path,
                       new_user_registration_path,
                       new_user_password_path,
                       edit_user_registration_path,
                       '/users',
                       '/users/sign_in.turbo_stream']

    if routes_bg_green.include? request.env['PATH_INFO']
      'bg-ic-green'
    else 
      'bg-secondary-light'
    end
  end

  def current_user_points
    owned_arrows = current_user.owned_arrows.count * 20
    authored_arrows = current_user.authored_arrows.count * 5

    owned_arrows + authored_arrows
  end
end
