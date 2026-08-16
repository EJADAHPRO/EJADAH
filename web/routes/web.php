<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

Route::middleware(['auth'])->group(function () {
    Route::get('dashboard', function () {
        return Inertia::render('dashboard');
    })->name('dashboard');
});

require __DIR__.'/settings.php';
require __DIR__.'/auth.php';

// Loaded last so the starter kit's authentication keeps `/login`, `/register`
// and `/dashboard`: Laravel matches the first route registered for a path.
require __DIR__.'/figma.php';

// The design's own 404, so an unknown URL still lands inside the site rather
// than on Laravel's exception page.
Route::fallback(function (Request $request) {
    return Inertia::render('figma/NotFound')->toResponse($request)->setStatusCode(404);
});
