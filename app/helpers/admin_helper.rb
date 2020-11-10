module AdminHelper
  def back_redirect
    if request.path_parameters[:action] == 'index'
      root_path
    else
      url_for action: 'index', controller: request.path_parameters[:controller]
    end
  end
end
