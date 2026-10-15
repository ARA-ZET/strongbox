# Email setup — finish with xneelo

Status (2026-10-15): the code for sending email is built, tested and pushed. Nothing is
emailed yet, because the sender needs an SMTP account and its password stored as a secret.
Until then, Invite Driver still works: copy the setup link from the dialog and send it by
WhatsApp.

## How it works

Everything that sends email (driver invites, invoice notices, job updates, welcome emails)
writes a doc to the Firestore `mail` collection. The `onMailCreated` Cloud Function sends it
over SMTP and writes the result back on the doc as `delivery.state` (`SUCCESS`, or `ERROR`
with the reason). The invite dialog shows this live.

- Code: `functions/src/mailer.js`, `onMailCreated` in `functions/index.js`
- Connection: one secret, `SMTP_URL`
- Sender: `MAIL_FROM` (default `StrongBox <info@strongbox.co.za>`) and `MAIL_REPLY_TO`
  (default `info@strongbox.co.za`). To change them, add them to `functions/.env`.

## 1. Fix the domain's mail DNS (xneelo, konsoleH → DNS)

Found 2026-10-15:

| Record | Now | Problem |
|---|---|---|
| `MX strongbox.co.za` | `10 mail.strongbox.co.za` | fine on its own… |
| `A mail.strongbox.co.za` | `35.219.200.196` | …but that IP is **Firebase App Hosting** (the website), not a mail server. Mail to `info@strongbox.co.za` is probably not arriving. |
| SPF (`TXT strongbox.co.za`) | none | Sent mail likely lands in spam |
| DKIM / DMARC | none | Same |

To do:

- [ ] Point `mail.strongbox.co.za` (or the MX itself) back at **xneelo's mail server**. In
      konsoleH, compare against xneelo's default mail records, or ask their support for the
      correct MX and mail values. This probably changed when the website domain was connected.
- [ ] **Keep** the website records: the apex `A` → `35.219.200.196` and the
      `TXT fah-claim=…` record. Firebase needs both.
- [ ] Add the **SPF** record xneelo gives you (a `TXT` on `strongbox.co.za` starting
      `v=spf1`). If you later send through another provider too (e.g. Brevo), add its
      `include:` to the **same** SPF record. Never create two SPF records.
- [ ] Turn on **DKIM** for the domain in konsoleH, if xneelo offers it.
- [ ] Optional: a DMARC record, e.g. `TXT _dmarc.strongbox.co.za` →
      `v=DMARC1; p=none; rua=mailto:info@strongbox.co.za`.
- [ ] Check that `info@strongbox.co.za` exists as a mailbox, and send it a test email from
      your phone.

Check from a terminal:

```sh
dig +short MX strongbox.co.za
dig +short A mail.strongbox.co.za      # must NOT be 35.219.200.196
dig +short TXT strongbox.co.za         # should include v=spf1 …
```

## 2. Get the SMTP details

From konsoleH, under the mailbox you'll send from (e.g. `info@strongbox.co.za`):

- **Host**: the outgoing (SMTP) server xneelo shows for the mailbox
- **Port**: `465` (SSL) or `587` (STARTTLS)
- **Username**: usually the full email address
- **Password**: the mailbox password

Build the connection string:

```
smtps://USERNAME:PASSWORD@HOST:465     # port 465, SSL
smtp://USERNAME:PASSWORD@HOST:587      # port 587, STARTTLS
```

URL-encode special characters in the username and password: `@` → `%40`, `:` → `%3A`,
`/` → `%2F`, `#` → `%23`, `?` → `%3F`. For example, `info@strongbox.co.za` becomes
`info%40strongbox.co.za`.

> Alternative if xneelo mail is a hassle: a transactional provider such as Brevo (free tier,
> 300 emails/day) or Resend. Verify `strongbox.co.za` there, add its SPF/DKIM records at
> xneelo, and use the SMTP login it gives you. Nothing in the code changes.

## 3. Store the secret

Run this yourself, so the password never ends up in git, chat or logs. Paste the connection
string when it asks:

```sh
firebase functions:secrets:set SMTP_URL --project strongbox-app
```

To replace it later, run the same command again and then redeploy.

## 4. Deploy the functions

The functions deploy is **blocked until the secret exists**. The CLI checks secrets for the
whole functions codebase, so even an `--only` filter fails. Everything else (app, rules) is
already live.

```sh
firebase deploy --only functions --project strongbox-app
```

This ships `onMailCreated` and the updated `inviteDriver` / `resendInvite`, which return the
email id so the invite dialog can show "emailed" or "couldn't email — reason".

## 5. Test it

- [ ] Admin → Fleet → **Invite Driver** with an address you can check. The dialog should change
      from "Sending…" to **"Invite emailed to …"** within a few seconds.
- [ ] If it says **"Couldn't email …"**, the reason comes straight from the mail server:
  - `535 Authentication failed` → wrong username or password (check the URL-encoding)
  - `ENOTFOUND` / `ECONNREFUSED` / timeout → wrong host or port
  - sender rejected → `MAIL_FROM` isn't an address the provider lets you send as
- [ ] Check the email didn't land in spam. If it did, step 1's SPF/DKIM isn't right yet.
- [ ] Logs: `firebase functions:log --only onMailCreated --project strongbox-app`

Emails queued before the secret existed are **not** resent automatically. Resend any invites
from the driver's page (**Resend Invite**).
