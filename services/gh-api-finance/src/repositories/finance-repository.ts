import type {
  CreateEntryInput,
  CreatePurchaseInput,
  CreateSaleInput,
  FinanceEntry,
  FinanceSummary,
  PurchaseRecord,
  SaleRecord,
} from '../domain/types.js';

export interface FinanceRepository {
  getSummary(farmId: string): Promise<FinanceSummary>;
  addEntry(farmId: string, input: CreateEntryInput): Promise<FinanceEntry>;
  listPurchases(farmId: string): Promise<PurchaseRecord[]>;
  recordPurchase(farmId: string, input: CreatePurchaseInput): Promise<PurchaseRecord>;
  listSales(farmId: string): Promise<SaleRecord[]>;
  recordSale(farmId: string, input: CreateSaleInput): Promise<SaleRecord>;
}
