export type FeedSpeciesScope =
  | 'ALL'
  | 'CATTLE'
  | 'GOAT'
  | 'SHEEP'
  | 'SMALL_RUMINANT';

export function matchesSpeciesScope(
  scope: FeedSpeciesScope,
  species: 'CATTLE' | 'GOAT' | 'SHEEP',
): boolean {
  if (scope === 'ALL') return true;
  if (scope === 'CATTLE') return species === 'CATTLE';
  if (scope === 'GOAT') return species === 'GOAT';
  if (scope === 'SHEEP') return species === 'SHEEP';
  if (scope === 'SMALL_RUMINANT') return species === 'GOAT' || species === 'SHEEP';
  return false;
}
