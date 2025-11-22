demo_shops = [
  { name: "Tea Garden", subdomain: "tea", description: "Specialty teas" },
  { name: "Coffee Club", subdomain: "coffee", description: "Artisan coffee drinks" }
]

catalog_blueprint = {
  categories: [
    { name: "Milk Teas", slug: "milk-teas", position: 1 },
    { name: "Signature Drinks", slug: "signature-drinks", position: 2 }
  ],
  sizes: [
    { name: "Regular", slug: "regular", position: 1, price_cents: 0 },
    { name: "Large", slug: "large", position: 2, price_cents: 100 }
  ],
  components: [
    { name: "Tapioca Pearls", slug: "tapioca-pearls", position: 1, price_cents: 50 },
    { name: "Grass Jelly", slug: "grass-jelly", position: 2, price_cents: 75 },
    { name: "Cheese Foam", slug: "cheese-foam", position: 3, price_cents: 125, active: true },
    { name: "Assam Black Tea Base", slug: "assam-black-tea-base", position: 4, price_cents: 0 },
    { name: "House Milk Blend", slug: "house-milk-blend", position: 5, price_cents: 0 },
    { name: "Ceremonial Matcha Shot", slug: "ceremonial-matcha-shot", position: 6, price_cents: 0 },
    { name: "Vanilla Cloud Base", slug: "vanilla-cloud-base", position: 7, price_cents: 0 }
  ],
  products: [
    {
      name: "Classic Milk Tea",
      slug: "classic-milk-tea",
      description: "Black tea with creamy milk and light sweetness.",
      position: 1,
      base_price_cents: 500,
      category_slugs: ["milk-teas"],
      size_prices: [
        { size_slug: "regular", price_cents: 0 },
        { size_slug: "large", price_cents: 100 }
      ],
      component_options: [
        { component_slug: "assam-black-tea-base", price_cents: 0, default_portion: :full, required: true },
        { component_slug: "house-milk-blend", price_cents: 0, default_portion: :full, required: true },
        { component_slug: "tapioca-pearls", price_cents: 50, default_portion: :half },
        { component_slug: "grass-jelly", price_cents: 75, default_portion: :quarter }
      ]
    },
    {
      name: "Matcha Cloud",
      slug: "matcha-cloud",
      description: "Ceremonial matcha with milk and salted foam.",
      position: 2,
      base_price_cents: 650,
      category_slugs: ["signature-drinks"],
      size_prices: [
        { size_slug: "regular", price_cents: 50 },
        { size_slug: "large", price_cents: 150 }
      ],
      component_options: [
        { component_slug: "ceremonial-matcha-shot", price_cents: 0, default_portion: :full, required: true },
        { component_slug: "vanilla-cloud-base", price_cents: 0, default_portion: :half, required: true },
        { component_slug: "cheese-foam", price_cents: 0, default_portion: :quarter, required: true },
        { component_slug: "tapioca-pearls", price_cents: 50, default_portion: :half }
      ]
    }
  ]
}

def seed_catalog_for(shop, blueprint)
  categories_by_slug = blueprint[:categories].each_with_index.to_h do |attributes, index|
    record = Category.find_or_initialize_by(shop: shop, slug: attributes[:slug])
    record.name = attributes[:name]
    record.position = attributes[:position] || index + 1
    record.available = attributes.fetch(:available, true)
    record.save!
    [record.slug, record]
  end

  sizes_by_slug = blueprint[:sizes].each_with_index.to_h do |attributes, index|
    record = Size.find_or_initialize_by(shop: shop, slug: attributes[:slug])
    record.name = attributes[:name]
    record.position = attributes[:position] || index + 1
    record.price_cents = attributes.fetch(:price_cents, 0)
    record.available = attributes.fetch(:available, true)
    record.save!
    [record.slug, record]
  end

  components_by_slug = blueprint[:components].each_with_index.to_h do |attributes, index|
    record = Component.find_or_initialize_by(shop: shop, slug: attributes[:slug])
    record.name = attributes[:name]
    record.position = attributes[:position] || index + 1
    record.price_cents = attributes.fetch(:price_cents, 0)
    record.active = attributes.fetch(:active, true)
    record.save!
    [record.slug, record]
  end

  blueprint[:products].each_with_index do |attributes, index|
    product = Product.find_or_initialize_by(shop: shop, slug: attributes[:slug])
    product.name = attributes[:name]
    product.description = attributes[:description]
    product.position = attributes[:position] || index + 1
    product.base_price_cents = attributes.fetch(:base_price_cents, 0)
    product.available = attributes.fetch(:available, true)
    product.save!

    Array(attributes[:category_slugs]).each do |slug|
      category = categories_by_slug.fetch(slug)
      ProductCategory.find_or_create_by!(shop: shop, product: product, category: category)
    end

    Array(attributes[:size_prices]).each do |size_price|
      size = sizes_by_slug.fetch(size_price[:size_slug])
      record = ProductSize.find_or_initialize_by(shop: shop, product: product, size: size)
      record.price_cents = size_price.fetch(:price_cents, 0)
      record.save!
    end

    Array(attributes[:component_options]).each do |component_option|
      component = components_by_slug.fetch(component_option[:component_slug])
      record = ProductComponent.find_or_initialize_by(shop: shop, product: product, component: component)
      record.price_cents = component_option.fetch(:price_cents, 0)
      record.required = component_option.fetch(:required, false)
      record.default_portion = component_option.fetch(:default_portion, :none)
      record.save!
    end
  end
end

def seed_sample_order_for(shop)
  product = shop.products.order(:position).first
  return unless product

  product_size = product.product_sizes.order(:id).first
  items_total_cents = product.base_price_cents + product_size&.price_cents.to_i
  tax_total_cents = (items_total_cents * 0.1).floor
  number = "#{shop.subdomain.upcase}-ORDER-001"

  order = Order.find_or_create_by!(shop: shop, number: number) do |record|
    record.status = :ready
    record.currency = "MXN"
    record.items_total_cents = items_total_cents
    record.discount_total_cents = 0
    record.tax_total_cents = tax_total_cents
    record.total_cents = items_total_cents + tax_total_cents
    record.total_item_count = 1
    record.ready_at = Time.current
  end

  order_item = order.order_items.find_or_create_by!(product: product, product_size: product_size) do |order_item|
    order_item.product_name = product.name
    order_item.size_name = product_size&.size&.name
    order_item.price_cents = items_total_cents
    order_item.status = :ready
  end

  component_option = product.product_components.order(:id).first
  if component_option
    order_item.order_item_components.find_or_create_by!(component: component_option.component) do |record|
      record.component_name = component_option.component.name
      record.price_cents = component_option.price_cents
      record.portion = component_option.default_portion
    end
  end
end

demo_shops.each do |attributes|
  shop = Shop.find_or_create_by!(subdomain: attributes[:subdomain]) do |record|
    record.name = attributes[:name]
    record.description = attributes[:description]
  end

  shop.users.find_or_create_by!(email: "staff@#{shop.subdomain}.momgo.test") do |user|
    user.name = "#{shop.name} Staff"
    user.password = "#{shop.subdomain.capitalize}_password"
  end

  seed_catalog_for(shop, catalog_blueprint)
  seed_sample_order_for(shop)
end
