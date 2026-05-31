import { InMemoryFinanceRepository } from '../repositories/in-memory-finance-repository.js';
import type { FinanceRepository } from '../repositories/finance-repository.js';

export async function bootstrapFinanceData(
  repository?: FinanceRepository,
): Promise<{ repository: FinanceRepository }> {
  const repo = repository ?? new InMemoryFinanceRepository();
  if (repo instanceof InMemoryFinanceRepository) {
    repo.ensureDemoFarm('farm-1');
  }
  return { repository: repo };
}
