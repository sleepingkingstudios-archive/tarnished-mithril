class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |table|
      table.string :username
      table.string :password_digest
      
      table.datetime :created_at, :null => false
      table.datetime :updated_at, :null => false
    end # create_table
  end # method change
end # migration
