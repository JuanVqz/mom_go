# Execution Plan (Backend Foundations Only)

> Scope: migrations, models, seeds, relationships, and supporting domain services. UI work is explicitly out of scope. Assumes `Shop` and `Current` models already exist.

### Delivery Summary (2025-11-21)
- **Timeline:** All nine backend phases were started and finished within the same engineering day (~8 hours of focused work).
- **AI model used:** Droid operated via **OpenAI GPT-5.1-Codex** for every implementation/refinement pass in this plan.
- **Core domain models touched:** `Shop`, `User`, `Category`, `Product`, `Size`, `Component`, `ProductCategory`, `ProductSize`, `ProductComponent`, `Order`, `OrderItem`, `OrderItemComponent`, plus supporting layers `Current`, `MomGo::TenantScoped`, and `MomGo::ShopContextMiddleware`.
- **Supporting services & concerns:** `Monetizable` concern, `OrderBuilder`, and `OrderStatusAggregator`, plus catalog/ordering seeds and fixtures to showcase realistic data snapshots.
- **Validation:** Full suite executed via `bin/rails test` (63 tests, 184 assertions) ensuring multi-tenant coverage by stubbing `Current.shop` where needed.

## 1. Tenant Enforcement Baseline ✅ Completed (2025-11-21)
- `MomGo::ShopContextMiddleware` now hydrates `Current.shop` per request.
- `shops.subdomain` unique index enforced; tenant models validated via `MomGo::TenantScoped` concern.
- `MomGo::TenantScoped` shipped with unit tests ensuring default scope + helper behavior.

## 2. User Domain ✅ Completed (2025-11-21)
- **Migration**: create `users` table with `shop_id`, `email`, `name`, timestamps; foreign key `on_delete: :restrict`; unique index on `[:shop_id, :email]`.
- **Model**: `User` belongs_to `Shop`, validates email uniqueness scoped to shop, optional `normalizes :email`.
- **Seed**: create a default staff user per demo shop.

## 3. Catalog Core ✅ Completed (2025-11-21)
### 3.1 Base Tables
- `categories`, `products`, `sizes`, `components` tables with `shop_id`, naming/ordering fields, `available`/`active` booleans, integer cents defaults, timestamps.
- Index pattern: `[:shop_id, :position]`, `[:shop_id, :slug]` (unique), etc.

### 3.2 Join Tables & Enums
- `product_categories`, `product_sizes`, `product_components` linking via FKs (`on_delete: :restrict`).
- Add enum columns: `product_components.default_portion` (`integer`, values `{none:0, quarter:1, half:2, three_quarters:3, full:4}`).
- Monetary defaults (`price_cents` = 0) and optional `required` flag.

### 3.3 Models & Seeds
- Define associations mirroring ERD; scopes for `ordered` (by position) and `available`.
- Seed sample catalog data per shop demonstrating at least two products, sizes, and component combos.

## 4. Ordering Tables
### 4.1 Orders ✅ Completed (2025-11-21)
- Migration: `orders` with `shop_id`, `number`, `status` enum (string/integer + CHECK), currency, monetary fields default 0, `total_item_count`, `ready_at`, timestamps.
- Indexes: unique `[:shop_id, :number]`, lookup indexes for `[:shop_id, :status]`.
- Model: status enum (`pending`, `accepted`, ...), validations for totals (>=0), callback to set `ready_at` when transitioning to `ready`.

### 4.2 Order Items ✅ Completed (2025-11-21)
- Migration: `order_items` referencing `orders`, `products`, `product_sizes`, storing snapshot names (`product_name`, `size_name`) and `price_cents` default 0, status enum, timestamps.
- Indexes: `[:order_id]`, `[:shop_id, :status]` (through `orders.shop_id`), FK constraints `on_delete: :restrict`.
- Model: associations, enum for item statuses, helper to compute component totals.

### 4.3 Order Item Components ✅ Completed (2025-11-21)
- Migration: `order_item_components` with FKs to `order_items` and `components`, snapshot `component_name`, `portion` enum, `price_cents` default 0, timestamps.
- Indexes: `[:order_item_id]`, optional uniqueness on `[:order_item_id, :component_id]` (business rule dependent).
- Model: enum for `portion`, validations ensuring values match catalog defaults when required.

## 5. Monetary Formatting Helpers ✅ Completed (2025-11-21)
- `Monetizable` concern normalizes `*_cents` fields, exposes a `price` helper returning a BigDecimal, and provides `formatted_price` strings such as `$100.00 MXN`.
- Applied to every model with monetary columns (`Product`, `Size`, `Component`, `ProductSize`, `ProductComponent`, `Order`, `OrderItem`, `OrderItemComponent`).
- Unit tests cover conversion accuracy, formatting, and MXN defaults (e.g., `price_cents = 10` → `price = 0.10`, `formatted_price = "$0.10 MXN"`).

## 6. Domain Services / Business Logic ✅ Completed (2025-11-21)
- Implement `OrderBuilder` service (PORO) that accepts cart payload + current shop, snapshots catalog data, builds `orders`, `order_items`, `order_item_components` inside transaction.
- Implement `OrderStatusAggregator` (or callbacks) to derive `Order.status`, `total_item_count`, and `ready_at` from item statuses.
- Add unit tests for both services; no controllers/views yet.

## 7. Constraints & Integrity ✅ Completed (2025-11-21)
- Apply `CHECK (price_cents >= 0)` to all monetary columns via migrations.
- Enforce enum constraints for `status` and `portion` (Rails enums + database check).
- Ensure all foreign keys use `on_delete: :restrict` to protect historical data.
- Create compound indexes prefixed by `shop_id` for tenant isolation (e.g., `[:shop_id, :product_id]`).

## 8. Seeds & Fixtures ✅ Completed (2025-11-21)
- Extend `db/seeds.rb` to:
  - Create demo shop(s) if absent.
  - Populate catalog entities, join records, and a sample order demonstrating portion extras.
- Update factories/fixtures for new models to unblock TDD.

## 9. Testing Matrix (Model/Service Level Only) ✅ Completed (2025-11-21)
- **Model coverage:** `test/models/*_test.rb` verifies validations, associations, enums, monetary helpers, and tenant-aware scopes (`CategoryTest`, `ProductTest`, `ComponentTest`, `Order*Test`, etc.), each stubbing `Current.shop` to assert isolation.
- **Service coverage:** `test/services/order_builder_test.rb` and `order_status_aggregator_test.rb` assert catalog snapshotting, status aggregation, and derived timestamps.
- **Validation command:** `bin/rails test` (parallel 11 workers) succeeds with 63 runs / 184 assertions, confirming the domain logic across tenants.

