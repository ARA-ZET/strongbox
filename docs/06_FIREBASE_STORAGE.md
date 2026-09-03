# 06 — Firebase Storage

## Folder Structure

```
{tenantId}/
  storageUnits/
    {unitId}/
      exterior/
        {timestamp}_{uuid}.jpg       ← exterior photos of closed/open units
      interior/
        {timestamp}_{uuid}.jpg       ← interior photos of open units
  items/
    {itemId}/
      {timestamp}_{uuid}.jpg         ← photos of individual catalogued items
  jobs/
    {jobId}/
      driver-photos/
        {unitId}/
          {timestamp}_{uuid}.jpg     ← driver capture at pickup/delivery
      signature.png                  ← client sign-off signature
  drivers/
    {driverId}/
      avatar.jpg                     ← profile photo
      shift-id/
        {shiftId}.png                ← shift E-ID QR card image
  clients/
    {clientId}/
      avatar.jpg                     ← client profile photo
  labels/
    {batchId}/
      qr-labels.pdf                  ← generated QR label PDFs
  documents/
    {clientId}/
      {timestamp}_{filename}         ← uploaded documents (future)
  invoices/
    {clientId}/
      {invoiceId}.pdf                ← Stripe invoice PDFs (cached)
```

## Naming Conventions
- All filenames use lowercase, hyphens, no spaces
- Timestamps in filenames: Unix millisecond timestamp prefix for chronological sorting
- UUIDs: short 8-char UUID suffix to avoid collision
- Example: `1720012345678_a1b2c3d4.jpg`

## Access Rules (Firebase Storage Security Rules)

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Authenticated users only
    match /{tenantId}/{allPaths=**} {
      allow read: if request.auth != null
        && firestore.get(/databases/(default)/documents/users/$(request.auth.uid)).data.tenantId == tenantId;

      // Clients: read their own unit photos only
      // Drivers: read/write job photos and their own profile
      // Admins: full read/write within tenant
      allow write: if request.auth != null
        && firestore.get(/databases/(default)/documents/users/$(request.auth.uid)).data.tenantId == tenantId
        && (
          firestore.get(/databases/(default)/documents/users/$(request.auth.uid)).data.role == 'admin'
          || firestore.get(/databases/(default)/documents/users/$(request.auth.uid)).data.role == 'driver'
        );
    }
  }
}
```

## Upload Guidelines
- **Max file size:** 10MB per photo
- **Accepted formats:** JPG, PNG, WebP
- **Compression:** Compress to max 1280px on longest edge before upload (use Flutter `image` package)
- **Thumbnails:** Generate 200px thumbnail via Cloud Function on upload, store at `{originalPath}_thumb.jpg`
- **Metadata:** Always attach `{uploadedBy: uid, entityType: string, entityId: string}` as custom metadata

## Cloud Function Triggers on Upload
- `onPhotoUpload`: Generate thumbnail, watermark driver captures with timestamp + job ID
- `onSignatureUpload`: Update job document `clientSignatureUrl` field automatically

## Deletion Policy
- Photos are **soft-deleted** in Firestore (set `isDeleted: true`)
- Actual Firebase Storage files are retained for **90 days** after soft-delete
- A scheduled Cloud Function runs daily to hard-delete Storage files where `deletedAt` > 90 days ago
- QR label PDFs are retained indefinitely (low storage cost, legal reference)
