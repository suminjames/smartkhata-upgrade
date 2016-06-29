json.array!(@menu_permissions) do |menu_permission|
  json.extract! menu_permission, :id, :menu_item_id, :user, :references
  json.url menu_permission_url(menu_permission, format: :json)
end
