import type { FinanceEntry, PurchaseRecord, SaleRecord } from '../domain/types.js';

export function demoEntries(farmId: string): FinanceEntry[] {
  const now = new Date().toISOString();
  return [
    {
      id: 'f1',
      farm_id: farmId,
      date_label: '8 May',
      category: 'Milk Sale',
      type: 'INCOME',
      amount: 1240,
      description: 'Daily collection · Tabuk Dairy',
      created_at: now,
    },
    {
      id: 'f2',
      farm_id: farmId,
      date_label: '7 May',
      category: 'AI Visits',
      type: 'EXPENSE',
      amount: 480,
      description: 'Dr. Rashed · 2 cows',
      created_at: now,
    },
  ];
}

export function demoPurchases(farmId: string): PurchaseRecord[] {
  return [
    {
      id: 'pr1',
      farm_id: farmId,
      purchase_date: '2026-04-01',
      total_amount: 12000,
      animal_ids: [],
      supplier: 'Al-Qassim Livestock',
    },
  ];
}

export function demoSales(farmId: string): SaleRecord[] {
  return [];
}
