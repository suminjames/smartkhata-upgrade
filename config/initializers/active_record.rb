class ActiveRecord::Base
  # Common regex patterns to use in model validations.
  DATE_REGEX  = /\A\d{4}-(?:0?[1-9]|1[0-2])-(?:0?[1-9]|[1-2]\d|3[01])\Z/
  EMAIL_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  ACCOUNT_NUMBER_REGEX = /\A(?=.*\d)([a-zA-Z0-9]+)\z/


end