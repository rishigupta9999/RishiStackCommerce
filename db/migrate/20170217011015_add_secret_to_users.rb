class AddSecretToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :secret, :string
    add_column :users, :token, :string
  end
end
