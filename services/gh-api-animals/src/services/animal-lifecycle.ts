import type { Animal, AnimalTagType, AnimalStatus } from '../domain/types.js';
import { AppError } from '../lib/errors.js';

export class AnimalLifecycle {
  flagCull(animal: Animal): Animal {
    if (animal.status !== 'ACTIVE') {
      throw new AppError('INVALID_STATE', 'Only active animals can be culled', 400);
    }
    const tags = new Set(animal.tags);
    tags.add('CULL');
    return { ...animal, tags: [...tags], cull_flagged: true };
  }

  markSold(animal: Animal): Animal {
    if (!animal.tags.includes('CULL')) {
      throw new AppError('INVALID_STATE', 'Animal must be cull-flagged before sale', 400);
    }
    const tags = animal.tags.filter((t) => t !== 'CULL');
    return {
      ...animal,
      tags,
      cull_flagged: false,
      status: 'SOLD' as AnimalStatus,
    };
  }

  applyTag(animal: Animal, tag: AnimalTagType): Animal {
    const tags = new Set(animal.tags);
    tags.add(tag);
    return {
      ...animal,
      tags: [...tags],
      cull_flagged: tags.has('CULL'),
    };
  }

  removeTag(animal: Animal, tag: AnimalTagType): Animal {
    const tags = animal.tags.filter((t) => t !== tag);
    return {
      ...animal,
      tags,
      cull_flagged: tags.includes('CULL'),
    };
  }
}
