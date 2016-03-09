# The class creation was influenced by https://gist.github.com/vlasar/5003493
class PaginatingDecorator < Draper::CollectionDecorator
  delegate :current_page, :total_pages, :limit_value, :entry_name, :total_count, :offset_value, :last_page?
end

