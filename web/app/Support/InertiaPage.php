<?php

namespace App\Support;

use Illuminate\Support\Str;

class InertiaPage
{
    /**
     * The prefix Inertia page names carry for pages ported from the design.
     */
    public const FIGMA_PREFIX = 'figma/';

    /**
     * The Vite entrypoint for an Inertia page name.
     *
     * The starter kit assumes every page sits under `resources/js/pages`. The
     * ported design does not — it keeps its original structure under
     * `resources/js/figma/app/pages` so the export stays diffable against
     * future Figma output. This maps a page name to whichever of the two it is,
     * which is what lets Blade preload the right chunk.
     */
    public static function entrypoint(string $component): string
    {
        if (Str::startsWith($component, self::FIGMA_PREFIX)) {
            $page = Str::after($component, self::FIGMA_PREFIX);

            return "resources/js/figma/app/pages/{$page}.tsx";
        }

        return "resources/js/pages/{$component}.tsx";
    }
}
