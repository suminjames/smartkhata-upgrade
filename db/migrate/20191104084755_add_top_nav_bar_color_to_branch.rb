class AddTopNavBarColorToBranch < ActiveRecord::Migration
  def change
    add_column :branches, :top_nav_bar_color, :string
  end
end
