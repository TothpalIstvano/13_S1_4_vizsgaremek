<?php

namespace Database\Seeders;

use App\Models\Posztok;
use Illuminate\Database\Seeder;

class PosztokSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Your custom posts
        $yourPosts = [
            [
                'cim' => 'My First Blog Post',
                'kivonat' => 'A brief excerpt of my first post...',
                'tartalom' => '<h2>Full HTML content here</h2><p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris pulvinar euismod velit sit amet finibus. Morbi lobortis dui quam, non tincidunt metus viverra a. Proin faucibus enim quis cursus tempor. Suspendisse dignissim tempor magna. Integer dictum massa non dui luctus congue. Aenean placerat purus magna, vel porttitor libero iaculis at. Mauris vehicula quam neque, non varius mauris euismod sed. In accumsan sodales mi, gravida laoreet dolor tempor dapibus.</p>
                ',
                'szerzo_id' => 1, // Your user ID
                'fo_kep_id' => 1, // ID of your main image from kepek table
                'letrehozas_datuma' => now(),
                'statusz' => 'közzétett'
            ],
            [
                'cim' => 'Second Blog Post',
                'kivonat' => 'Maecenas ultricies tincidunt mi quis ullamcorper. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.',
                'tartalom' => '<p>Sed rhoncus quis dolor id efficitur. Donec malesuada interdum libero, vel elementum nibh molestie non. Vestibulum convallis nibh velit, in suscipit sapien dictum nec. Praesent dignissim orci in purus maximus, nec varius magna efficitur. Aenean massa justo, molestie ut auctor in, tempus ac turpis. Aliquam et ligula vel neque tempor mollis vitae consectetur eros. Phasellus commodo arcu vel ex consectetur malesuada. Mauris ultrices sem metus, a porta ante tincidunt eget.
                <ul>
                    <li>Coffee</li>
                    <li>Tea</li>
                    <li>Milk</li>
                </ul>
                </p>',
                'szerzo_id' => 1,
                'fo_kep_id' => 4,
                'letrehozas_datuma' => now()->subDays(3),
                'statusz' => 'közzétett'
            ],
            [
                'cim' => 'Third Blog Post (ugyanaz)',
                'kivonat' => 'Maecenas ultricies tincidunt mi quis ullamcorper. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.',
                'tartalom' => '<p>Sed rhoncus quis dolor id efficitur. Donec malesuada interdum libero, vel elementum nibh molestie non. Vestibulum convallis nibh velit, in suscipit sapien dictum nec. Praesent dignissim orci in purus maximus, nec varius magna efficitur. Aenean massa justo, molestie ut auctor in, tempus ac turpis. Aliquam et ligula vel neque tempor mollis vitae consectetur eros. Phasellus commodo arcu vel ex consectetur malesuada. Mauris ultrices sem metus, a porta ante tincidunt eget.</p>',
                'szerzo_id' => 1,
                'fo_kep_id' => 8,
                'letrehozas_datuma' => now()->subDays(5),
                'statusz' => 'közzétett'
            ],
            // Add more posts...
        ];

        foreach ($yourPosts as $post) {
            Posztok::create($post);
        }

        // Optional: Keep some fake data
        Posztok::factory(5)->create(); // Reduced from 30
        $this->command->info('Posztok table seeded successfully!');
    }
}
