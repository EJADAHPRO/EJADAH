# Ejadah — web

The Ejadah web front end: the **EJADAH PRO 101** Figma Make design, running as a
Laravel application.

Laravel 12 · React 19 · Inertia 2 · Tailwind v4 · SQLite. Scaffolded from
`laravel/react-starter-kit`, so shadcn/ui, SSR and the auth screens come with it.

This lives alongside the Flutter monorepo (`apps/`, `packages/`, `server/`) and
shares nothing with it. It is a separate application in the same repository.

## Run it

```bash
composer install
npm install

cp .env.example .env
php artisan key:generate
touch database/database.sqlite
php artisan migrate --seed        # creates the six roles

npm run dev                       # and, in another shell:
php artisan serve
```

For server-side rendering instead of `npm run dev`:

```bash
npm run build:ssr
node bootstrap/ssr/ssr.js         # Inertia's SSR server, port 13714
php artisan serve
```

## Where the design lives

```
resources/js/figma/app/pages/     76 pages, exactly as exported
resources/js/figma/app/shared.tsx brand tokens, Navbar, Footer, globalStyle
resources/js/figma/app/auth.tsx   the design's client-side auth mock
resources/js/figma/app/routes.ts  the export's own route table — kept for
                                  reference, never executed
resources/js/figma/imports/       the Ejadah icon
resources/js/figma/lib/           the two pieces of bridging code
routes/figma.php                  that route table, as Laravel routes
```

The export is kept in its original shape so it stays diffable against future
Figma output. Only the import aliases were rewritten: `@/app/` → `@/figma/app/`
and `@/imports/` → `@/figma/imports/`.

## How it is wired

**`react-router` is aliased to a shim.** The package is not installed. Both
`vite.config.js` and `tsconfig.json` point the specifier at
`resources/js/figma/lib/router-shim.tsx`, which re-expresses `Link`,
`useNavigate`, `useParams`, `useSearchParams`, `useLocation`, `Outlet` and
`ScrollRestoration` in Inertia terms. `createBrowserRouter` and `RouterProvider`
are no-ops — Laravel owns routing, so running a second client-side router would
only fight it for the URL bar.

Route parameters therefore come from the server: `routes/figma.php` sends them
as a `routeParams` prop and the shim's `useParams()` reads them there.

**Pages mount by name.** Inertia page names are `figma/<Component>` —
`figma/Home`, `figma/TutorProfile` — resolved out of `figma/app/pages` by
`resources/js/figma/lib/chrome.tsx`. Each page stays its own lazy chunk. The
design's shared navbar and footer are attached as an Inertia *layout*, so they
survive navigation instead of remounting; the ten full-screen pages (the player,
the classroom, the admin screens, login, register, onboarding) opt out, matching
the two top-level branches of the original route table.

## Three paths the design does not own

`/login`, `/register` and `/dashboard` stay with the starter kit's working
authentication. The design's versions of those three are static mocks that
cannot sign anyone in, so they are mounted at `/design/login`,
`/design/register` and `/design/dashboard` instead — reachable, but not in the
way of a form that works.

Everything else in the export sits at the path the design gave it, because its
links are absolute (`/courses`, `/career/uk`, `/search`) and would not resolve
from a prefix. Unknown URLs fall through to the design's own 404.

## Roles

`spatie/laravel-permission`, `HasRoles` on `User`, and six roles seeded on the
`web` guard by `RoleSeeder`: Admin, Student, Tutor, Mentor, Consultant, Staff.

## Provenance, and what that costs

The design was recovered from `EJADAH_PRO_101.make` by replaying the 111 file
writes and 180 edits in its chat thread, because Figma Make stores the code
snapshots themselves off-archive. That reconstruction is faithful but not
guaranteed complete:

* **11 edits across 9 files could not be applied** — their target text was not
  present. These are edits that failed in the original session too, so those
  files should be at their true final state, but they are the first place to
  look if a page looks subtly wrong. The files are `shared.tsx` (3), and one
  each in `routes.ts`, `FreeTests`, `TutorOnboarding`, `Home`, `ProgramDetails`,
  `Register` and `Tutoring`.
* **`src/styles/theme.css` was never written**, only edited. Nothing imports it;
  the design's global CSS is the `globalStyle` string in `shared.tsx`.
* **Four defects in the export were fixed** rather than carried over: a
  duplicated `MyBookings` import in `routes.ts`, `nav(...)` called with no `nav`
  in scope in `Exams.tsx` and `Community.tsx` (both would have thrown on click),
  and `align: "center"` — not a CSS property — where `alignItems` was meant.

The design's photography is hot-linked from Unsplash and its data is
hard-coded in the page files. Nothing here talks to the Dart backend yet.

## Checks

```bash
npx tsc --noEmit    # 4 errors, all pre-existing in the starter kit's own
                    # auth forms and welcome.tsx — none in the ported design
npm run build
npm run build:ssr
```
