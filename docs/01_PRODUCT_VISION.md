# 01 — Product Vision

## Vision
StrongBox Logistics is the operating system for modern storage businesses — making it effortless to collect, store, track, and return client belongings with full transparency and zero mistakes.

## Mission
Eliminate the anxiety of handing your belongings to a stranger by giving every client, driver, and admin complete real-time visibility through QR-powered tracking, photo evidence, and digital confirmation at every step.

## Problem Statement
Small to mid-size storage and collection businesses operate with paper logs, spreadsheets, and WhatsApp messages. This causes:
- Wrong items delivered to wrong clients
- No photographic proof of condition at pickup or delivery
- No client self-service — everything requires a phone call
- No audit trail when disputes arise
- Drivers have no structured workflow — errors happen

## Target Audience

### Primary (v1)
- **Storage business owners** running 1–5 staff, 50–500 active clients
- **Operations managers** dispatching 2–10 drivers daily
- **Drivers** doing 3–15 stops per day

### Secondary (v1)
- **Clients** — households and small businesses storing furniture, seasonal items, documents, equipment

### Future
- Other storage businesses wanting to license the platform
- Moving companies needing inventory + QR tracking
- Estate management firms

## Business Goals (Year 1)
1. Onboard 50 paying client accounts onto StrongBox Logistics
2. Process 1,000 pickup/delivery jobs per month by month 6
3. Achieve < 0.1% wrong-delivery rate
4. Maintain 4.5+ star driver rating from clients

## Revenue Model

### v1 — Subscription (Stripe)
Clients (storage customers) pay a monthly fee based on how many boxes/items they store.

| Plan | Price | Box Limit | Notes |
|---|---|---|---|
| Starter | R899/mo | Up to 20 boxes | Basic tracking, email support |
| Professional | R3,499/mo | Up to 100 boxes | Open-box item cataloguing, priority support |
| Enterprise | Custom | Unlimited | Dedicated account manager, API access |

### Future Revenue Streams
- Per-delivery charge on top of subscription
- Platform licensing to other storage businesses (SaaS)
- Marketplace commission when clients book storage through the app
- Insurance add-on for high-value stored items

## Subscription Plans (Detail)

### Starter — R899/month
- Up to 20 storage units (boxes/items)
- Closed box tracking only (exterior photos)
- QR code labels
- Client portal (view items, request delivery)
- Email notifications
- 1 admin user

### Professional — R3,499/month
- Up to 100 storage units
- Open box + individual item cataloguing
- Per-item delivery requests
- Photo gallery per item
- SMS + email notifications
- 3 admin users + unlimited drivers
- Analytics dashboard

### Enterprise — Custom
- Unlimited storage units
- All Professional features
- API access
- Custom branding
- Dedicated account manager
- SLA guarantee
- Multiple warehouse locations

## Version Roadmap

### v1.0 — MVP (Current Build)
- Admin portal: dashboard, inventory, QR, jobs, fleet, clients, reports, notifications
- Driver app: job list, QR scan, photo capture, client sign-off, shift management
- Client portal: storage view, delivery requests, subscription, account
- Firebase + Stripe integration

### v1.5 — Enhanced Tracking
- Item-level QR codes (not just box-level)
- In-app client chat with admin
- Automated delivery scheduling (client picks slot)
- SMS notifications via Twilio

### v2.0 — Platform Foundation
- Multi-tenant architecture (other storage businesses can sign up)
- Warehouse location management (zones, shelves, bins)
- Route optimisation for drivers (multi-stop ordering)
- White-label client-facing branding per tenant

### v2.5 — Marketplace Beta
- Client-facing marketplace to find and book storage providers
- Freelance driver job board
- Provider ratings and reviews

### v3.0 — StrongBox OS
- AI-powered inventory insights
- Predictive demand for pickups/deliveries
- Home inventory management for non-storage use cases
- Moving company vertical
- Insurance marketplace integration

## Success Metrics
- Monthly Active Clients (paying subscribers)
- Jobs completed per month
- Wrong-delivery rate (target: < 0.1%)
- Average driver job completion time
- Client NPS score
- QR scan rate (% of boxes with QR scanned on pickup and delivery)
- Subscription churn rate (target: < 3%/month)

## Competitive Analysis

| Competitor | Weakness | StrongBox Advantage |
|---|---|---|
| Spreadsheets + WhatsApp | No audit trail, error-prone | Full digital workflow |
| Clutter / MakeSpace | US-only, not white-label | Can be deployed anywhere |
| Generic WMS software | Complex, expensive, not mobile-first | Purpose-built, mobile-first |
| Custom builds | Slow, expensive | Ready to deploy |

## MVP Scope
The v1 MVP is a single-tenant app for one storage business. It covers:
- ✅ Admin portal (web, desktop-first)
- ✅ Driver app (mobile-first web)
- ✅ Client portal (web, responsive)
- ✅ QR code generation + scanning
- ✅ Photo capture at pickup/delivery
- ✅ Stripe subscription billing
- ✅ Firebase real-time sync
- ❌ Multi-tenancy (v2)
- ❌ Marketplace (v2.5)
- ❌ Route optimisation (v1.5)

## Glossary
| Term | Definition |
|---|---|
| Storage Unit | Any box, suitcase, crate, or item in storage (replaces "Box" in code) |
| Closed Unit | A sealed container photographed externally only |
| Open Unit | A catalogued container where each item inside is individually photographed and tracked |
| QR Code | A unique identifier printed on a label and physically attached to each storage unit |
| Job | A scheduled pickup or delivery task assigned to a driver |
| Tenant | A storage business using the platform (v1 = single tenant) |
| Client | A paying customer of the storage business |
| Driver | A staff member who performs pickups and deliveries |
| Admin | Operations staff managing the system |
| Scan Event | Any QR code scan logged in the system with timestamp, location, and actor |
| Audit Trail | The chronological log of every action taken on a storage unit or job |
