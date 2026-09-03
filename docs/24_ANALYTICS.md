# 24 — Analytics Feature Spec

## Purpose
Give admins a real-time view of business performance: job throughput, unit volume, driver efficiency, client activity, and revenue. Charts and tables are built from Firestore aggregation queries and pre-computed daily roll-ups.

---

## Designs

| Screen | Route | Design File |
|---|---|---|
| Reports & Analytics | `/admin/reports` | `admin_reports_analytics_dashboard` |

---

## Screen Layout

### Desktop
- Left: KPI summary cards row (4 cards)
- Below: 2-column chart grid
- Right rail: Driver leaderboard + recent activity feed

### Mobile
- Scrollable vertical stack: cards → charts → tables

---

## KPI Cards (Top Row)

Calculated from Firestore queries. All time ranges are selectable (Today / This Week / This Month / Custom).

| Metric | Source | Calculation |
|---|---|---|
| **Total Jobs** | `jobs` | count where `createdAt` in range |
| **Completed Jobs** | `jobs` | count where `status == completed` in range |
| **On-Time Rate** | `jobs` | `completedAt <= scheduledDate.end` / total completed |
| **Units Stored** | `storageUnits` | count where `status == inStorage` |
| **Units Delivered** | `storageUnits` | count where `status == delivered` in range |
| **Active Clients** | `clients` | count where `subscriptionStatus in [active, trialing]` |
| **Revenue (MRR)** | `customers/*/subscriptions` | sum of active plan prices |

Each `SummaryCard` or `MetricCard` shows value + trend vs previous period (calculated client-side).

---

## Charts

### 1. Jobs Over Time (Line Chart)
- X: date (daily ticks for week/month, weekly for 3 months)
- Y: job count
- Two lines: Pickups (navy) / Deliveries (amber)
- Package: `fl_chart` → `LineChart`

### 2. Unit Status Breakdown (Donut Chart)
- Segments: In Storage / In Transit / Pending Pickup / Delivered / Pending Delivery
- Colors match status chip colours
- Centre label: total unit count
- Package: `fl_chart` → `PieChart`

### 3. Job Completion Rate (Bar Chart)
- X: day of week (Mon–Sun) or week number
- Y: count
- Stacked bars: completed (green) / cancelled (red) / incomplete (grey)
- Package: `fl_chart` → `BarChart`

### 4. Revenue Trend (Area Chart)
- X: month
- Y: MRR in £/$ (from Stripe subscription data)
- Single amber area line
- Package: `fl_chart` → `LineChart` with gradient fill

---

## Driver Performance Table

| Column | Source |
|---|---|
| Driver Name | `users/{uid}.name` |
| Jobs Completed | count of completed jobs by `driverId` in range |
| On-Time % | `completedAt <= scheduledDate.end` percentage |
| Avg Duration | mean of `completedAt - inProgressAt` |
| Issues Reported | count of `issueReports` by `driverId` |

- Sortable by any column
- Highlight top performer (gold badge)
- Uses `AppDataTable` widget

---

## Client Activity Table

| Column | Source |
|---|---|
| Client Name | `clients/{id}.name` |
| Units in Storage | count of units where `clientId, status == inStorage` |
| Deliveries This Month | count of completed delivery jobs |
| Subscription | plan name + status chip |
| Last Activity | most recent AuditEvent `timestamp` |

---

## Recent Activity Feed

- Last 20 `AuditEvent`s across all entities
- Each entry: icon + description + entity link + timestamp (relative)
- Auto-refreshes via `StreamProvider`
- Types displayed: job status changes, unit status changes, issue reports, new clients

---

## Data Architecture

### Real-Time Queries (small counts)
Direct Firestore `StreamProvider`s for:
- Current unit statuses (donut chart)
- Recent activity feed
- Active subscriptions count

### Aggregated Queries (larger datasets)
Use Firestore `count()` aggregation queries (requires Firestore SDK ≥ 9.10):
```dart
final count = await FirebaseFirestore.instance
    .collection('jobs')
    .where('tenantId', isEqualTo: tenantId)
    .where('status', isEqualTo: 'completed')
    .where('createdAt', isGreaterThan: rangeStart)
    .count()
    .get();
```

### Pre-computed Daily Roll-Ups (future v1.5)
Cloud Function `dailyRollup` runs at 23:59 UTC and writes summary documents:
```
analytics/{tenantId}/daily/{YYYY-MM-DD}
  totalJobs, completedJobs, pickupJobs, deliveryJobs,
  unitsPickedUp, unitsDelivered, newClients, revenue
```
Charts then read from this collection for historical ranges (faster, avoids scanning full collections).

---

## Time Range Selector

- Tabs / dropdown: Today | This Week | This Month | Last 3 Months | Custom Range
- Managed by `analyticsFilterNotifier`
- All chart providers depend on the selected range via `ref.watch(analyticsFilterNotifier)`

---

## Export

- "Export CSV" button on each table
- Generates CSV client-side from current query results
- `csv` package + `path_provider` for local download
- Filename format: `strongbox_report_{type}_{date}.csv`

---

## Providers

```dart
analyticsFilterNotifier             → Notifier<AnalyticsFilter>
  // AnalyticsFilter { range: DateTimeRange, preset: 'today'|'week'|'month'|'custom' }

jobsOverTimeProvider(filter)        → FutureProvider<List<DailyJobCount>>
unitStatusBreakdownProvider         → StreamProvider<Map<StorageStatus, int>>
completionRateProvider(filter)      → FutureProvider<List<DailyCompletionRate>>
revenueTrendProvider(filter)        → FutureProvider<List<MonthlyRevenue>>
driverPerformanceProvider(filter)   → FutureProvider<List<DriverStats>>
clientActivityProvider(filter)      → FutureProvider<List<ClientActivity>>
recentActivityProvider              → StreamProvider<List<AuditEvent>>
kpiSummaryProvider(filter)          → FutureProvider<KPISummary>
```

---

## Permissions

| Feature | Admin | Driver | Client |
|---|---|---|---|
| View full analytics dashboard | ✓ | ✗ | ✗ |
| View own driver stats | ✗ | ✓ (profile screen) | ✗ |
| View own storage stats | ✗ | ✗ | ✓ (dashboard) |
| Export CSV | ✓ | ✗ | ✗ |

---

## Error States

| Error | Handling |
|---|---|
| Firestore aggregation timeout | Fall back to full query count (capped at 500) |
| No data for selected range | Empty chart with "No data for this period" label |
| Revenue data unavailable | Hide chart; show "Connect Stripe to see revenue data" |
| Export fails | Toast: "Export failed — try again" |

---

## Acceptance Criteria

- [ ] All 4 KPI cards load within 2 seconds of page open
- [ ] Time range selector updates all charts and tables simultaneously
- [ ] Line chart correctly plots pickups vs deliveries by day
- [ ] Donut chart segments match live Firestore unit status counts
- [ ] Driver performance table is sortable by all columns
- [ ] "Export CSV" downloads a valid file for each table
- [ ] Charts handle empty data gracefully (no blank white space)
- [ ] Analytics data is tenant-scoped (no cross-tenant leakage)
- [ ] Driver can view their own stats on the profile screen (not full dashboard)
