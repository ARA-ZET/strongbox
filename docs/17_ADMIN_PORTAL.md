# 17 — Admin Portal Feature

## Purpose
Give operations staff full visibility and control over clients, storage units, jobs, drivers, and QR codes.

## Screens & Designs
| Screen | Route | Design file |
|---|---|---|
| Dashboard | /admin/dashboard | admin_portal_dashboard |
| Clients List | /admin/clients | admin_clients_list |
| Client Detail | /admin/clients/:id | admin_client_detail |
| All Inventory | /admin/inventory | admin_all_inventory |
| Unit Detail | /admin/inventory/:id | admin_box_detail |
| QR Management | /admin/qr | admin_qr_management |
| Jobs List | /admin/jobs | admin_jobs_list |
| Create Job Step 1 | /admin/jobs/new | admin_create_new_job_step_1 |
| Create Job Step 2 | /admin/jobs/new | admin_create_new_job_step_2 |
| Create Job Step 3 | /admin/jobs/new | admin_create_new_job_step_3_schedule |
| Create Job Step 4 | /admin/jobs/new | admin_create_new_job_step_4_confirm |
| Fleet | /admin/fleet | admin_drivers_fleet — **Drivers** (invite, edit) / **Vehicles & trailers** (registry: add, edit, retire; licence-disc alerts) |
| Driver Detail | /admin/fleet/:id | admin_driver_detail_view |
| Notifications | /admin/notifications | admin_notifications_alerts_center |
| Reports | /admin/reports | admin_reports_analytics_dashboard |

## Shell
AdminShell: 240px navy sidebar (desktop) + bottom nav (mobile).
Quick Scan amber button at bottom of sidebar opens right-side scanner drawer.

## Dashboard Reads
- `storageUnitRepository.watchAll()` count where status==inStorage
- `jobRepository.watchAll()` filtered to today
- `qrRepository.watchBatches()` for unlinked count alert
- `auditRepository.watchAll()` limit 10 for activity feed

## Inventory Rules
- "Add Box" creates a StorageUnit + optionally links a QR code
- Filtering is client-side after initial Firestore fetch (for performance on small datasets)
- "Load More" uses Firestore cursor pagination

## Create Job State Machine
- State managed by `createJobNotifier` (Riverpod StateNotifier)
- Step 1 sets `type` (pickup/delivery)
- Step 2 sets `clientId`, `storageUnitIds`, `itemIds`
- Step 3 sets `scheduledDate`, `timeWindow`, `driverId`, `notes`
- Step 4 shows summary; Submit calls `jobRepository.create()`
- On submit: job created, storage unit statuses updated, driver notified via FCM

## Permissions
- All admin routes require `role == admin`
- Admin can impersonate a client (logs AuditEvent with `action: adminImpersonated`)
