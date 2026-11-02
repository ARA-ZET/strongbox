/**
 * Pickup booking from a quote — the `bookPickup` callable.
 *
 * The client sends only what they chose: counts per price-list id, a pickup
 * vehicle, date, time window and address. Prices come from the server's
 * copy of the price list, never from the request, so a client cannot set
 * their own rate. One `storageUnits` doc is created per item, status
 * `pendingPickup`, rate locked in, each with its own QR code (`qrCodes`
 * doc, linked) — the client prints the labels and sticks them on while
 * packing, and the driver scans them at collection.
 *
 * Optional extras, priced server-side too: packing supplies (once-off each)
 * and packing-helper hours. With `suppliesFirst` (journey Path A) a linked
 * `supplyDrop` job brings empty boxes and the supplies before the pickup;
 * otherwise the driver brings the supplies on the day (Path B).
 *
 * Bookings arrive `pendingConfirmation` — an admin reviews and confirms
 * them (JobRepository.confirm) before a driver is dispatched.
 */
const { HttpsError } = require("firebase-functions/v2/https");
const { FieldValue, Timestamp } = require("firebase-admin/firestore");
const logger = require("firebase-functions/logger");

const { COL, SAST_OFFSET_MS } = require("./constants");
const { freshUnitCodes } = require("./qr");
const defaults = require("./default-rates.g.json").catalog;

/** One booking writes job + units + QR codes + audit in one batch (≤ 500). */
const MAX_UNITS = 200;
/** gRPC ALREADY_EXISTS — a QR code taken between check and write. */
const ALREADY_EXISTS = 6;
const MAX_PER_ITEM = 99;
const MAX_HELPER_HOURS = 12;
const WINDOWS = new Set(["morning", "afternoon", "evening"]);
const DAY_MS = 24 * 60 * 60 * 1000;

/**
 * The tenant's live catalog (priceLists/{tenantId}) or the defaults.
 * @param {object|undefined} priceList
 */
function catalogFrom(priceList) {
  if (!priceList) return defaults;
  // Stored with the app's JSON names (PriceCatalog): `price`, not monthlyZar.
  const list = (entries) => (entries || []).filter((e) => e && e.id);
  return {
    boxes: list(priceList.boxes).map((b) => ({ id: b.id, label: b.label,
      monthlyZar: Number(b.price) || 0, active: b.active !== false })),
    looseItems: list(priceList.looseItems).map((i) => ({ id: i.id,
      name: i.name, monthlyZar: Number(i.price) || 0,
      active: i.active !== false })),
    vehicles: list(priceList.vehicles).map((v) => ({ id: v.id,
      label: v.label, onceOffZar: Number(v.price) || 0,
      active: v.active !== false })),
    // Lists published before supplies existed fall back to the defaults.
    supplies: priceList.supplies ?
      list(priceList.supplies).map((s) => ({ id: s.id, label: s.label,
        onceOffZar: Number(s.price) || 0, active: s.active !== false })) :
      defaults.supplies,
    packingHelper: priceList.packingHelper ? {
      label: priceList.packingHelper.label || "Packing helper",
      hourlyZar: Number(priceList.packingHelper.price) || 0,
      minHours: Number(priceList.packingHelper.minHours) || 1,
      active: priceList.packingHelper.active !== false,
    } : defaults.packingHelper,
  };
}

function bad(message) {
  return new HttpsError("invalid-argument", message);
}

/** SAST calendar day number of [date]. */
function sastDay(date) {
  return Math.floor((date.getTime() + SAST_OFFSET_MS) / DAY_MS);
}

/**
 * Validates a booking request against [catalog] and returns what to write.
 * Pure — throws HttpsError("invalid-argument") on anything off-menu.
 * @param {object} data request data
 * @param {object} catalog from catalogFrom()
 * @param {Date} now
 * @return {{units: Array<object>, vehicle: object, scheduledDate: Date,
 *   timeWindow: string, address: object, notes: string|null,
 *   accessNotes: string|null, supplies: Array<object>, helperHours: number,
 *   helperZar: number, emptyBoxes: Object<string, number>,
 *   supplyDrop: {scheduledDate: Date, timeWindow: string}|null,
 *   monthlyZar: number, onceOffZar: number}}
 */
