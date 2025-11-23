## Cart & Data Strategy
- **Session-backed cart**: persist cart items in `session[:cart]` (per shop) to avoid schema work; store array of item hashes `{ "uuid", "product_id", "product_size_id", "components" }`. Clear cart after successful order.
- **Component grouping**: leverage existing `components.kind` enum (no new migrations) to split catalog data into `ingredients` vs `extras`. Controller/view will rely on `component.kind` values, assuming fixtures already set accordingly.

## Controller Updates
- **Shops::OrdersController**
  - `index/new`: renders catalog + inline “add to cart” forms (one form per product).
  - `cart` helper methods to read/write session cart.
  - `create` (new behavior): instead of immediate order, adds selected item to cart (or updates existing UUID) and re-renders catalog showing cart sidebar.
  - `checkout`: new action (GET) showing aggregated cart summary; submit posts to `commit` action that invokes `OrderBuilder` with all session items.
- **Shops::CartItemsController** (simpler alternative): embed create/update/destroy endpoints to manage session cart via forms/buttons; OrdersController keeps checkout/create actions. (Pick whichever keeps code tidy; default to dedicated controller for clarity.)

## View Flow
1. **Catalog + Inline Forms (single page)**
   - List each product with two sections: "Included Ingredients" (read-only list of `component.kind == "ingredient"`) and "Optional Extras" (select inputs for allowed extra portions, default `none`).
   - Each product block has size dropdown, extras selectors, quantity (default 1), and an "Add to cart" button posting to cart endpoint.
   - Sidebar/table on same page shows current cart items with edit/remove buttons.
2. **Checkout Summary**
   - Button "Review & save" on catalog page directs to checkout page showing every cart item detailing ingredient/extras portions and price preview (if computable). Users can remove items before final submission.
   - "Save order" button posts to OrdersController#commit, converts session cart into OrderBuilder payload, clears cart, redirects to order show page.

## Service Integration
- Reuse `OrderBuilder`, extending payload builder to accept `items` array from session cart (ensuring each item receives selected component portions where ingredients default to catalog defaults, extras default to `none` unless chosen).
- Add helper module (e.g., `CartPayloadBuilder`) to translate session cart entries into the builder format, enforcing required components/portion defaults.

## Validation & Defaults
- When adding to cart, ensure product belongs to current shop, at least one ingredient exists, and extras belong to that product.
- Ingredients automatically included with their catalog `default_portion`; extras default to `none` (or excluded) unless user picks a non-`none` value.
- On checkout, if cart empty, redirect back with alert.

## Non-Goals (per instructions)
- No DB carts yet; no new migrations.
- No real-time prep view in this phase.
- Keep UI simple (server-rendered ERB); Stimulus/Hotwire can be layered later.

Let me know if this matches expectations before implementation.