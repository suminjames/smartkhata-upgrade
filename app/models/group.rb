# == Schema Information
#
# Table name: groups
#
#  id                :integer          not null, primary key
#  name              :string
#  parent_id         :integer
#  report            :integer
#  sub_report        :integer
#  for_trial_balance :boolean          default(FALSE)
#  creator_id        :integer
#  updater_id        :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Group < ActiveRecord::Base
  include Auditable

  include ::Models::Updater
  include FiscalYearModule

  belongs_to :parent, :class_name => 'Group'
  has_many :children, :class_name => 'Group', :foreign_key => 'parent_id'
  has_many :ledgers

  enum reports: ["PNL", "Balance"]
  enum sub_reports: ["Income", "Expense", "Assets", "Liabilities"]

  scope :top_level, -> {
    where(:parent_id => nil)
  }
  scope :trial_balance, -> { where(:for_trial_balance => true) }

  scope :balance_sheet, -> {
    where(:parent_id => nil, :report => reports['Balance'])
  }
  scope :pnl, -> {
    where(:report => reports['PNL'])
  }

  # TODO add some uniqueness other than name
  validates :name, uniqueness: true
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

  def closing_balance_bad
    self.descendent_ledgers_bad.sum(&:closing_balance)
  end


  # get the ledger and groups based on level selected
  # level 1 which is default will return only the balance
  def get_ledger_group(attrs = {})
    level = attrs[:drill_level] || 1
    fy_code = attrs[:fy_code]
    branch_id = attrs[:branch_id]
    group_ledger = Hash.new
    child_group = Hash.new
    group_ledger[:balance] = self.closing_balance(fy_code,branch_id)
    group_ledger[:ledgers] = []

    # dont load all the clients
    # as client list is too scary can go up too 5k+
    if level > 1 && self.name != 'Clients'
      group_ledger[:ledgers] = self.ledgers
      self.children.each do |child|
        child_group[child.name] = child.get_ledger_group(drill_level: level-1, fy_code: fy_code)
      end
    end
    group_ledger[:child_group] = child_group
    return group_ledger
  end

  # get all the descendents and their balances

  def descendents
    self_and_descendents - [self]
  end

  def self_and_descendents
    self.class.tree_for(self)
  end

  def descendent_ledgers(fy_code = get_fy_code)
    subtree = self.class.tree_sql_for(self)
    Ledger.where("group_id IN (#{subtree})").order(name: :asc)
  end

  def closing_balance(fy_code,branch_id)
    # self.descendent_ledgers(fy_code).to_a.sum(&:closing_balance)
    self.descendent_ledgers.inject(0) { |sum, p| sum + p.closing_balance(fy_code, branch_id) }
  end

  def self.tree_for(instance)
    where("#{table_name}.id IN (#{tree_sql_for(instance)})").order("#{table_name}.id")
  end

  def self.tree_sql_for(instance)
    tree_sql = <<-SQL
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
