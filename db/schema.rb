# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_11_21_173644) do
  create_table "categories", force: :cascade do |t|
    t.integer "shop_id", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.integer "position", default: 0, null: false
    t.boolean "available", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shop_id", "position"], name: "index_categories_on_shop_id_and_position"
    t.index ["shop_id", "slug"], name: "index_categories_on_shop_id_and_slug", unique: true
    t.index ["shop_id"], name: "index_categories_on_shop_id"
  end

  create_table "components", force: :cascade do |t|
    t.integer "shop_id", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.integer "position", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.integer "price_cents", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shop_id", "position"], name: "index_components_on_shop_id_and_position"
    t.index ["shop_id", "slug"], name: "index_components_on_shop_id_and_slug", unique: true
    t.index ["shop_id"], name: "index_components_on_shop_id"
  end

  create_table "product_categories", force: :cascade do |t|
    t.integer "shop_id", null: false
    t.integer "product_id", null: false
    t.integer "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_product_categories_on_category_id"
    t.index ["product_id"], name: "index_product_categories_on_product_id"
    t.index ["shop_id", "product_id", "category_id"], name: "index_product_categories_uniqueness", unique: true
    t.index ["shop_id"], name: "index_product_categories_on_shop_id"
  end

  create_table "product_components", force: :cascade do |t|
    t.integer "shop_id", null: false
    t.integer "product_id", null: false
    t.integer "component_id", null: false
    t.integer "price_cents", default: 0, null: false
    t.boolean "required", default: false, null: false
    t.integer "default_portion", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["component_id"], name: "index_product_components_on_component_id"
    t.index ["product_id"], name: "index_product_components_on_product_id"
    t.index ["shop_id", "product_id", "component_id"], name: "index_product_components_uniqueness", unique: true
    t.index ["shop_id"], name: "index_product_components_on_shop_id"
  end

  create_table "product_sizes", force: :cascade do |t|
    t.integer "shop_id", null: false
    t.integer "product_id", null: false
    t.integer "size_id", null: false
    t.integer "price_cents", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_product_sizes_on_product_id"
    t.index ["shop_id", "product_id", "size_id"], name: "index_product_sizes_uniqueness", unique: true
    t.index ["shop_id"], name: "index_product_sizes_on_shop_id"
    t.index ["size_id"], name: "index_product_sizes_on_size_id"
  end

  create_table "products", force: :cascade do |t|
    t.integer "shop_id", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.text "description"
    t.integer "position", default: 0, null: false
    t.boolean "available", default: true, null: false
    t.integer "base_price_cents", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shop_id", "position"], name: "index_products_on_shop_id_and_position"
    t.index ["shop_id", "slug"], name: "index_products_on_shop_id_and_slug", unique: true
    t.index ["shop_id"], name: "index_products_on_shop_id"
  end

  create_table "shops", force: :cascade do |t|
    t.string "name", null: false
    t.string "subdomain", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subdomain"], name: "index_shops_on_subdomain", unique: true
  end

  create_table "sizes", force: :cascade do |t|
    t.integer "shop_id", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.integer "position", default: 0, null: false
    t.boolean "available", default: true, null: false
    t.integer "price_cents", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shop_id", "position"], name: "index_sizes_on_shop_id_and_position"
    t.index ["shop_id", "slug"], name: "index_sizes_on_shop_id_and_slug", unique: true
    t.index ["shop_id"], name: "index_sizes_on_shop_id"
  end

  create_table "users", force: :cascade do |t|
    t.integer "shop_id", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shop_id", "email"], name: "index_users_on_shop_id_and_email", unique: true
    t.index ["shop_id"], name: "index_users_on_shop_id"
  end

  add_foreign_key "categories", "shops", on_delete: :restrict
  add_foreign_key "components", "shops", on_delete: :restrict
  add_foreign_key "product_categories", "categories", on_delete: :restrict
  add_foreign_key "product_categories", "products", on_delete: :restrict
  add_foreign_key "product_categories", "shops", on_delete: :restrict
  add_foreign_key "product_components", "components", on_delete: :restrict
  add_foreign_key "product_components", "products", on_delete: :restrict
  add_foreign_key "product_components", "shops", on_delete: :restrict
  add_foreign_key "product_sizes", "products", on_delete: :restrict
  add_foreign_key "product_sizes", "shops", on_delete: :restrict
  add_foreign_key "product_sizes", "sizes", on_delete: :restrict
  add_foreign_key "products", "shops", on_delete: :restrict
  add_foreign_key "sizes", "shops", on_delete: :restrict
  add_foreign_key "users", "shops", on_delete: :restrict
end
