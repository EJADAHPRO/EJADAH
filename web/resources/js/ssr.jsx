/* prettier-ignore */
import {
createInertiaApp
} from '@inertiajs/react';
import createServer from '@inertiajs/react/server';
import ReactDOMServer from 'react-dom/server';
import { figmaComponentName, isFigmaPage, withFigmaChrome } from './figma/lib/chrome';

createServer((page) =>
    createInertiaApp({
        page,
        render: ReactDOMServer.renderToString,
        resolve: (name) => {
            if (isFigmaPage(name)) {
                const figma = import.meta.glob('./figma/app/pages/*.tsx', {
                    eager: true,
                });
                return withFigmaChrome(figma[`./figma/app/pages/${figmaComponentName(name)}.tsx`], name);
            }

            const pages = import.meta.glob('./pages/**/*.tsx', {
                eager: true,
            });
            return pages[`./pages/${name}.tsx`];
        },
        // prettier-ignore
        setup: ({ App, props }) => <App {...props} />,
    }),
);
