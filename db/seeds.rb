demo_shops = [
  { name: "Tea Garden", subdomain: "tea", description: "Specialty teas" },
  { name: "Coffee Club", subdomain: "coffee", description: "Artisan coffee drinks" }
]

demo_shops.each do |attributes|
  shop = Shop.find_or_create_by!(subdomain: attributes[:subdomain]) do |record|
    record.name = attributes[:name]
    record.description = attributes[:description]
  end

  shop.users.find_or_create_by!(email: "staff@#{shop.subdomain}.momgo.test") do |user|
    user.name = "#{shop.name} Staff"
  end
end
