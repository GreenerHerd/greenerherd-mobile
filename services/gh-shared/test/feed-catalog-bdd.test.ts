import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import { matchesSpeciesScope } from '../db/feed-species-scope.js';
import { isProductEligible } from '../db/feed-eligibility.js';
import {
  loadBddFeedCatalog,
  steamedCornFlakeProductNumber,
  ureaCattleProductNumber,
} from '../test-fixtures/bdd-feed-catalog.js';

describe('BDD feed catalog fixture (products + eligibility rules)', () => {
  const catalog = loadBddFeedCatalog();

  it('loads canonical products with embedded eligibility rules', () => {
    const products = catalog.list();
    assert.ok(products.length >= 60, 'expected ~61 catalogue products');
    for (const p of products) {
      assert.ok(p.product_number >= 1001, `invalid product_number: ${p.name_en}`);
      assert.ok(Array.isArray(p.eligibility_rules), `${p.name_en} missing rules array`);
      assert.ok(
        p.eligibility_rules.length >= 1,
        `${p.name_en} should have at least one rule`,
      );
    }
  });

  it('loads at least 70 eligibility rules across the catalogue', () => {
    const ruleCount = catalog
      .list()
      .reduce((n, p) => n + p.eligibility_rules.length, 0);
    assert.ok(ruleCount >= 70, `expected ~74 rules, got ${ruleCount}`);
  });

  it('resolves products by product_number', () => {
    const steamedNum = steamedCornFlakeProductNumber();
    const ureaNum = ureaCattleProductNumber();
    const steamed = catalog.getByProductNumber(steamedNum);
    const urea = catalog.getByProductNumber(ureaNum);
    assert.equal(steamed?.name_en, 'Steamed Corn Flake');
    assert.equal(urea?.name_en, 'Urea');
    assert.ok(
      steamed!.eligibility_rules.some(
        (r) => r.species_scope === 'CATTLE' && r.production_focus === 'DAIRY',
      ),
    );
    assert.ok(urea!.eligibility_rules.some((r) => r.species_scope === 'CATTLE'));
  });

  it('lists cattle products when filtering by species via rules', () => {
    const cattle = catalog.list({ species: 'CATTLE' });
    assert.ok(cattle.length >= 50);
    for (const p of cattle) {
      assert.ok(
        p.eligibility_rules.some((r) => matchesSpeciesScope(r.species_scope, 'CATTLE')),
        `${p.name_en} has no cattle-applicable rule`,
      );
    }
  });

  it('Barley- raw is one product with separate cattle and small-ruminant rules', () => {
    const barley = catalog.list().find((p) => p.name_en === 'Barley- raw');
    assert.ok(barley, 'Barley- raw missing from fixture');
    assert.equal(barley!.eligibility_rules.length, 2);
    const scopes = barley!.eligibility_rules.map((r) => r.species_scope).sort();
    assert.deepEqual(scopes, ['CATTLE', 'SMALL_RUMINANT']);

    const cattleCtx = {
      species: 'CATTLE' as const,
      age_months: 24,
      production_focus: 'MEAT' as const,
      lactating: false,
    };
    const sheepCtx = {
      species: 'SHEEP' as const,
      age_months: 24,
      production_focus: 'MEAT' as const,
      lactating: false,
    };
    assert.equal(isProductEligible(barley!, cattleCtx).eligible, true);
    assert.equal(isProductEligible(barley!, sheepCtx).eligible, true);
  });
});
