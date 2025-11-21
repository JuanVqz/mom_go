require "test_helper"

class TenantScopedTest < ActiveSupport::TestCase
  class TenantScopedWidget < ApplicationRecord
    self.table_name = "tenant_scoped_widgets"
    include MomGo::TenantScoped
  end

  setup do
    ActiveRecord::Base.connection.create_table(:tenant_scoped_widgets, force: true) do |t|
      t.references :shop, null: false, foreign_key: true
      t.string :name, null: false
      t.timestamps
    end

    TenantScopedWidget.reset_column_information
    Current.reset
  end

  teardown do
    ActiveRecord::Base.connection.drop_table(:tenant_scoped_widgets, if_exists: true)
    Current.reset
  end

  test "requires a shop" do
    widget = TenantScopedWidget.new(name: "Sample")

    assert_not widget.valid?
    assert_includes widget.errors[:shop], "must exist"
  end

  test "default scope restricts queries to Current.shop" do
    tea = shops(:tea)
    coffee = shops(:coffee)

    Current.shop = tea
    tea_widget = TenantScopedWidget.create!(shop: tea, name: "Tea Widget")

    Current.shop = coffee
    coffee_widget = TenantScopedWidget.create!(shop: coffee, name: "Coffee Widget")

    Current.shop = tea
    assert_equal [tea_widget.id], TenantScopedWidget.all.ids

    Current.shop = coffee
    assert_equal [coffee_widget.id], TenantScopedWidget.all.ids

    Current.reset
    assert_equal [tea_widget.id, coffee_widget.id].sort, TenantScopedWidget.without_tenant_scope.order(:id).ids
  end

  test "for_shop ignores Current.shop" do
    tea = shops(:tea)
    coffee = shops(:coffee)

    Current.shop = tea
    TenantScopedWidget.create!(shop: tea, name: "Tea Widget")

    Current.shop = coffee
    coffee_widget = TenantScopedWidget.create!(shop: coffee, name: "Coffee Widget")

    Current.shop = tea
    assert_equal [coffee_widget.id], TenantScopedWidget.for_shop(coffee).ids
  end
end
