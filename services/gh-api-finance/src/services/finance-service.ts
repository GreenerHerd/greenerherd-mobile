import type {
  CreateEntryInput,
  CreatePurchaseInput,
  CreateSaleInput,
} from '../domain/types.js';
import type { FinanceRepository } from '../repositories/finance-repository.js';

export class FinanceService {
  constructor(private readonly repo: FinanceRepository) {}

  getSummary(farmId: string) {
    return this.repo.getSummary(farmId);
  }

  addEntry(farmId: string, input: CreateEntryInput) {
    return this.repo.addEntry(farmId, input);
  }

  listPurchases(farmId: string) {
    return this.repo.listPurchases(farmId);
  }

  recordPurchase(farmId: string, input: CreatePurchaseInput) {
    return this.repo.recordPurchase(farmId, input);
  }

  listSales(farmId: string) {
    return this.repo.listSales(farmId);
  }

  recordSale(farmId: string, input: CreateSaleInput) {
    return this.repo.recordSale(farmId, input);
  }
}
