class CreateShops < ActiveRecord::Migration[8.0]
  def change
    create_table :shops do |t|
      t.string :name, null: false
      t.string :subdomain, null: false
      t.text :description

      t.timestamps
    end

    add_index :shops, :subdomain, unique: true
  end
end
