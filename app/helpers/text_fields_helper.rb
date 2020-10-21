module TextFieldsHelper
  def text_field_options(value = nil)
    text_field_hash = {
        placeholder: 'YYYY-MM-DD',
        class: 'form-control nepali-datepicker',
        autocomplete: "off"
    }
    text_field_hash[:value] = value if value.present?
    text_field_hash
  end

  def datepicker_input(f, input_name, label: "", is_input: false, value: nil)
    content_tag(:div, class: "date-input-wrapper") do
      if is_input
        f.input input_name.to_sym, label: label, input_html: text_field_options
      else
        f.text_field(input_name.to_sym, text_field_options(value)) + content_tag(:span, "&times".html_safe, class: "clear-date")
      end
    end
  end
end
