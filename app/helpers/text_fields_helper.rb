module TextFieldsHelper
  def text_field_options
    text_field_hash = {
        placeholder: 'YYYY-MM-DD',
        class: 'form-control nepali-datepicker',
        autocomplete: "off"
    }
    return text_field_hash
  end
end