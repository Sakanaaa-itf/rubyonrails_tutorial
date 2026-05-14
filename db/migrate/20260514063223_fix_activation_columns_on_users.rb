class FixActivationColumnsOnUsers < ActiveRecord::Migration[7.0]
  def change
    rename_column :users, :activated_ad, :activated_at
    change_column :users, :activated, :boolean, default: false
  end
end
