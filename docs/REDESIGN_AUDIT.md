# Audit & visual specification — PerpusKu

Baseline: `main`, `0e27e1178d5a13b4841a978789cb0801259d4cc8` (24 October 2026).
Working branch: `redesign/minimal-dashboard-responsive`. Clean checkout before edits.

## Source reviewed

README, pubspec.yaml / lock, main.dart, every Dart file under lib/core and lib/features,
book_model_test.dart, book_form_validation_test.dart and widget_test.dart.
No AGENTS.md found. SDK constraint is Dart ^3.13.0. Dependencies: Flutter,
Supabase Flutter, Provider, flutter_dotenv, Cupertino icons; no new dependency added.
Core constants/services and auth repository files are empty placeholders.

## Actual feature map

| Module | Existing behavior preserved | UI risks identified |
|---|---|---|
| Auth | signIn, signUp, password visibility, confirmation, signOut, main auth redirect | Unbounded desktop form, narrow footer overflow; controllers not disposed |
| Catalog | title/author/code/category/rack/publisher search, category chips, list/grid, refresh, detail, CRUD, stock controls, custom category/rack, validation | Fixed two-column grid and form fields on mobile; desktop oversized cards |
| Members | list, CRUD, normalized number/name/email/phone/address, async errors, delete guard and confirmation | Dense mobile ListTile trailing actions squeeze text |
| Reservations | list/grid, book/member search, CRUD, date pickers, four statuses, detail | Fetch errors swallowed, save/delete failures uncaught; detail stale after edit |
| Category & rack | CRUD, name normalization, duplicate check, existing rack options, exit confirmation | Fetch errors swallowed, delete failures uncaught, existing custom rack absent from dropdown |
| Navigation | all four modules | Bottom nav at every width, page state discarded on module switch; starts on reservations |

Repositories query existing tables ordered by created_at descending. No schema, RLS,
endpoint, model, repository query or credentials changed. The SDK initialization parameter
uses publishableKey with the same existing environment value. Overview uses loaded records;
these are counts of records visible through existing API/RLS, not invented global totals.
No decoration-only analytics or fabricated growth rates.

## Visual specification

References 201420/201445/201448/201456: compact white surfaces, mobile status cards,
readable search and simple navigation. References 201514/201518/201523/201527/201533:
left navigation, aligned desktop tables and restrained overview statistics. 201426:
clear primary actions and grouped information. Adopt their hierarchy, not their finance
content, gradients, oversized radii or charts. Use the PRD navy palette and light theme.

Tokens: navy #172E50, blue #3866B0, canvas #F5F7FA, border #E0E6EF;
headings 24–28, sections 20, body 14–16, captions 12. Native Flutter typography avoids
an additional remote font dependency. Spacing 8/12/16/24/28/32, corners 10–12.

| Surface | Mobile <600 | Tablet 600–1023 | Desktop >=1024 |
|---|---|---|---|
| Shell | Beranda/Katalog/Reservasi/Lainnya | Icon rail with tooltips | 248 px persistent sidebar |
| Overview | One or two stat columns according to actual space | Two columns | Four if content width >=900 |
| Records | Natural-height cards, actions below text | Cards; two columns in grid mode | Table on desktop when content >=600 (or inner width >=900); horizontal scroll confined to table |
| Forms | Single-column, scrollable | Max-width 760 | Same constrained form; book year/stock split only at inner width >=600 |
| Auth | Scrollable form | Centered max-width 480 | Branding panel + constrained form |

IndexedStack lazily mounts visited modules and preserves searches and scroll state.
Stable keyed content survives navigation width changes. Inputs use controllers and stable
form wrappers. Dashboard queries three existing providers; concurrent book/reservation
reads are coalesced. Category reads remain lazy. Errors expose retry; loading never
substitutes zero for unavailable counts.
