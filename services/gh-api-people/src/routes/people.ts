import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { AppError, errorBody } from '../lib/errors.js';
import { assertAdminRole, assertFarmAccess } from '../lib/auth.js';
import type { PeopleService } from '../services/people-service.js';

const inviteSchema = z
  .object({
    name: z.string().min(1),
    email: z.string().email().optional(),
    phone: z.string().min(8).optional(),
    farm_role: z.enum(['MANAGER', 'FARM_HAND', 'VET']),
    preferred_lang: z.enum(['EN', 'AR', 'UR', 'FR']).optional(),
    delivery_channel: z.enum(['EMAIL', 'WHATSAPP', 'BOTH']).default('EMAIL'),
  })
  .superRefine((body, ctx) => {
    if (body.delivery_channel === 'EMAIL' && !body.email) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        message: 'email required for EMAIL delivery',
        path: ['email'],
      });
    }
    if (body.delivery_channel === 'WHATSAPP' && !body.phone) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        message: 'phone required for WHATSAPP delivery',
        path: ['phone'],
      });
    }
    if (body.delivery_channel === 'BOTH' && (!body.email || !body.phone)) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        message: 'email and phone required for BOTH delivery',
      });
    }
  });

const roleSchema = z.object({
  farm_role: z.enum(['OWNER', 'MANAGER', 'FARM_HAND', 'VET']),
});

const groupAccessSchema = z.object({
  user_id: z.string().min(1),
  can_manage: z.boolean(),
});

export async function peopleRoutes(
  app: FastifyInstance,
  peopleService: PeopleService,
): Promise<void> {
  app.get<{ Params: { farmId: string } }>(
    '/api/v1/farms/:farmId/users',
    async (request, reply) => {
      assertFarmAccess(request, request.params.farmId);
      assertAdminRole(request);
      const members = await peopleService.listMembers(request.params.farmId);
      return reply.send({ data: members, meta: { total: members.length } });
    },
  );

  app.post<{ Params: { farmId: string } }>(
    '/api/v1/farms/:farmId/users/invite',
    async (request, reply) => {
      assertFarmAccess(request, request.params.farmId);
      assertAdminRole(request);
      const parsed = inviteSchema.safeParse(request.body);
      if (!parsed.success) {
        return reply.status(400).send(errorBody('VALIDATION_ERROR', parsed.error.message));
      }
      try {
        const farmName =
          (request.body as { farm_name?: string })?.farm_name ?? 'your farm';
        const result = await peopleService.invite(
          request.params.farmId,
          parsed.data,
          farmName,
        );
        return reply.status(201).send({
          data: result.member,
          meta: {
            invite_link: result.delivery.invite_link,
            invite_message: result.delivery.message,
            email_sent: result.delivery.email_sent,
            whatsapp_url: result.delivery.whatsapp_url,
          },
        });
      } catch (e) {
        if (e instanceof AppError) {
          return reply.status(e.statusCode).send(errorBody(e.code, e.message));
        }
        throw e;
      }
    },
  );

  app.patch<{ Params: { farmId: string; userId: string } }>(
    '/api/v1/farms/:farmId/users/:userId',
    async (request, reply) => {
      assertFarmAccess(request, request.params.farmId);
      assertAdminRole(request);
      const parsed = roleSchema.safeParse(request.body);
      if (!parsed.success) {
        return reply.status(400).send(errorBody('VALIDATION_ERROR', parsed.error.message));
      }
      try {
        const member = await peopleService.updateRole(
          request.params.farmId,
          request.params.userId,
          parsed.data.farm_role,
        );
        return reply.send({ data: member });
      } catch (e) {
        if (e instanceof AppError) {
          return reply.status(e.statusCode).send(errorBody(e.code, e.message));
        }
        throw e;
      }
    },
  );

  app.delete<{ Params: { farmId: string; userId: string } }>(
    '/api/v1/farms/:farmId/users/:userId',
    async (request, reply) => {
      assertFarmAccess(request, request.params.farmId);
      assertAdminRole(request);
      try {
        const member = await peopleService.deactivate(
          request.params.farmId,
          request.params.userId,
        );
        return reply.send({ data: member });
      } catch (e) {
        if (e instanceof AppError) {
          return reply.status(e.statusCode).send(errorBody(e.code, e.message));
        }
        throw e;
      }
    },
  );

  app.post<{ Params: { farmId: string; groupId: string } }>(
    '/api/v1/farms/:farmId/groups/:groupId/access',
    async (request, reply) => {
      assertFarmAccess(request, request.params.farmId);
      assertAdminRole(request);
      const parsed = groupAccessSchema.safeParse(request.body);
      if (!parsed.success) {
        return reply.status(400).send(errorBody('VALIDATION_ERROR', parsed.error.message));
      }
      try {
        const access = await peopleService.assignGroup(
          request.params.farmId,
          request.params.groupId,
          parsed.data.user_id,
          parsed.data.can_manage,
        );
        return reply.status(201).send({ data: access });
      } catch (e) {
        if (e instanceof AppError) {
          return reply.status(e.statusCode).send(errorBody(e.code, e.message));
        }
        throw e;
      }
    },
  );

  app.get<{ Params: { farmId: string; groupId: string } }>(
    '/api/v1/farms/:farmId/groups/:groupId/access',
    async (request, reply) => {
      assertFarmAccess(request, request.params.farmId);
      const access = await peopleService.listGroupAccess(request.params.groupId);
      return reply.send({ data: access, meta: { total: access.length } });
    },
  );
}
