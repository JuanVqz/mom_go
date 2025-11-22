require "test_helper"

class ShopScopedTest < ActiveSupport::TestCase
  class ShopScopedWidget < ApplicationRecord
    self.table_name = "shop_scoped_widgets"
    include ShopScoped
  end

  setup do
    ActiveRecord::Base.connection.create_table(:shop_scoped_widgets, force: true) do |t|
      t.references :shop, null: false, foreign_key: true
      t.string :name, null: false
      t.timestamps
    end

    ShopScopedWidget.reset_column_information
    Current.reset
  end

  teardown do
    ActiveRecord::Base.connection.drop_table(:shop_scoped_widgets, if_exists: true)
    Current.reset
  end

  test "requires a shop" do
    widget = ShopScopedWidget.new(name: "Sample")

    assert_not widget.valid?
    assert_includes widget.errors[:shop], "must exist"
  end

  test "default scope restricts queries to Current.shop" do
    tea = shops(:tea)
    coffee = shops(:coffee)

    Current.shop = tea
    tea_widget = ShopScopedWidget.create!(shop: tea, name: "Tea Widget")

    Current.shop = coffee
    coffee_widget = ShopScopedWidget.create!(shop: coffee, name: "Coffee Widget")

    Current.shop = tea
    assert_equal [tea_widget.id], ShopScopedWidget.all.ids

    Current.shop = coffee
    assert_equal [coffee_widget.id], ShopScopedWidget.all.ids

    Current.reset
    assert_equal [tea_widget.id, coffee_widget.id].sort, ShopScopedWidget.without_tenant_scope.order(:id).ids
  end

  test "for_shop ignores Current.shop" do
    tea = shops(:tea)
    coffee = shops(:coffee)

    Current.shop = tea
    ShopScopedWidget.create!(shop: tea, name: "Tea Widget")

    Current.shop = coffee
    coffee_widget = ShopScopedWidget.create!(shop: coffee, name: "Coffee Widget")

    Current.shop = tea
    assert_equal [coffee_widget.id], ShopScopedWidget.for_shop(coffee).ids
  end
end
