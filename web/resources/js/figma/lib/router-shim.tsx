/**
 * react-router → Inertia shim.
 *
 * The Figma export is a react-router SPA. Rather than run a second client-side
 * router inside Inertia — which would fight it for the URL bar and lose the
 * server as the source of truth — every `react-router` import is aliased here
 * and re-expressed in Inertia terms.
 *
 * Two consequences worth knowing:
 *
 *  * `createBrowserRouter` and `RouterProvider` are deliberate no-ops. The
 *    route table in `figma/app/routes.ts` is kept so the pages still typecheck
 *    against it, but Laravel's routes decide what renders.
 *  * Nothing here reads `window` at module scope, so the same code runs under
 *    `npm run build:ssr`.
 */
import { Link as InertiaLink, router, usePage } from '@inertiajs/react';
import type { ComponentProps, CSSProperties, ReactNode } from 'react';
import { createContext, useCallback, useContext, useMemo } from 'react';

/** The current Inertia URL, path and query together, e.g. `/figma?tab=all`. */
function useUrl(): string {
    const { url } = usePage();
    return url ?? '/';
}

function splitUrl(url: string): { pathname: string; search: string; hash: string } {
    const hashAt = url.indexOf('#');
    const hash = hashAt === -1 ? '' : url.slice(hashAt);
    const withoutHash = hashAt === -1 ? url : url.slice(0, hashAt);

    const queryAt = withoutHash.indexOf('?');
    const search = queryAt === -1 ? '' : withoutHash.slice(queryAt);
    const pathname = queryAt === -1 ? withoutHash : withoutHash.slice(0, queryAt);

    return { pathname: pathname || '/', search, hash };
}

export interface Location {
    pathname: string;
    search: string;
    hash: string;
    state: unknown;
    key: string;
}

export function useLocation(): Location {
    const url = useUrl();
    return useMemo(() => {
        const { pathname, search, hash } = splitUrl(url);
        // `key` exists so components that use it to force a remount still get a
        // value that changes with the URL.
        return { pathname, search, hash, state: null, key: url };
    }, [url]);
}

export interface NavigateOptions {
    replace?: boolean;
    state?: Record<string, unknown>;
}

export type NavigateFunction = (to: string | number, options?: NavigateOptions) => void;

export function useNavigate(): NavigateFunction {
    return useCallback((to: string | number, options: NavigateOptions = {}) => {
        // react-router spells "go back" as a negative number. Inertia has no
        // equivalent, so this falls through to real session history.
        if (typeof to === 'number') {
            if (typeof window !== 'undefined') window.history.go(to);
            return;
        }

        router.visit(to, {
            replace: options.replace ?? false,
            preserveState: false,
        });
    }, []);
}

/**
 * Route parameters.
 *
 * Laravel resolves the route, so the parameters come from the server as an
 * Inertia prop rather than from a client-side pattern match. A page mounted
 * without them gets an empty object, never a crash.
 */
export function useParams<T extends Record<string, string | undefined> = Record<string, string | undefined>>(): T {
    const { props } = usePage<{ routeParams?: Record<string, string> }>();
    return useMemo(() => ({ ...(props.routeParams ?? {}) }) as T, [props.routeParams]);
}

export type SetSearchParams = (next: URLSearchParams | Record<string, string>, options?: NavigateOptions) => void;

export function useSearchParams(): [URLSearchParams, SetSearchParams] {
    const url = useUrl();
    const { pathname, search } = splitUrl(url);

    const params = useMemo(() => new URLSearchParams(search), [search]);

    const setParams = useCallback<SetSearchParams>(
        (next, options = {}) => {
            const resolved = next instanceof URLSearchParams ? next : new URLSearchParams(next);
            const query = resolved.toString();
            router.visit(query ? `${pathname}?${query}` : pathname, {
                replace: options.replace ?? false,
                preserveState: true,
            });
        },
        [pathname],
    );

    return [params, setParams];
}

export interface LinkProps extends Omit<ComponentProps<typeof InertiaLink>, 'href'> {
    to: string;
    /** Accepted for source compatibility; Inertia always replaces the document. */
    reloadDocument?: boolean;
    style?: CSSProperties;
    children?: ReactNode;
}

/** `<Link to="…">` — react-router's prop name, Inertia's navigation. */
export function Link({ to, reloadDocument: _reloadDocument, ...rest }: LinkProps) {
    return <InertiaLink href={to} {...rest} />;
}

const OutletContext = createContext<ReactNode>(null);

/**
 * Supplies the node that `<Outlet />` renders.
 *
 * This is what lets `figma/app/pages/Root.tsx` — the real Navbar, footer and
 * global stylesheet — be reused exactly as exported, with the Inertia page
 * supplying the body it wraps.
 */
export function OutletProvider({ node, children }: { node: ReactNode; children: ReactNode }) {
    return <OutletContext.Provider value={node}>{children}</OutletContext.Provider>;
}

/**
 * Nested-route outlet.
 *
 * Renders explicit children when given them, otherwise whatever the nearest
 * [OutletProvider] supplies, and nothing at all when there is neither.
 */
export function Outlet({ children }: { children?: ReactNode }) {
    const provided = useContext(OutletContext);
    return <>{children ?? provided ?? null}</>;
}

/** Inertia already restores scroll position; this is a marker, not a behaviour. */
export function ScrollRestoration() {
    return null;
}

export interface RouteObject {
    path?: string;
    index?: boolean;
    Component?: unknown;
    children?: RouteObject[];
}

/**
 * No-op router factory.
 *
 * Kept so `figma/app/routes.ts` and `figma/app/App.tsx` continue to compile.
 * The object it returns is inert: Laravel owns routing.
 */
export function createBrowserRouter(routes: RouteObject[]) {
    return { routes };
}

export function RouterProvider(_props: { router: unknown }) {
    return null;
}
