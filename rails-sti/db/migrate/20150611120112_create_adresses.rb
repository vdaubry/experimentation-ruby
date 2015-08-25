class CreateAdresses < ActiveRecord::Migration
  def change
    create_table :adresses do |t|
      t.string :street
      t.string :place
      t.string :country
      t.string :type
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