function planBooking(data, catalog, now) {
  const counts = (raw) => {
    if (raw == null) return {};
    if (typeof raw !== "object" || Array.isArray(raw)) {
      throw bad("Quote items must be counts per item.");
    }
    return raw;
  };
  const boxes = counts(data.boxes);
  const loose = counts(data.loose);

  const units = [];
  const add = (entries, list, name, type) => {
    for (const [id, rawCount] of Object.entries(entries)) {
      const count = Number(rawCount);
      if (!Number.isInteger(count) || count < 0 || count > MAX_PER_ITEM) {
        throw bad(`Quantity for "${id}" must be 0–${MAX_PER_ITEM}.`);
      }
      if (count === 0) continue;
      const item = list.find((entry) => entry.id === id);
      if (!item || item.active === false || !(item.monthlyZar > 0)) {
        throw bad(`"${id}" isn't on the price list any more — ` +
          "refresh your quote.");
      }
      for (let i = 1; i <= count; i++) {
        units.push({
          priceKey: id,
          monthlyRateZar: item.monthlyZar,
          type,
          label: count > 1 ? `${item[name]} ${i}` : item[name],
        });
      }
    }
  };
  add(boxes, catalog.boxes, "label", "closed");
  add(loose, catalog.looseItems, "name", "open");

  if (units.length === 0) throw bad("Add at least one box or item.");
  if (units.length > MAX_UNITS) {
    throw bad(`That's more than ${MAX_UNITS} items — contact us and ` +
      "we'll plan the move with you.");
  }

  const vehicle = catalog.vehicles.find((v) => v.id === data.vehicle &&
    v.active !== false);
  if (!vehicle) throw bad("Choose a pickup vehicle.");

  // Same-day bookings are too late to dispatch; cap how far ahead.
  // Compared as SAST calendar days.
  const day = (raw, what) => {
    const date = new Date(String(raw || ""));
    if (Number.isNaN(date.getTime())) throw bad(`Choose a ${what} date.`);
    if (sastDay(date) <= sastDay(now)) {
      throw bad(`Pick a ${what} date from tomorrow onwards.`);
    }
    if (date.getTime() > now.getTime() + 180 * DAY_MS) {
      throw bad(`Pick a ${what} date within the next six months.`);
    }
    return date;
  };
  const window = (raw) => {
    const value = String(raw || "");
    if (!WINDOWS.has(value)) throw bad("Choose a time window.");
    return value;
  };
  const scheduledDate = day(data.date, "pickup");
  const timeWindow = window(data.timeWindow);

  // Packing supplies: once-off, priced from the list.
  const supplies = [];
  for (const [id, rawQty] of Object.entries(counts(data.supplies))) {
    const qty = Number(rawQty);
    if (!Number.isInteger(qty) || qty < 0 || qty > MAX_PER_ITEM) {
      throw bad(`Quantity for "${id}" must be 0–${MAX_PER_ITEM}.`);
    }
    if (qty === 0) continue;
    const item = (catalog.supplies || []).find((entry) => entry.id === id);
    if (!item || item.active === false) {
      throw bad(`"${id}" isn't on the price list any more — ` +
        "refresh your quote.");
    }
    supplies.push({ id, label: item.label, qty, unitZar: item.onceOffZar });
  }

  const helper = catalog.packingHelper || { active: false };
  const helperHours = Number(data.helperHours || 0);
  if (!Number.isInteger(helperHours) || helperHours < 0 ||
    helperHours > MAX_HELPER_HOURS) {
    throw bad(`Packing help is booked in whole hours, up to ` +
      `${MAX_HELPER_HOURS}.`);
  }
  if (helperHours > 0) {
    if (!helper.active || !(helper.hourlyZar > 0)) {
      throw bad("Packing help isn't available right now.");
    }
    if (helperHours < helper.minHours) {
      throw bad(`Packing help is a minimum of ${helper.minHours} hours.`);
    }
  }
  const helperZar = helperHours * (helper.hourlyZar || 0);

  // Path A: supplies delivered on an earlier day, at least 24 hours ahead.
  let supplyDrop = null;
  const emptyBoxes = {};
  if (data.suppliesFirst === true) {
    const supplyDate = day(data.supplyDate, "supply drop-off");
    if (sastDay(supplyDate) >= sastDay(scheduledDate)) {
      throw bad("Supplies must arrive at least a day before the pickup.");
    }
    supplyDrop = { scheduledDate: supplyDate,
      timeWindow: window(data.supplyWindow) };
    for (const unit of units) {
      if (unit.type !== "closed") continue;
      emptyBoxes[unit.priceKey] = (emptyBoxes[unit.priceKey] || 0) + 1;
    }
  }

  const raw = data.address || {};
  const text = (value, max) => String(value || "").trim().slice(0, max);
  const address = {
    line1: text(raw.line1, 120),
    line2: text(raw.line2, 120) || null,
    city: text(raw.city, 60),
    postCode: text(raw.postCode, 10),
    country: "ZA",
  };
  if (!address.line1 || !address.city) {
    throw bad("Enter the pickup address (street and suburb/city).");
  }

  const suppliesZar = supplies.reduce((sum, s) => sum + s.qty * s.unitZar, 0);
  return {
    units,
    vehicle,
    scheduledDate,
    timeWindow,
    address,
    notes: text(data.notes, 500) || null,
    accessNotes: text(data.accessNotes, 300) || null,
    supplies,
    helperHours,
    helperZar,
    emptyBoxes,
    supplyDrop,
    monthlyZar: units.reduce((sum, unit) => sum + unit.monthlyRateZar, 0),
    onceOffZar: vehicle.onceOffZar + suppliesZar + helperZar,
  };
}

