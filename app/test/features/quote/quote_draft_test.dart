import 'package:flutter_test/flutter_test.dart';
import 'package:strong_box/core/constants/price_list.g.dart';
import 'package:strong_box/core/models/quote.dart';

void main() {
  test('supplies and helper hours travel in the website URL form', () {
    final draft = QuoteDraft.fromQuery({
      'boxes': 'small:2',
      'supplies': 'bubble-wrap:3,tape:1',
      'helper': '3',
    });
    expect(draft.supplies, {'bubble-wrap': 3, 'tape': 1});
    expect(draft.helperHours, 3);
    expect(QuoteDraft.fromQuery(draft.toQuery()), draft);
    expect(QuoteDraft.inQuery({'helper': '2'}), isTrue);
  });

  test('once-off totals add vehicle, supplies and packing help', () {
    const catalog = PriceList.catalog;
    final draft = const QuoteDraft(boxes: {'small': 1}, vehicleId: 'small-van')
        .withSupply('bubble-wrap', 2)
        .withHelperHours(2);
    final totals = QuoteTotals(draft, catalog);
    expect(totals.monthlyZar, 195); // supplies never touch the monthly bill
    expect(totals.suppliesZar, 2 * 50);
    expect(totals.helperZar, 2 * catalog.packingHelper.hourlyZar);
    expect(totals.onceOffZar, 250 + 100 + 500);
    expect(QuoteTotals(draft.withHelperHours(1), catalog).helperTooShort,
        isTrue);
  });
}
