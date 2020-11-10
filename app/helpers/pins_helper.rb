module PinsHelper
  # @param type String
  def action?(type)
    case type
    when 'creating'
      @pin.id.nil?
    when 'editing'
      @pin.created_by_id == current_user.id || current_user.admin?
    when 'fixing'
      @pin.created_by_id != current_user.id && !current_user.admin?
    else
      false
    end
  end
end
