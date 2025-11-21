class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.references :shop, null: false, foreign_key: { on_delete: :restrict }
      t.string :number, null: false
      t.integer :status, null: false, default: 0
      t.string :currency, null: false, default: "MXN"
      t.integer :items_total_cents, null: false, default: 0
      t.integer :discount_total_cents, null: false, default: 0
      t.integer :tax_total_cents, null: false, default: 0
      t.integer :total_cents, null: false, default: 0
      t.integer :total_item_count, null: false, default: 0
      t.datetime :ready_at

      t.timestamps
    end

    add_index :orders, %i[shop_id number], unique: true
    add_index :orders, %i[shop_id status]

    add_check_constraint :orders, "items_total_cents >= 0", name: "orders_items_total_cents_check"
    add_check_constraint :orders, "discount_total_cents >= 0", name: "orders_discount_total_cents_check"
    add_check_constraint :orders, "tax_total_cents >= 0", name: "orders_tax_total_cents_check"
    add_check_constraint :orders, "total_cents >= 0", name: "orders_total_cents_check"
    add_check_constraint :orders, "total_item_count >= 0", name: "orders_total_item_count_check"
  end
end
