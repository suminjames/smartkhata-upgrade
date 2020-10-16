class BaseServiceOld
  include Virtus.model
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_reader :errors
  attr_reader :has_error

  def initialize(attributes = {})
    super attributes
    @errors = ActiveModel::Errors.new(self)
  end

  def persisted?
    false
  end

  private

  def has_error?
    self.errors.size.positive?
  end

  def set_errors(*models)
    models.compact.each do |mod|
      mod.errors.each do |k, v|
        if self.respond_to?(k)
          self.errors[k] << v
        else
          self.errors[:base] << v
        end
      end
    end
  end

  # Returns true if calls
  def commit_or_rollback
    res = true
    ActiveRecord::Base.transaction do
      res = yield
      raise ActiveRecord::Rollback unless res
    end

    res
  end
end
