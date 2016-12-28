class UserMailer < Devise::Mailer
  include ApplicationHelper
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
  default template_path: 'devise/mailer' # to make sure that your mailer uses the devise views
  layout 'mailer'

  def mailer_sender(mapping, sender = :from)
    default_sender = default_params[sender]
    mailer_url = ActionMailer::Base.default_url_options[:host];

    if mailer_url != Rails.application.secrets.domain_name
      default_sender = mailer_url.sub(".#{Rails.application.secrets.domain_name}", "@#{Rails.application.secrets.domain_name}")

      if default_sender == mailer_url
        # replace the instance of .com.np with the site name
        default_sender = mailer_url.sub(".com.np", "@#{Rails.application.secrets.domain_name}")
      end
    end
    default_sender
  end

end
