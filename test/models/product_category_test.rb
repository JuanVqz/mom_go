require "test_helper"

class ProductCategoryTest < ActiveSupport::TestCase
  setup { Current.reset }
  teardown { Current.reset }

  test "requires unique product/category per shop" do
    duplicate = ProductCategory.new(
      shop: shops(:tea),
      product: products(:classic_milk_tea),
      category: categories(:tea_milk_teas)
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:product_id], "has already been taken"
  end

  test "belongs to product and category" do
    record = product_categories(:classic_milk_tea_milk_teas)

    assert_equal products(:classic_milk_tea), record.product
    assert_equal categories(:tea_milk_teas), record.category
  end
end
