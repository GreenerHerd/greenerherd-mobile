import pg from 'pg';

async function main(): Promise<void> {
  const databaseUrl =
    process.env.DATABASE_URL ??
    'postgres://greenerherd:greenerherd@localhost:5432/greenerherd';

  const pool = new pg.Pool({ connectionString: databaseUrl });
  const client = await pool.connect();

  try {
    console.log('Dropping public schema...');
    await client.query('DROP SCHEMA public CASCADE');
    await client.query('CREATE SCHEMA public');
    await client.query('GRANT ALL ON SCHEMA public TO public');
    console.log('Schema reset.');
  } finally {
    client.release();
    await pool.end();
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
