# Correctly display the error validation for Bootstrap
# From: https://trevorelwell.me/customize-field-errors-with-rails-5-bootstrap-4/
ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  html = ''

  form_fields = [
    'textarea',
    'input',
    'select'
  ]

  elements = Nokogiri::HTML::DocumentFragment.parse(html_tag).css "label, " + form_fields.join(', ')

  elements.each do |e|
    if e.node_name.eql? 'label'
      html = %(#{e}).html_safe
    elsif form_fields.include? e.node_name
      e['class'] += ' is-invalid'
      html = %(#{e}).html_safe
    end
  end
  html
end
