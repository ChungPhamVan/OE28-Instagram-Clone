class AddUsernameToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :username, :string
    add_column :users, :name, :string
    add_column :users, :website, :string
    add_column :users, :bio, :text
    add_column :users, :phone, :string
    add_column :users, :gender, :integer, default: 2
    add_column :users, :role, :integer, default: 0
    add_column :users, :status, :integer, default: 0
    add_index :users, :email, unique: true
    add_index :users, :username, unique: true
  end
end
