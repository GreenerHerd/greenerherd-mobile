# Greener Herd — Agent Knowledge Bundle

Upload all files in this bundle to your Claude Managed Agent knowledge base.

## File Index

| File | Category | Purpose |
|---|---|---|
| `GH_JS_Knowledge_Repository.md` | **PRIMARY** | Master knowledge document — start here. Covers all rules, data contracts, and logic in structured form. |
| `feeds.json` | Database | Live feed catalogue (35 ingredients). Source of truth for nutritional values and intake caps. |
| `feed-eligibility-service.js` | Rules | Filters eligible feeds for an animal group by species, sex, age, lactation, and pregnancy status. |
| `optimizer.js` | App Logic | LP-based least-cost feed mix optimiser for cattle (DM basis, NEg/NEm energy model). |
| `small-ruminant-optimizer.js` | App Logic | LP-based least-cost feed mix optimiser for sheep and goats (TDN model, Ca/P in grams). |
| `cull-evaluation-service_test.js` | Reference | Full test suite — reveals the complete API contract, input shapes, scoring rules, and priority thresholds for the cull evaluation service. |
| `mailgunEmailService.js` | Infrastructure | Transactional email sender via Mailgun. Used for notifications and alerts. |

## How to Use With Agents

- **Feed plan tasks** → `GH_JS_Knowledge_Repository.md` § 2–4 + `feeds.json` + eligibility/optimiser files
- **Cull evaluation tasks** → `GH_JS_Knowledge_Repository.md` § 5 + `cull-evaluation-service_test.js`
- **Notification/email tasks** → `GH_JS_Knowledge_Repository.md` § 6 + `mailgunEmailService.js`
- **Adding new feeds** → Follow the schema in `GH_JS_Knowledge_Repository.md` § 1, update `feeds.json`

## Key Gotcha

Species enums differ by service layer:
- `feed-eligibility-service.js` → lowercase: `cattle`, `sheep`, `goats`
- `cull-evaluation-service.js` → UPPERCASE: `CATTLE`, `SHEEP`, `GOAT`
