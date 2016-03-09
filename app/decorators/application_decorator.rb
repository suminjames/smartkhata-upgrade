class ApplicationDecorator < Draper::Decorator
  delegate_all

  # Following method influenced by https://gist.github.com/vlasar/5003493
  def self.collection_decorator_class
    PaginatingDecorator
  end

end
