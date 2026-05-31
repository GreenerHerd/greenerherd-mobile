# GREENER HERD — Project Overview
> AI Engineering Harness Memory Artifact · v1.0

## Purpose
Greener Herd is a livestock management mobile application targeting farmers in the **Middle East**. It helps farmers manage livestock health, productivity, nutrition, breeding, tasks, finances, and reporting from a single platform.

## Target Users
| Role | Description | Access Level |
|---|---|---|
| Farm Owner | Primary account holder, full control | Admin |
| Farm Manager | Day-to-day operations manager | Admin |
| Farm Hand | Executes assigned tasks, limited view | Standard |
| Veterinarian | Cross-farm health visibility | Vet (read-heavy) |

## Key Principles
- **Mobile-first** Flutter application (iOS + Android)
- **Multi-lingual**: English, Arabic, Urdu, French (RTL support required for Arabic/Urdu)
- **Offline-capable**: core data entry must work without connectivity
- **All weights in kg**
- **Currency**: user selects preferred currency at Farm Profile setup; stored per-farm
- **Middle East context**: animals are typically kept indoors (sheds with fans, or in shade); pasture management is NOT in scope
- **Vet multi-farm**: a vet account can be linked to multiple farms and selects which farm to view on login

## Livestock Species in Scope
- Cattle
- Goats
- Sheep

A farm can have one or more species. Each species can be designated for **Milk**, **Meat**, or **Both** — this drives farm logic throughout the app.

## Tech Stack
| Layer | Technology |
|---|---|
| Mobile Frontend | Flutter (Dart) |
| Backend Services | Node.js (Express or Fastify) |
| Database | PostgreSQL (primary), Redis (caching/sessions) |
| File Storage | S3-compatible object storage (images, voice notes, docs) |
| AI Features | Claude API (nutrition recommendations, feed identification, cull reports, voice tasks) |
| Push Notifications | Firebase Cloud Messaging (FCM) |
| Localisation | Flutter `intl` package + ARB files |

## Module Map
```
Greener Herd
├── Onboarding
├── Dashboard (Farm overview + per-species)
├── Animals
│   ├── Individual Animal Profile
│   └── Group Management
├── Features (per animal / per group)
│   ├── Nutrition
│   ├── Breeding
│   ├── Milking
│   └── Healthcare
├── Task Management
├── Buying & Selling
├── Inventory
│   ├── Feed Inventory
│   └── Medical Inventory
├── Finance
├── Reporting
└── People Management
```

## Localisation Requirements
- All UI strings externalised into ARB files (one per locale)
- RTL layout switching for Arabic and Urdu
- Date formats follow locale conventions
- Number formatting (decimal separators) follow locale
- Language can be changed within app settings without reinstall
