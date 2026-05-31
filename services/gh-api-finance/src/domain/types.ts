export type FinanceEntryType = 'INCOME' | 'EXPENSE';

export interface FinanceEntry {
  id: string;
  farm_id: string;
  date_label: string;
  category: string;
  type: FinanceEntryType;
  amount: number;
  description: string;
  created_at: string;
}

export interface FinanceMonth {
  label: string;
  income: number;
  expense: number;
}

export interface FinanceSummary {
  income_3mo: number;
  expense_3mo: number;
  net_3mo: number;
  livestock_value: number;
  monthly: FinanceMonth[];
  recent: FinanceEntry[];
}

export interface PurchaseRecord {
  id: string;
  farm_id: string;
  purchase_date: string;
  total_amount: number;
  animal_ids: string[];
  supplier?: string;
  notes?: string;
}

export interface SaleRecord {
  id: string;
  farm_id: string;
  sale_date: string;
  total_amount: number;
  animal_ids: string[];
  buyer?: string;
  notes?: string;
}

export interface CreateEntryInput {
  date_label: string;
  category: string;
  type: FinanceEntryType;
  amount: number;
  description: string;
}

export interface CreatePurchaseInput {
  purchase_date: string;
  total_amount: number;
  animal_ids?: string[];
  supplier?: string;
  notes?: string;
}

export interface CreateSaleInput {
  sale_date: string;
  total_amount: number;
  animal_ids: string[];
  buyer?: string;
  notes?: string;
}
