require "test_helper"

class ComponentTest < ActiveSupport::TestCase
  setup { Current.reset }
  teardown { Current.reset }

  test "requires name and slug" do
    component = Component.new(shop: shops(:tea))

    assert_not component.valid?
    assert_includes component.errors[:name], "can't be blank"
    assert_includes component.errors[:slug], "can't be blank"
  end

  test "validates slug uniqueness per shop" do
    component = Component.new(shop: shops(:tea), name: "Dup", slug: "tapioca-pearls")

    assert_not component.valid?
    assert_includes component.errors[:slug], "has already been taken"
  end

  test "price_cents must be non-negative" do
    component = Component.new(shop: shops(:tea), name: "Invalid", slug: "invalid", price_cents: -1)

    assert_not component.valid?
    assert_includes component.errors[:price_cents], "must be greater than or equal to 0"
  end

  test "available scope uses active flag" do
    components(:tea_grass_jelly).update!(active: false)
    Current.shop = shops(:tea)

    assert_equal [components(:tea_tapioca).id, components(:tea_grass_jelly).id, components(:tea_cheese_foam).id], Component.ordered.ids
    assert_equal [components(:tea_tapioca).id, components(:tea_cheese_foam).id], Component.available.ids
  end

  test "has many product_components and products" do
    component = components(:tea_tapioca)

    assert_equal [product_components(:classic_tapioca).id], component.product_components.ids
    assert_equal [products(:classic_milk_tea).id], component.products.ids
  end
end
