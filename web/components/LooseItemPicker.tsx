"use client";

import { useState } from "react";
import type { Prices } from "@/lib/prices";

/**
 * Pick loose items from the live list — the same items, categories and
 * prices /loose-items shows. Used by both calculators; each click adds one of
 * that item to the quote, so the caller owns the counts.
 */
export default function LooseItemPicker({
  looseItems,
  looseItemCategories,
  onAdd,
  onClose,
}: Pick<Prices, "looseItems" | "looseItemCategories"> & {
  onAdd: (id: string) => void;
  onClose: () => void;
}) {
  const [category, setCategory] = useState("All");
  const shown =
    category === "All" ? looseItems : looseItems.filter((i) => i.category === category);

  return (
    <div className="p-4 border-2 border-accent-deep/40 rounded-xl bg-mist">
      <div className="flex justify-between items-center mb-3">
        <p className="font-body-strong text-navy-deep text-sm">Pick loose items</p>
        <button
          onClick={onClose}
          className="text-sm font-body-strong text-accent-deep hover:underline"
        >
          Done
        </button>
      </div>

      {looseItemCategories.length > 2 && (
        <div className="flex gap-2 flex-wrap mb-3">
          {looseItemCategories.map((cat) => (
            <button
              key={cat}
              onClick={() => setCategory(cat)}
              aria-pressed={category === cat}
              className={`px-3 py-1 rounded-full text-xs font-body-strong transition-colors ${
                category === cat
                  ? "bg-navy-deep text-surface-white"
                  : "bg-surface-white text-navy-deep hover:bg-surface-container"
              }`}
            >
              {cat}
            </button>
          ))}
        </div>
      )}

      <div className="grid grid-cols-1 sm:grid-cols-2 gap-2 max-h-64 overflow-y-auto pr-1">
        {shown.map((item) => (
          <button
            key={item.id}
            onClick={() => onAdd(item.id)}
            aria-label={`Add ${item.name}, R${item.price} per month`}
            className="flex items-center gap-2 p-2 bg-surface-white border border-navy-deep/10 rounded-lg text-left hover:border-accent-deep transition-colors group"
          >
            <span className="material-symbols-outlined text-accent-deep text-xl shrink-0">
              {item.icon}
            </span>
            <span className="text-sm text-navy-deep font-body-strong truncate flex-1">
              {item.name}
            </span>
            <span className="text-xs text-on-surface-variant tabular-nums shrink-0">
              R{item.price}
            </span>
            <span className="material-symbols-outlined text-navy-deep/30 group-hover:text-accent-deep text-lg shrink-0">
              add
            </span>
          </button>
        ))}
      </div>
    </div>
  );
}
