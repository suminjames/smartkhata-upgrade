module TextFieldsHelper
  def text_field_options
    text_field_hash = {
        placeholder: 'YYYY-MM-DD',
        class: 'form-control nepali-datepicker',
        autocomplete: "off"
    }
    return text_field_hash
  end

  def datepicker_input(f, input_name, label= "", value= "", simple_form= false)
    content_tag(:div, class: "date-input-wrapper") do
      if simple_form
        f.input input_name.to_sym, label: label, :input_html => text_field_options
      else
        f.text_field(input_name.to_sym, text_field_options.merge(value: value)) + content_tag(:span, "&times".html_safe, class: "clear-date" )
      end
    end
  end
end