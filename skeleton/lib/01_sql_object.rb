require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    @columns? @columns :
    @columns = DBConnection.execute2(<<-SQL).first.map{|entry| entry.to_sym}
  SELECT
    *
  FROM
    cats
SQL
  end

  def self.finalize!
    columns.each do |column|
      define_method("#{column}") do
        attributes[column]
      end
      define_method("#{column}=") do |arg|
        attributes[column] = arg
      end
    end
  end

  def self.table_name=(table_name)

    @table_name = table_name
  end

  def self.table_name

    @table_name? @table_name : self.to_s.tableize
  end

  def self.all
    parse_all(DBConnection.execute(<<-SQL))
      SELECT
        *
      FROM
        cats
    SQL

  end

  def self.parse_all(results)
    results.map{|entry| self.new(entry)}
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id).first
      SELECT
        *
      FROM
        cats
      WHERE
        id = ?
    SQL
    return nil if result.nil?
    self.new(result)
  end

  def initialize(params = {})
    params.each do |k,v|
      raise "unknown attribute '#{k}'" unless self.class.columns.include?(k.to_sym)
      self.send("#{k}=",v)
    end

  end

  def attributes
    @attributes? @attributes : @attributes = {}

  end

  def attribute_values
    self.attributes.values
  end

  def insert
    col = self.class.columns[1..-1].join(",")

    ques = (["?"]*(self.class.columns.length-1)).join(',')
    DBConnection.execute(<<-SQL,*attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col})
      VALUES
        (#{ques})
    SQL
    attributes[self.class.columns.first] = DBConnection.last_insert_row_id
  end

  def update
    id = self.class.columns.first
    rest = (self.class.columns[1..-1].map {|att| "#{att} = ?"}).join(',')

    DBConnection.execute(<<-SQL,#{rest},id)
      UPDATE
        #{self.class.table_name}
      SET

      WHERE
        id = ?
    SQL
  end

  def save
    # ...
  end
end
