class CreateCatalogJoinTables < ActiveRecord::Migration[8.0]
  def change
    create_table :product_categories do |t|
      t.references :shop, null: false, foreign_key: { on_delete: :restrict }
      t.references :product, null: false, foreign_key: { on_delete: :restrict }
      t.references :category, null: false, foreign_key: { on_delete: :restrict }

      t.timestamps
    end

    add_index :product_categories, %i[shop_id product_id category_id], unique: true, name: "index_product_categories_uniqueness"

    create_table :product_sizes do |t|
      t.references :shop, null: false, foreign_key: { on_delete: :restrict }
      t.references :product, null: false, foreign_key: { on_delete: :restrict }
      t.references :size, null: false, foreign_key: { on_delete: :restrict }
      t.integer :price_cents, null: false, default: 0

      t.timestamps
    end

    add_index :product_sizes, %i[shop_id product_id size_id], unique: true, name: "index_product_sizes_uniqueness"
    add_check_constraint :product_sizes, "price_cents >= 0", name: "product_sizes_price_cents_check"

    create_table :product_components do |t|
      t.references :shop, null: false, foreign_key: { on_delete: :restrict }
      t.references :product, null: false, foreign_key: { on_delete: :restrict }
      t.references :component, null: false, foreign_key: { on_delete: :restrict }
      t.integer :price_cents, null: false, default: 0
      t.boolean :required, null: false, default: false
      t.integer :default_portion, null: false, default: 0
      t.integer :role, null: false, default: 0

      t.timestamps
    end

    add_index :product_components, %i[shop_id product_id component_id], unique: true, name: "index_product_components_uniqueness"
    add_check_constraint :product_components, "price_cents >= 0", name: "product_components_price_cents_check"
    add_check_constraint :product_components, "default_portion IN (0,1,2,3,4)", name: "product_components_default_portion_check"
    add_check_constraint :product_components, "role IN (0,1)", name: "product_components_role_check"
  end
end
