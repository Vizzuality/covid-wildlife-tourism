module PinsHelper
  # @param type String
  def action?(type)
    case type
    when 'creating'
      @pin.id.nil?
    when 'editing'
      !@pin.id.nil? && (@pin.created_by_id == current_user.id || current_user.admin?)
    when 'fixing'
      !@pin.id.nil? && @pin.created_by_id != current_user.id && !current_user.admin?
    else
      false
    end
  end

  def pin_status(state)
    case state
    when 'live'
      t('views.map.pin_approved')
    when 'waiting_approval'
      t('views.map.pin_pending')
    when 'to_replace'
      t('views.map.pin_pending_changes')
    else
      t('views.map.pin_approved')
    end
  end
end
