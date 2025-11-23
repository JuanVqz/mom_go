require "test_helper"

module Orders
  class OrderCreationFlowTest < ActionDispatch::IntegrationTest
    setup do
      host! "tea.example.com"
      Current.reset
    end

    teardown { Current.reset }

    test "user builds multi-item cart and saves order" do
      product = products(:classic_milk_tea)
      product_size = product_sizes(:classic_regular)
      tapioca = components(:tea_tapioca)
      milk_blend = components(:tea_house_milk_blend)

      get new_shops_order_path
      assert_response :success
      assert_select "h2", text: product.name

      post shops_cart_items_path, params: {
        cart_item: {
          product_id: product.id,
          product_size_id: product_size.id,
          component_portions: {
            tapioca.id => "full"
          },
          ingredient_portions: {
            milk_blend.id => "half"
          }
        }
      }

      assert_redirected_to new_shops_order_path
      follow_redirect!
      assert_select "li", text: /#{tapioca.name}/

      get checkout_shops_orders_path
      assert_response :success
      assert_select "section h2", text: product.name

      post commit_shops_orders_path
      order = Order.order(:created_at).last
      assert_redirected_to shops_order_path(order)
      follow_redirect!

      assert_response :success
      assert_select "h1", text: /Order/
      assert_select "li", text: /#{tapioca.name}/

      order_item = order.order_items.first
      milk_component = order_item.order_item_components.find_by(component_name: milk_blend.name)
      assert_equal "half", milk_component.portion
    end

    test "ingredient and extra selectors are nested inside cart form" do
      product = products(:classic_milk_tea)
      tapioca = components(:tea_tapioca)
      milk_blend = components(:tea_house_milk_blend)

      get new_shops_order_path
      assert_response :success

      assert_select "section form[action='#{shops_cart_items_path}'] select[name='cart_item[ingredient_portions][#{milk_blend.id}]']"
      assert_select "section form[action='#{shops_cart_items_path}'] select[name='cart_item[ingredient_portions][#{milk_blend.id}]'] option[value='none']", false
      assert_select "section form[action='#{shops_cart_items_path}'] select[name='cart_item[component_portions][#{tapioca.id}]']"
      assert_select "section form[action='#{shops_cart_items_path}'] select[name='cart_item[component_portions][#{tapioca.id}]'] option[value='none']"
    end

    test "user updates cart item ingredient, extra portions, and size" do
      shop = shops(:tea)
      product = products(:classic_milk_tea)
      product_size = product_sizes(:classic_regular)
      new_size = product_sizes(:classic_large)
      tapioca = components(:tea_tapioca)
      milk_blend = components(:tea_house_milk_blend)

      post shops_cart_items_path, params: {
        cart_item: {
          product_id: product.id,
          product_size_id: product_size.id,
          component_portions: {
            tapioca.id => "full"
          },
          ingredient_portions: {
            milk_blend.id => "full"
          }
        }
      }

      item_id = @request.session[:cart][shop.id.to_s]["items"].first["id"]

      patch shops_cart_item_path(item_id), params: {
        cart_item: {
          product_id: product.id,
          product_size_id: new_size.id,
          component_portions: {
            tapioca.id => "quarter"
          },
          ingredient_portions: {
            milk_blend.id => "half"
          }
        }
      }

      assert_redirected_to checkout_shops_orders_path
      follow_redirect!

      assert_select "form[action='#{shops_cart_item_path(item_id)}'] select[name='cart_item[product_size_id]'] option[selected][value='#{new_size.id}']"
      assert_select "form[action='#{shops_cart_item_path(item_id)}'] select[name='cart_item[component_portions][#{tapioca.id}]'] option[selected][value='quarter']"
      ingredient_select = "form[action='#{shops_cart_item_path(item_id)}'] select[name='cart_item[ingredient_portions][#{milk_blend.id}]']"
      assert_select ingredient_select
      assert_select "#{ingredient_select} option[value='none']", false
      assert_select "#{ingredient_select} option[selected][value='half']"

      updated_item = @request.session[:cart][shop.id.to_s]["items"].first
      assert_equal new_size.id, updated_item["product_size_id"]
      assert_equal "half", updated_item["ingredient_portions"][milk_blend.id.to_s]
    end
  end
end
