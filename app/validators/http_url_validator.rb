class HttpUrlValidator < ActiveModel::EachValidator

  def self.compliant?(value)
    uri = URI.parse(value)
    uri.is_a?(URI::HTTP) && !uri.host.nil?
  rescue URI::InvalidURIError
    false
  end

  def validate_each(record, attribute, value)
    if value.present? && !self.class.compliant?(value)
      record.errors.add(attribute, I18n.t('validators.http_url.not_valid'))
    end
  end

end
