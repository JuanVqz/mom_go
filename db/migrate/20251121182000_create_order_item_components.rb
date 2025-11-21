class CreateOrderItemComponents < ActiveRecord::Migration[8.0]
  def change
    create_table :order_item_components do |t|
      t.references :shop, null: false, foreign_key: { on_delete: :restrict }
      t.references :order_item, null: false, foreign_key: { on_delete: :restrict }
      t.references :component, foreign_key: { on_delete: :restrict }
      t.string :component_name, null: false
      t.integer :portion, null: false, default: 0
      t.integer :price_cents, null: false, default: 0

      t.timestamps
    end

    add_index :order_item_components, %i[order_item_id component_id], unique: true, name: "index_order_item_components_uniqueness"

    add_check_constraint :order_item_components, "price_cents >= 0", name: "order_item_components_price_cents_check"
  end
end
