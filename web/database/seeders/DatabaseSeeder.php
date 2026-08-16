<?php

namespace Database\Seeders;

use App\Models\User;
// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Roles first: the test user below is given one, and assigning a role
        // that has not been seeded throws rather than creating it.
        $this->call(RoleSeeder::class);

        User::factory()
            ->create([
                'name' => 'Test User',
                'email' => 'test@example.com',
            ])
            ->assignRole('Student');
    }
}
