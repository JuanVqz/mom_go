class CreateCatalogBaseTables < ActiveRecord::Migration[8.0]
  def change
    create_table :categories do |t|
      t.references :shop, null: false, foreign_key: { on_delete: :restrict }
      t.string :name, null: false
      t.string :slug, null: false
      t.integer :position, null: false, default: 0
      t.boolean :available, null: false, default: true

      t.timestamps
    end

    add_index :categories, %i[shop_id slug], unique: true
    add_index :categories, %i[shop_id position]

    create_table :products do |t|
      t.references :shop, null: false, foreign_key: { on_delete: :restrict }
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.integer :position, null: false, default: 0
      t.boolean :available, null: false, default: true
      t.integer :base_price_cents, null: false, default: 0

      t.timestamps
    end

    add_index :products, %i[shop_id slug], unique: true
    add_index :products, %i[shop_id position]
    add_check_constraint :products, "base_price_cents >= 0", name: "products_base_price_cents_check"

    create_table :sizes do |t|
      t.references :shop, null: false, foreign_key: { on_delete: :restrict }
      t.string :name, null: false
      t.string :slug, null: false
      t.integer :position, null: false, default: 0
      t.boolean :available, null: false, default: true
      t.integer :price_cents, null: false, default: 0

      t.timestamps
    end

    add_index :sizes, %i[shop_id slug], unique: true
    add_index :sizes, %i[shop_id position]
    add_check_constraint :sizes, "price_cents >= 0", name: "sizes_price_cents_check"

    create_table :components do |t|
      t.references :shop, null: false, foreign_key: { on_delete: :restrict }
      t.string :name, null: false
      t.string :slug, null: false
      t.integer :position, null: false, default: 0
      t.boolean :active, null: false, default: true
      t.integer :price_cents, null: false, default: 0

      t.timestamps
    end

    add_index :components, %i[shop_id slug], unique: true
    add_index :components, %i[shop_id position]
    add_check_constraint :components, "price_cents >= 0", name: "components_price_cents_check"
  end
end
