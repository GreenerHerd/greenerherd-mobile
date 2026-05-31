import pg from 'pg';

let sharedPool: pg.Pool | null = null;

export function getDatabaseUrl(): string | undefined {
  return process.env.DATABASE_URL;
}

export function shouldUseDatabase(): boolean {
  return Boolean(getDatabaseUrl());
}

export function createPool(connectionString?: string): pg.Pool {
  const url = connectionString ?? getDatabaseUrl();
  if (!url) {
    throw new Error('DATABASE_URL is required for PostgreSQL');
  }
  return new pg.Pool({ connectionString: url, max: 10 });
}

export function getSharedPool(): pg.Pool {
  if (!sharedPool) {
    sharedPool = createPool();
  }
  return sharedPool;
}

export async function verifyDatabaseConnection(pool: pg.Pool): Promise<void> {
  await pool.query('SELECT 1');
}

export async function closeSharedPool(): Promise<void> {
  if (sharedPool) {
    await sharedPool.end();
    sharedPool = null;
  }
}
