/**
 * Mounts the ported Figma pages as Inertia pages.
 *
 * Inertia names these pages `figma/<Component>` — `figma/Home`,
 * `figma/TutorProfile` — which maps one-to-one onto the files in
 * `figma/app/pages`. Laravel decides which one to render, so the design's own
 * `routes.ts` is kept for reference but never executed.
 *
 * The `import.meta.glob` calls themselves must stay in the entry files: Vite
 * requires a literal pattern, and the browser build wants lazy chunks while the
 * SSR build wants everything eagerly. Only the parts that can be shared live
 * here.
 */
import Root from '@/figma/app/pages/Root';
import { OutletProvider } from '@/figma/lib/router-shim';
import type { ComponentType, ReactNode } from 'react';

const FIGMA_PREFIX = 'figma/';

/**
 * Pages the design gives their own full-screen layout, with no shared navbar
 * or footer. Taken from the two top-level branches of `figma/app/routes.ts`.
 */
const FULL_SCREEN = new Set([
    'CoursePlayer',
    'LiveClassroom',
    'Login',
    'Register',
    'Onboarding',
    'AdminDashboard',
    'AdminUsers',
    'AdminContent',
    'AdminAnalytics',
    'AdminBilling',
]);

export function isFigmaPage(name: string): boolean {
    return name.startsWith(FIGMA_PREFIX);
}

/** `figma/TutorProfile` → `TutorProfile`. */
export function figmaComponentName(name: string): string {
    return name.slice(FIGMA_PREFIX.length);
}

/**
 * The design's shared chrome — navbar, footer and global stylesheet — exactly
 * as `Root.tsx` exports it. The page body reaches `Root`'s `<Outlet />` through
 * the shim's context rather than by being imported there.
 */
function FigmaShell({ children }: { children: ReactNode }) {
    return (
        <OutletProvider node={children}>
            <Root />
        </OutletProvider>
    );
}

export interface PageModule {
    default: ComponentType<Record<string, unknown>> & {
        layout?: (page: ReactNode) => ReactNode;
    };
}

/**
 * Attaches the shared chrome as an Inertia layout, unless the design gives this
 * page a full-screen one.
 *
 * Using Inertia's `layout` property rather than wrapping the element keeps the
 * chrome mounted across visits, so the navbar does not remount on every
 * navigation — and it renders identically under SSR.
 */
export function withFigmaChrome(module: PageModule, name: string): PageModule {
    if (FULL_SCREEN.has(figmaComponentName(name))) return module;

    module.default.layout ??= (page: ReactNode) => <FigmaShell>{page}</FigmaShell>;
    return module;
}
