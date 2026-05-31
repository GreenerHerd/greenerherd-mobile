import { v4 as uuid } from 'uuid';
import type {
  CreateEntryInput,
  CreatePurchaseInput,
  CreateSaleInput,
  FinanceEntry,
  FinanceMonth,
  FinanceSummary,
  PurchaseRecord,
  SaleRecord,
} from '../domain/types.js';
import {
  demoEntries,
  demoPurchases,
  demoSales,
} from '../db/seed-demo-finance.js';
import type { FinanceRepository } from './finance-repository.js';

export class InMemoryFinanceRepository implements FinanceRepository {
  private entries = new Map<string, FinanceEntry[]>();
  private purchases = new Map<string, PurchaseRecord[]>();
  private sales = new Map<string, SaleRecord[]>();
  private livestockValue = new Map<string, number>();

  ensureDemoFarm(farmId: string): void {
    if (!this.entries.has(farmId)) {
      this.entries.set(farmId, [...demoEntries(farmId)]);
      this.purchases.set(farmId, [...demoPurchases(farmId)]);
      this.sales.set(farmId, [...demoSales(farmId)]);
      this.livestockValue.set(farmId, 412800);
    }
  }

  async getSummary(farmId: string): Promise<FinanceSummary> {
    this.ensureDemoFarm(farmId);
    const entries = this.entries.get(farmId) ?? [];
    const monthly: FinanceMonth[] = [
      { label: 'Mar', income: 24000, expense: 12200 },
      { label: 'Apr', income: 28000, expense: 14600 },
      { label: 'May', income: 32200, expense: 14800 },
    ];
    let income3 = 0;
    let expense3 = 0;
    for (const m of monthly) {
      income3 += m.income;
      expense3 += m.expense;
    }
    for (const e of entries) {
      if (e.type === 'INCOME') income3 += e.amount;
      else expense3 += e.amount;
    }
    const recent = [...entries]
      .sort((a, b) => b.created_at.localeCompare(a.created_at))
      .slice(0, 20);
    return {
      income_3mo: income3,
      expense_3mo: expense3,
      net_3mo: income3 - expense3,
      livestock_value: this.livestockValue.get(farmId) ?? 0,
      monthly,
      recent,
    };
  }

  async addEntry(farmId: string, input: CreateEntryInput): Promise<FinanceEntry> {
    this.ensureDemoFarm(farmId);
    const entry: FinanceEntry = {
      id: uuid(),
      farm_id: farmId,
      ...input,
      created_at: new Date().toISOString(),
    };
    this.entries.get(farmId)!.unshift(entry);
    return entry;
  }

  async listPurchases(farmId: string): Promise<PurchaseRecord[]> {
    this.ensureDemoFarm(farmId);
    return [...(this.purchases.get(farmId) ?? [])];
  }

  async recordPurchase(
    farmId: string,
    input: CreatePurchaseInput,
  ): Promise<PurchaseRecord> {
    this.ensureDemoFarm(farmId);
    const record: PurchaseRecord = {
      id: uuid(),
      farm_id: farmId,
      purchase_date: input.purchase_date,
      total_amount: input.total_amount,
      animal_ids: input.animal_ids ?? [],
      supplier: input.supplier,
      notes: input.notes,
    };
    this.purchases.get(farmId)!.unshift(record);
    await this.addEntry(farmId, {
      date_label: input.purchase_date.slice(0, 10),
      category: 'Livestock purchase',
      type: 'EXPENSE',
      amount: input.total_amount,
      description: input.supplier ?? 'Animal purchase',
    });
    return record;
  }

  async listSales(farmId: string): Promise<SaleRecord[]> {
    this.ensureDemoFarm(farmId);
    return [...(this.sales.get(farmId) ?? [])];
  }

  async recordSale(farmId: string, input: CreateSaleInput): Promise<SaleRecord> {
    this.ensureDemoFarm(farmId);
    const record: SaleRecord = {
      id: uuid(),
      farm_id: farmId,
      sale_date: input.sale_date,
      total_amount: input.total_amount,
      animal_ids: input.animal_ids,
      buyer: input.buyer,
      notes: input.notes,
    };
    this.sales.get(farmId)!.unshift(record);
    await this.addEntry(farmId, {
      date_label: input.sale_date.slice(0, 10),
      category: 'Livestock sale',
      type: 'INCOME',
      amount: input.total_amount,
      description: input.buyer ?? 'Animal sale',
    });
    return record;
  }
}
