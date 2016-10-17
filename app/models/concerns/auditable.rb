module Auditable
  extend ActiveSupport::Concern
  included do
    auditable
  end
end
