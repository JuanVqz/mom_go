# Minimal Rails 8 Store Application - mom_go

## 1. Create New Rails App Command

```bash
rails new mom_go \
  --database=sqlite3 \
  --skip-action-mailbox \
  --skip-action-text \
  --skip-action-cable \
  --skip-active-storage \
  --skip-bootsnap \
  --skip-kamal \
  --skip-docker \
  --skip-hotwire \
  --skip-javascript \
  --css=none
```

**What this KEEPS (Rails 8 omakase defaults):**
- ✅ **Brakeman** - Security vulnerability scanner
- ✅ **RuboCop with rubocop-rails-omakase** - Code linter with Rails style guide
- ✅ **GitHub Actions CI** - Basic CI configuration
- ✅ **Solid Cache, Solid Queue, Solid Cable** - SQLite-based infrastructure

**What this SKIPS:**
- ❌ Tailwind CSS
- ❌ Import maps / JavaScript bundling
- ❌ Action Mailbox
- ❌ Action Text
- ❌ Active Storage (can add later for product images)
- ❌ Bootsnap (can add later for boot performance)
- ❌ Kamal deployment
- ❌ Docker files
- ❌ Action Cable
- ❌ Hotwire/Turbo/Stimulus

**Core Rails that remains:**
- ✅ Active Record (database ORM)
- ✅ Action Mailer (for order confirmations)
- ✅ Active Job (for background jobs)
- ✅ Active Support & Action Pack (core Rails)
- ✅ SQLite3 database

## 2. Expected Gemfile (Core Gems Only)

**Production:**
- `rails` (~> 8.0)
- `sqlite3` (~> 2.0)
- `puma` (web server)
- `solid_cache`, `solid_queue`, `solid_cable` - SQLite-backed infrastructure
- `thruster` - HTTP/2 proxy

**Development & Test:**
- `brakeman` - Security scanner
- `rubocop-rails-omakase` - Opinionated linter
- `debug` - Ruby debugger
- Minitest (default test framework)

## 3. SQLite for Production

Rails 8 production-ready features:
- WAL mode enabled
- IMMEDIATE transaction mode
- Optimized busy handlers
- Single-file simplicity

**Ideal for:**
- Low to medium traffic stores (< 100-500 concurrent users)
- Single-server deployments
- Cost-effective hosting

## 4. Code Quality & Security

**RuboCop:**
- Run: `bin/rubocop`
- Auto-fix: `bin/rubocop -a`
- Config: `.rubocop.yml`

**Brakeman:**
- Run: `bin/brakeman`
- Scans for vulnerabilities

**CI:**
- GitHub Actions at `.github/workflows/ci.yml`
- Runs tests + Brakeman + RuboCop

## 5. Store Structure

**Models:**
- `Product` (name, description, price, stock)
- `Order` (customer_name, customer_email, status, total)
- `OrderItem` (order_id, product_id, quantity, price)

**Controllers:**
- `ProductsController` (index, show)
- `OrdersController` (new, create, show)
- `CartController` (session-based cart management)

**Views:**
- Plain ERB templates
- Minimal CSS (inline or single stylesheet)
- No JavaScript

## 6. Production Configuration

**Database:**
```yaml
production:
  adapter: sqlite3
  database: storage/production.sqlite3
  pool: 5
  timeout: 5000
```

**Cache/Queue:**
- Solid Cache for Rails caching
- Solid Queue for ActiveJob
- All using SQLite

## 7. Deployment

- Use Thruster for HTTP/2 proxy
- Deploy to VPS, Fly.io, Render, Railway
- No Docker/Kamal initially

## Summary

Absolute minimum Rails 8 store **mom_go** with:
- **No bootsnap** (can add if boot time becomes issue)
- **No Active Storage** (can add when product images needed)
- **Yes to code quality** (RuboCop omakase)
- **Yes to security** (Brakeman)
- **Yes to SQLite everywhere** (DB + cache + queue)
- **No JavaScript, no CSS framework**
- Clean, secure, maintainable foundation
