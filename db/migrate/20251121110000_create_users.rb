class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.references :shop, null: false, foreign_key: { on_delete: :restrict }
      t.string :email, null: false
      t.string :name, null: false

      t.timestamps
    end

    add_index :users, %i[shop_id email], unique: true
  end
end
