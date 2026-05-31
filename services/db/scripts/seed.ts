import { readdir, readFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import pg from 'pg';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const seedsDir = path.join(__dirname, '../seeds');

async function main(): Promise<void> {
  const databaseUrl =
    process.env.DATABASE_URL ??
    'postgres://greenerherd:greenerherd@localhost:5432/greenerherd';

  const pool = new pg.Pool({ connectionString: databaseUrl });
  const client = await pool.connect();

  try {
    const files = (await readdir(seedsDir))
      .filter((f) => f.endsWith('.sql'))
      .sort();

    const ordered = [
      ...files.filter((f) => f === 'countries_currencies.sql'),
      ...files.filter((f) => f === 'breeds.sql'),
      ...files.filter((f) => f === 'breed_weights.sql'),
      ...files.filter((f) => f === 'feed_products.sql'),
      ...files.filter((f) => f === 'feed_product_eligibility_rules.sql'),
      ...files.filter((f) => f === 'marketplace_feed_products.sql'),
      ...files.filter((f) => f === 'feed_fx_rates.sql'),
      ...files.filter((f) => f === 'feed_indicative_prices.sql'),
      ...files.filter((f) => f === 'nutrition_requirements.sql'),
      ...files.filter((f) => f === 'notification_task_definitions.sql'),
      ...files.filter(
        (f) =>
          ![
            'countries_currencies.sql',
            'breeds.sql',
            'breed_weights.sql',
            'feed_products.sql',
            'feed_product_eligibility_rules.sql',
            'marketplace_feed_products.sql',
            'feed_fx_rates.sql',
            'feed_indicative_prices.sql',
            'nutrition_requirements.sql',
            'notification_task_definitions.sql',
          ].includes(f),
      ),
    ];

    for (const file of ordered) {
      const sql = await readFile(path.join(seedsDir, file), 'utf8');
      console.log(`seed ${file}`);
      await client.query(sql);
    }

    const breeds = await client.query(
      'SELECT species, COUNT(*)::int AS count FROM breeds WHERE is_active GROUP BY species ORDER BY species',
    );
    console.log('Breed counts:', breeds.rows);
    console.log('Seeding complete.');
  } finally {
    client.release();
    await pool.end();
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
