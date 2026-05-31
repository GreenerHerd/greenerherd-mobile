import Fastify from 'fastify';
import cors from '@fastify/cors';
import jwt from 'jsonwebtoken';
import { createFastifyLogger } from '@greenerherd/shared-db/fastify-logger';

const app = Fastify({ logger: createFastifyLogger('gh-api-auth') });
const secret = process.env.JWT_SECRET ?? 'dev-secret-change-me';

await app.register(cors, { origin: true });

app.get('/health', async () => ({ status: 'ok', service: 'gh-api-auth' }));

app.post<{ Body: { email: string; password?: string } }>(
  '/api/v1/auth/login',
  async (request, reply) => {
    const { email } = request.body;
    const token = jwt.sign(
      {
        user_id: 'u1',
        farm_ids: ['farm-1'],
        role: 'OWNER',
        email,
      },
      secret,
      { expiresIn: '15m' },
    );
    return reply.send({
      data: {
        accessToken: token,
        refreshToken: 'mock-refresh',
        user: { id: 'u1', name: 'Yusuf Al-Harbi', role: 'OWNER' },
      },
    });
  },
);

app.post('/api/v1/auth/refresh', async (_request, reply) => {
  return reply.send({ data: { accessToken: jwt.sign({ user_id: 'u1' }, secret) } });
});

const port = Number(process.env.PORT ?? 3001);
await app.listen({ port, host: '0.0.0.0' });
app.log.info({ port }, 'gh-api-auth listening');
