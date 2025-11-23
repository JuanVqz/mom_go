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

ActiveRecord::Schema[8.0].define(version: 2025_11_21_182000) do
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
    t.check_constraint "price_cents >= 0", name: "components_price_cents_check"
  end

  create_table "order_item_components", force: :cascade do |t|
    t.integer "shop_id", null: false
    t.integer "order_item_id", null: false
    t.integer "component_id"
    t.string "component_name", null: false
    t.integer "portion", default: 0, null: false
    t.integer "price_cents", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["component_id"], name: "index_order_item_components_on_component_id"
    t.index ["order_item_id"], name: "index_order_item_components_on_order_item_id"
    t.index ["shop_id", "order_item_id", "component_id"], name: "index_order_item_components_uniqueness", unique: true
    t.index ["shop_id"], name: "index_order_item_components_on_shop_id"
    t.check_constraint "portion IN (0,1,2,3,4)", name: "order_item_components_portion_check"
    t.check_constraint "price_cents >= 0", name: "order_item_components_price_cents_check"
  end

  create_table "order_items", force: :cascade do |t|
    t.integer "shop_id", null: false
    t.integer "order_id", null: false
    t.integer "product_id", null: false
    t.integer "product_size_id"
    t.string "product_name", null: false
    t.string "size_name"
    t.integer "price_cents", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
    t.index ["product_size_id"], name: "index_order_items_on_product_size_id"
    t.index ["shop_id", "status"], name: "index_order_items_on_shop_id_and_status"
    t.index ["shop_id"], name: "index_order_items_on_shop_id"
    t.check_constraint "price_cents >= 0", name: "order_items_price_cents_check"
    t.check_constraint "status IN (0,1,2,3,4)", name: "order_items_status_check"
  end

  create_table "orders", force: :cascade do |t|
    t.integer "shop_id", null: false
    t.string "number", null: false
    t.integer "status", default: 0, null: false
    t.string "currency", default: "MXN", null: false
    t.integer "items_total_cents", default: 0, null: false
    t.integer "discount_total_cents", default: 0, null: false
    t.integer "tax_total_cents", default: 0, null: false
    t.integer "total_cents", default: 0, null: false
    t.integer "total_item_count", default: 0, null: false
    t.datetime "ready_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shop_id", "number"], name: "index_orders_on_shop_id_and_number", unique: true
    t.index ["shop_id", "status"], name: "index_orders_on_shop_id_and_status"
    t.index ["shop_id"], name: "index_orders_on_shop_id"
    t.check_constraint "discount_total_cents >= 0", name: "orders_discount_total_cents_check"
    t.check_constraint "items_total_cents >= 0", name: "orders_items_total_cents_check"
    t.check_constraint "status IN (0,1,2,3,4,5)", name: "orders_status_check"
    t.check_constraint "tax_total_cents >= 0", name: "orders_tax_total_cents_check"
    t.check_constraint "total_cents >= 0", name: "orders_total_cents_check"
    t.check_constraint "total_item_count >= 0", name: "orders_total_item_count_check"
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
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["component_id"], name: "index_product_components_on_component_id"
    t.index ["product_id"], name: "index_product_components_on_product_id"
    t.index ["shop_id", "product_id", "component_id"], name: "index_product_components_uniqueness", unique: true
    t.index ["shop_id"], name: "index_product_components_on_shop_id"
    t.check_constraint "default_portion IN (0,1,2,3,4)", name: "product_components_default_portion_check"
    t.check_constraint "price_cents >= 0", name: "product_components_price_cents_check"
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
    t.check_constraint "price_cents >= 0", name: "product_sizes_price_cents_check"
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
    t.check_constraint "base_price_cents >= 0", name: "products_base_price_cents_check"
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
    t.check_constraint "price_cents >= 0", name: "sizes_price_cents_check"
  end

  create_table "users", force: :cascade do |t|
    t.integer "shop_id", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "locked_at"
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, where: "reset_password_token IS NOT NULL"
    t.index ["shop_id", "email"], name: "index_users_on_shop_id_and_email", unique: true
    t.index ["shop_id"], name: "index_users_on_shop_id"
    t.check_constraint "failed_attempts >= 0", name: "users_failed_attempts_non_negative"
    t.check_constraint "length(password_digest) >= 60", name: "users_password_digest_length_check"
  end

  add_foreign_key "categories", "shops", on_delete: :restrict
  add_foreign_key "components", "shops", on_delete: :restrict
  add_foreign_key "order_item_components", "components", on_delete: :restrict
  add_foreign_key "order_item_components", "order_items", on_delete: :restrict
  add_foreign_key "order_item_components", "shops", on_delete: :restrict
  add_foreign_key "order_items", "orders", on_delete: :restrict
  add_foreign_key "order_items", "product_sizes", on_delete: :restrict
  add_foreign_key "order_items", "products", on_delete: :restrict
  add_foreign_key "order_items", "shops", on_delete: :restrict
  add_foreign_key "orders", "shops", on_delete: :restrict
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
