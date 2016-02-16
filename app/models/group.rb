class Group < ActiveRecord::Base
	belongs_to :parent, :class_name => 'Group'
  has_many :children, :class_name => 'Group', :foreign_key => 'parent_id'
  has_many :ledgers

  enum reports: [ "PNL", "Balance"]
  enum sub_reports: [ "Income", "Expense", "Assets", "Liabilities"]

  scope :top_level, -> {
  	where(:parent_id => nil)
	}

	scope :balance_sheet, -> {
		where(:parent_id => nil, :report => reports['Balance'])
	}
  scope :pnl, -> {
    where(:report => reports['PNL'])
  }
	# not so good approach
	# kept for performance test later on
  def descendents_bad
    children.map do |child|
      [child] + child.descendents_bad
    end.flatten
  end

  def self_and_descendents_bad
    [self] + descendents_bad
  end

  def descendent_ledgers_bad
    self_and_descendents_bad.map(&:ledgers).flatten
  end

  def closing_blnc_bad
  	self.descendent_ledgers_bad.sum(&:closing_blnc)
  end



  # get all the descendents and their balances

  def descendents
    self_and_descendents - [self]
  end

  def self_and_descendents
    self.class.tree_for(self)
  end

  def descendent_ledgers
    subtree = self.class.tree_sql_for(self)
    Ledger.where("group_id IN (#{subtree})")
  end

  def closing_blnc
  	self.descendent_ledgers.sum(:closing_blnc)
  end

  def self.tree_for(instance)
    where("#{table_name}.id IN (#{tree_sql_for(instance)})").order("#{table_name}.id")
  end

  def self.tree_sql_for(instance)
    tree_sql =  <<-SQL
      WITH RECURSIVE search_tree(id, path) AS (
          SELECT id, ARRAY[id]
          FROM #{table_name}
          WHERE id = #{instance.id}
        UNION ALL
          SELECT #{table_name}.id, path || #{table_name}.id
          FROM search_tree
          JOIN #{table_name} ON #{table_name}.parent_id = search_tree.id
          WHERE NOT #{table_name}.id = ANY(path)
      )
      SELECT id FROM search_tree ORDER BY path
    SQL
  end



end
