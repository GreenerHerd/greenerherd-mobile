import { BreedCatalog, toPublicBreed, } from '../db/breed-catalog.js';
export async function registerReferenceRoutes(app, breedCatalog, pool) {
    app.get('/api/v1/reference/breeds/health', async () => ({
        data: {
            loaded: breedCatalog.size,
            by_species: breedCatalog.countsBySpecies(),
        },
        meta: {},
    }));
    app.get('/api/v1/reference/breeds', async (request, reply) => {
        const species = request.query.species;
        if (species && !['CATTLE', 'GOAT', 'SHEEP'].includes(species)) {
            return reply.status(400).send({
                error: { code: 'VALIDATION_ERROR', message: 'Invalid species filter' },
            });
        }
        const breeds = breedCatalog.list(species);
        return reply.send({
            data: breeds.map(toPublicBreed),
            meta: {
                total: breeds.length,
                by_species: breedCatalog.countsBySpecies(),
            },
        });
    });
    app.get('/api/v1/reference/breeds/:breedId', async (request, reply) => {
        const breed = breedCatalog.getById(request.params.breedId);
        if (!breed) {
            return reply.status(404).send({
                error: { code: 'BREED_NOT_FOUND', message: 'Breed not found' },
            });
        }
        return reply.send({ data: toPublicBreed(breed), meta: {} });
    });
    app.get('/api/v1/reference/breeds/:breedId/weights', async (request, reply) => {
        const breed = breedCatalog.getById(request.params.breedId);
        if (!breed) {
            return reply.status(404).send({
                error: { code: 'BREED_NOT_FOUND', message: 'Breed not found' },
            });
        }
        const inMemory = breedCatalog.getWeights(breed.id);
        const weights = inMemory ??
            (pool ? await BreedCatalog.loadWeights(pool, breed.id) : null);
        if (!weights) {
            return reply.status(503).send({
                error: {
                    code: 'REFERENCE_UNAVAILABLE',
                    message: 'Weight data requires DATABASE_URL',
                },
            });
        }
        return reply.send({
            data: weights,
            meta: { total: weights.length, breed_id: breed.id },
        });
    });
}
