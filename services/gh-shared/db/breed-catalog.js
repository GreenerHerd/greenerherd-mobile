export class BreedCatalog {
    all;
    bySpecies = new Map();
    lookup = new Map();
    byId = new Map();
    weightsByBreedId = new Map();
    constructor(rows) {
        this.all = rows;
        for (const row of rows) {
            this.byId.set(row.id, row);
            const list = this.bySpecies.get(row.species) ?? [];
            list.push(row);
            this.bySpecies.set(row.species, list);
            this.indexKey(row.species, row.code, row);
            this.indexKey(row.species, row.name_en, row);
            if (row.name_ar)
                this.indexKey(row.species, row.name_ar, row);
            if (row.name_en.includes('/')) {
                for (const part of row.name_en.split('/')) {
                    this.indexKey(row.species, part.trim(), row);
                }
            }
        }
    }
    indexKey(species, raw, row) {
        const key = `${species}::${normalizeBreedKey(raw)}`;
        this.lookup.set(key, row);
    }
    static fromRecords(rows) {
        if (rows.length === 0) {
            throw new Error('BreedCatalog.fromRecords requires at least one breed');
        }
        return new BreedCatalog(rows);
    }
    setWeights(breedId, points) {
        this.weightsByBreedId.set(breedId, points);
    }
    getWeights(breedId) {
        return this.weightsByBreedId.get(breedId) ?? null;
    }
    static async load(pool) {
        const { rows } = await pool.query(`SELECT
        id, species, code, name_en, name_ar, name_ur, name_fr,
        origin, primary_purpose, color, milk_production_kg_year,
        heat_tolerance, disease_resistance, birth_ease, feed_efficiency,
        temperament, adult_male_weight_kg, adult_female_weight_kg,
        adaptability, longevity_years, height_male_cm, height_female_cm, known_for
       FROM breeds
       WHERE is_active = TRUE
       ORDER BY species, name_en`);
        if (rows.length === 0) {
            throw new Error('No breeds in database. Run: cd services/db && npm run db:setup');
        }
        return new BreedCatalog(rows);
    }
    static async loadWeights(pool, breedId) {
        const { rows } = await pool.query(`SELECT sex, age_months, weight_kg
       FROM breed_weight_by_age
       WHERE breed_id = $1
       ORDER BY sex, age_months`, [breedId]);
        return rows.map((r) => ({
            sex: r.sex,
            age_months: r.age_months,
            weight_kg: Number(r.weight_kg),
        }));
    }
    list(species) {
        if (!species)
            return [...this.all];
        return [...(this.bySpecies.get(species) ?? [])];
    }
    getById(id) {
        return this.byId.get(id) ?? null;
    }
    resolve(species, breed) {
        return this.lookup.get(`${species}::${normalizeBreedKey(breed)}`) ?? null;
    }
    require(species, breed) {
        const found = this.resolve(species, breed);
        if (!found) {
            throw new Error(`UNKNOWN_BREED:${species}:${breed}`);
        }
        return found;
    }
    get size() {
        return this.all.length;
    }
    countsBySpecies() {
        return {
            CATTLE: this.bySpecies.get('CATTLE')?.length ?? 0,
            GOAT: this.bySpecies.get('GOAT')?.length ?? 0,
            SHEEP: this.bySpecies.get('SHEEP')?.length ?? 0,
        };
    }
}
export function normalizeBreedKey(value) {
    return value
        .trim()
        .toLowerCase()
        .normalize('NFD')
        .replace(/[\u0300-\u036f]/g, '')
        .replace(/[/\\]+/g, '_')
        .replace(/[^a-z0-9_]+/g, '_')
        .replace(/_+/g, '_')
        .replace(/^_|_$/g, '');
}
export function toPublicBreed(b) {
    return {
        id: b.id,
        species: b.species,
        code: b.code,
        name_en: b.name_en,
        name_ar: b.name_ar,
        name_ur: b.name_ur,
        name_fr: b.name_fr,
        origin: b.origin,
        primary_purpose: b.primary_purpose,
        color: b.color,
        milk_production_kg_year: b.milk_production_kg_year,
        heat_tolerance: b.heat_tolerance,
        disease_resistance: b.disease_resistance,
        birth_ease: b.birth_ease,
        feed_efficiency: b.feed_efficiency,
        temperament: b.temperament,
        adult_male_weight_kg: b.adult_male_weight_kg,
        adult_female_weight_kg: b.adult_female_weight_kg,
        adaptability: b.adaptability,
        longevity_years: b.longevity_years,
        height_male_cm: b.height_male_cm,
        height_female_cm: b.height_female_cm,
        known_for: b.known_for,
    };
}
