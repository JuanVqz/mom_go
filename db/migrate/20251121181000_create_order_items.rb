class CreateOrderItems < ActiveRecord::Migration[8.0]
  def change
    create_table :order_items do |t|
      t.references :shop, null: false, foreign_key: { on_delete: :restrict }
      t.references :order, null: false, foreign_key: { on_delete: :restrict }
      t.references :product, null: false, foreign_key: { on_delete: :restrict }
      t.references :product_size, foreign_key: { on_delete: :restrict }
      t.string :product_name, null: false
      t.string :size_name
      t.integer :price_cents, null: false, default: 0
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :order_items, %i[shop_id status]

    add_check_constraint :order_items, "price_cents >= 0", name: "order_items_price_cents_check"
  end
end
