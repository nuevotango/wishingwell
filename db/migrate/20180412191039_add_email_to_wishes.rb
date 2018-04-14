class AddEmailToWishes < ActiveRecord::Migration[5.1]
  def change
    add_column :wishes, :email, :string
  end
end
