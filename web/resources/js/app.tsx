import '../css/app.css';

import { createInertiaApp } from '@inertiajs/react';
import { resolvePageComponent } from 'laravel-vite-plugin/inertia-helpers';
import { createRoot } from 'react-dom/client';
import { route as routeFn } from 'ziggy-js';
import { figmaComponentName, isFigmaPage, withFigmaChrome, type PageModule } from './figma/lib/chrome';
import { initializeTheme } from './hooks/use-appearance';

declare global {
    const route: typeof routeFn;
}

const appName = import.meta.env.VITE_APP_NAME || 'Laravel';

createInertiaApp({
    title: (title) => `${title} - ${appName}`,
    resolve: (name) => {
        // Ported design pages resolve out of figma/app/pages and are wrapped in
        // the design's own chrome. Each one stays a separate chunk.
        if (isFigmaPage(name)) {
            return resolvePageComponent(
                `./figma/app/pages/${figmaComponentName(name)}.tsx`,
                import.meta.glob<PageModule>('./figma/app/pages/*.tsx'),
            ).then((module) => withFigmaChrome(module, name));
        }

        return resolvePageComponent(`./pages/${name}.tsx`, import.meta.glob('./pages/**/*.tsx'));
    },
    setup({ el, App, props }) {
        const root = createRoot(el);

        root.render(<App {...props} />);
    },
    progress: {
        color: '#4B5563',
    },
});

// This will set light / dark mode on load...
initializeTheme();
