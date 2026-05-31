import type { FastifyReply, FastifyRequest } from 'fastify';
import jwt from 'jsonwebtoken';
import { AppError } from './errors.js';

export interface JwtClaims {
  user_id: string;
  farm_ids: string[];
  role: string;
}

declare module 'fastify' {
  interface FastifyRequest {
    user?: JwtClaims;
  }
}

export function createAuthHook(secret: string) {
  return async function authHook(request: FastifyRequest, _reply: FastifyReply) {
    const header = request.headers.authorization;
    if (!header?.startsWith('Bearer ')) {
      throw new AppError('UNAUTHORIZED', 'Missing or invalid Authorization header', 401);
    }
    try {
      request.user = jwt.verify(header.slice(7), secret) as JwtClaims;
    } catch {
      throw new AppError('UNAUTHORIZED', 'Invalid or expired token', 401);
    }
  };
}

export function assertFarmAccess(request: FastifyRequest, farmId: string): void {
  if (!request.user?.farm_ids?.includes(farmId)) {
    throw new AppError('FORBIDDEN', 'No access to this farm', 403);
  }
}

export function assertFinanceRole(request: FastifyRequest): void {
  const role = request.user?.role;
  if (role !== 'OWNER' && role !== 'MANAGER') {
    throw new AppError('FORBIDDEN', 'Finance access requires owner or manager role', 403);
  }
}

export function signTestToken(
  secret: string,
  claims: Partial<JwtClaims> & { user_id: string },
): string {
  return jwt.sign(
    {
      farm_ids: claims.farm_ids ?? [],
      role: claims.role ?? 'OWNER',
      ...claims,
    },
    secret,
    { expiresIn: '1h' },
  );
}
