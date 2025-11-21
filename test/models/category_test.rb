require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  setup { Current.reset }
  teardown { Current.reset }

  test "requires name and slug" do
    category = Category.new(shop: shops(:tea))

    assert_not category.valid?
    assert_includes category.errors[:name], "can't be blank"
    assert_includes category.errors[:slug], "can't be blank"
  end

  test "enforces slug uniqueness per shop" do
    category = Category.new(shop: shops(:tea), name: "Duplicate", slug: "milk-teas")

    assert_not category.valid?
    assert_includes category.errors[:slug], "has already been taken"
  end

  test "ordered scope sorts by position" do
    Current.shop = shops(:tea)

    assert_equal [categories(:tea_milk_teas).id, categories(:tea_signature_drinks).id], Category.ordered.ids
  end

  test "available scope filters unavailable" do
    categories(:tea_signature_drinks).update!(available: false)
    Current.shop = shops(:tea)

    assert_equal [categories(:tea_milk_teas).id], Category.available.ids
  end

  test "has many products through product_categories" do
    category = categories(:tea_milk_teas)

    assert_equal [products(:classic_milk_tea).id], category.products.ids
    assert_equal [product_categories(:classic_milk_tea_milk_teas).id], category.product_categories.ids
  end
end
