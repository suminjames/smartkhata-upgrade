class BaseService
  attr_reader :error

  def call
    raise NotImplementedError
  end

  def success?
    error.present?
  end

  # class Error
  #   attr_reader :message
  #   def initialize(message)
  #     @message = message
  #   end
  # end

  private

  def set_error message
    @error = message
  end
end
