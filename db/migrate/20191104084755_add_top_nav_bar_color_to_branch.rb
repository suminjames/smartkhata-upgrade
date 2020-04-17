class AddTopNavBarColorToBranch < ActiveRecord::Migration[4.2]
  def change
    add_column :branches, :top_nav_bar_color, :string
  end
end
