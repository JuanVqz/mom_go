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

    create_table :product_components do |t|
      t.references :shop, null: false, foreign_key: { on_delete: :restrict }
      t.references :product, null: false, foreign_key: { on_delete: :restrict }
      t.references :component, null: false, foreign_key: { on_delete: :restrict }
      t.integer :price_cents, null: false, default: 0
      t.boolean :required, null: false, default: false
      t.integer :default_portion, null: false, default: 0

      t.timestamps
    end

    add_index :product_components, %i[shop_id product_id component_id], unique: true, name: "index_product_components_uniqueness"
  end
end
