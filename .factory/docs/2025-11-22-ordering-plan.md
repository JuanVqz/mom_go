# Middleware → Ordering → Real-Time → Ops Dashboard Plan

## 1. Tenant Middleware & Scaffolding - ✅ Completed (2025-11-21)
- Build Rack middleware `app/middleware/tenant_subdomain_resolver.rb` to parse subdomains, lookup `Shop`, and assign `Current.shop`; handle missing/invalid shops with 404.
- Register middleware in `config/application.rb` before controller stack; ensure thread safety via `CurrentAttributes` or similar pattern.
- Add `app/models/concerns/shop_scoped.rb` to centralize `belongs_to :shop`, validations, and `default_scope { where(shop_id: Current.shop.id) }` helpers across tenant models.

## 2. Ordering Workflow (HTML Baseline) - ✅ Completed (2025-11-22)
- Service object `app/services/orders/create_order.rb` ingests params/cart, snapshots catalog data, and persists `Order`, `OrderItem`, `OrderItemComponent` with defaults/enums enforced.
- Controller `OrdersController` (`new`, `create`, `show`) plus ERB views in `app/views/orders/` for basic form submission and order summary display.
- Add integration test `test/integration/orders/order_creation_flow_test.rb` to cover happy path and snapshot pricing behavior.

## 3. Real-Time Layer
- ActionCable channel `OrderItemsChannel` broadcasting per-shop order item status updates; subscribe clients by `shop_id`.
- Callback service `OrderStatusBroadcaster` triggered on `OrderItem` status changes to broadcast Turbo Stream payloads and aggregate `Order` status transitions.
- JavaScript consumer (Stimulus or channel script) updates the HTML list rendered in ordering workflow views.

## 4. Operational Visibility Dashboard
- Controller `Operations::DashboardController` with route `/operations/dashboard` protected by tenant middleware.
- Query object `Orders::StatusLaneQuery` grouping orders into `queued`, `preparing`, `ready`, `delivered` collections for rendering.
- ERB view `app/views/operations/dashboard/index.html.erb` showing simple tables/lanes hooked into the real-time updates for live status changes.