/**
 * @param {FirebaseFirestore.Firestore} db
 */
function createBooking(db) {
  /**
   * data: { boxes, loose, vehicle, date (ISO), timeWindow, address, notes?,
   *   accessNotes?, supplies?, helperHours?, suppliesFirst?, supplyDate?,
   *   supplyWindow? }
   * → { jobId, supplyJobId, unitIds, monthlyZar, pickupZar, onceOffZar }
   */
  async function bookPickup(request) {
    const uid = request.auth && request.auth.uid;
    if (!uid) throw new HttpsError("unauthenticated", "Sign in to book.");
    const user = await db.collection(COL.users).doc(uid).get();
    if (!user.exists || user.get("role") !== "client") {
      throw new HttpsError("permission-denied",
          "Pickups are booked from a client account.");
    }
    const clientId = user.get("clientId");
    const tenantId = user.get("tenantId");
    if (!clientId) {
      throw new HttpsError("failed-precondition",
          "Your account is still being set up — try again in a moment.");
    }

    const priceList = await db.collection(COL.priceLists).doc(tenantId).get();
    const plan = planBooking(request.data || {},
        catalogFrom(priceList.exists ? priceList.data() : undefined),
        new Date());

    const jobRef = db.collection(COL.jobs).doc();
    const supplyRef = plan.supplyDrop ? db.collection(COL.jobs).doc() : null;
    const unitRefs = plan.units.map(() =>
      db.collection(COL.storageUnits).doc());
    const now = FieldValue.serverTimestamp();

    // A code taken between the check and the write fails the whole batch
    // (create() never overwrites) — retry with fresh codes.
    for (let attempt = 1; ; attempt++) {
      const codes = await freshUnitCodes(db, plan.units.length);
      try {
        await writeBooking(codes);
        break;
      } catch (error) {
        if (error.code !== ALREADY_EXISTS || attempt >= 3) throw error;
      }
    }

    /** @param {string[]} codes one QR code per unit */
    async function writeBooking(codes) {
      const batch = db.batch();

      const common = {
        tenantId,
        clientId,
        driverId: null,
        status: "pendingConfirmation",
        address: plan.address,
        scannedUnitIds: [],
        receivedUnitIds: [],
        handedOverUnitIds: [],
        itemIds: [],
        photoIds: [],
        notes: plan.notes,
        accessNotes: plan.accessNotes,
        source: "quote",
        suppliesFirst: !!plan.supplyDrop,
        isRushJob: false,
        isDeleted: false,
        createdAt: now,
        updatedAt: now,
      };
      batch.set(jobRef, {
        ...common,
        type: "pickup",
        scheduledDate: Timestamp.fromDate(plan.scheduledDate),
        timeWindow: plan.timeWindow,
        storageUnitIds: unitRefs.map((ref) => ref.id),
        // Path B: the driver brings the supplies on the day.
        supplies: plan.supplyDrop ? [] : plan.supplies,
        emptyBoxes: {},
        helperHours: plan.helperHours,
        pickupVehicleId: plan.vehicle.id,
        estimatedFee: plan.vehicle.onceOffZar,
        // Every once-off charge rides on the pickup, billed once collected.
        onceOffZar: plan.onceOffZar,
        linkedJobId: supplyRef ? supplyRef.id : null,
      });
      if (supplyRef) {
        batch.set(supplyRef, {
          ...common,
          type: "supplyDrop",
          scheduledDate: Timestamp.fromDate(plan.supplyDrop.scheduledDate),
          timeWindow: plan.supplyDrop.timeWindow,
          storageUnitIds: [],
          supplies: plan.supplies,
          emptyBoxes: plan.emptyBoxes,
          helperHours: 0,
          onceOffZar: 0,
          linkedJobId: jobRef.id,
        });
      }
      plan.units.forEach((unit, i) => {
        batch.set(unitRefs[i], {
          tenantId,
          clientId,
          qrCodeId: codes[i],
          type: unit.type,
          priceKey: unit.priceKey,
          monthlyRateZar: unit.monthlyRateZar,
          label: unit.label,
          status: "pendingPickup",
          jobId: jobRef.id,
          photoIds: [],
          tags: [],
          isDeleted: false,
          createdAt: now,
          updatedAt: now,
        });
        batch.create(db.collection(COL.qrCodes).doc(codes[i]), {
          tenantId,
          storageUnitId: unitRefs[i].id,
          isLinked: true,
          source: "booking",
          createdAt: now,
          linkedAt: now,
          linkedBy: uid,
        });
      });
      batch.set(db.collection(COL.auditEvents).doc(), {
        tenantId,
        actorId: uid,
        actorRole: "client",
        action: "jobCreated",
        entityType: "job",
        entityId: jobRef.id,
        metadata: {
          type: "pickup",
          source: "quote",
          units: plan.units.length,
          monthlyZar: plan.monthlyZar,
          onceOffZar: plan.onceOffZar,
          vehicle: plan.vehicle.id,
          suppliesFirst: !!plan.supplyDrop,
        },
        timestamp: now,
      });
      await batch.commit();
    }

    logger.info("Pickup booked", { jobId: jobRef.id, clientId,
      units: plan.units.length });
    return {
      jobId: jobRef.id,
      supplyJobId: supplyRef ? supplyRef.id : null,
      unitIds: unitRefs.map((ref) => ref.id),
      monthlyZar: plan.monthlyZar,
      pickupZar: plan.vehicle.onceOffZar,
      onceOffZar: plan.onceOffZar,
    };
  }

  return { bookPickup };
}

module.exports = { createBooking, planBooking, catalogFrom, sastDay, MAX_UNITS };
