<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Role;
use Spatie\Permission\PermissionRegistrar;

class RoleSeeder extends Seeder
{
    /**
     * The six roles the platform recognises.
     *
     * Students consume; tutors, mentors and consultants supply the three kinds
     * of one-to-one service; staff and admin run the place. They are seeded
     * rather than created on demand so a role can never be invented by a typo
     * at the call site.
     */
    public const ROLES = [
        'Admin',
        'Student',
        'Tutor',
        'Mentor',
        'Consultant',
        'Staff',
    ];

    public function run(): void
    {
        // Spatie caches the role lookup; seeding without clearing it can leave
        // a stale miss behind in the same process.
        app(PermissionRegistrar::class)->forgetCachedPermissions();

        foreach (self::ROLES as $role) {
            Role::findOrCreate($role, 'web');
        }
    }
}
