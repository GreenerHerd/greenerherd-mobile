-- Feed cycle phase for nutrition profiles (reproductive / growth calendar from masterfile)
ALTER TABLE nutrition_requirement_profiles
  ADD COLUMN IF NOT EXISTS feed_cycle TEXT;

UPDATE nutrition_requirement_profiles
SET feed_cycle = profile_code
WHERE feed_cycle IS NULL;

CREATE INDEX IF NOT EXISTS idx_nutrition_req_feed_cycle
  ON nutrition_requirement_profiles (species, feed_cycle)
  WHERE is_active = TRUE;
