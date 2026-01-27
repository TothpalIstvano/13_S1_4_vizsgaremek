<?php

namespace Database\Seeders;

// ADD THIS LINE: Import the Kepek model
use App\Models\Kepek;

use Illuminate\Database\Seeder;

class KepekSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        Kepek::create([
            'url_Link' => 'https://www.gravatar.com/avatar/?d=mp&s=200',
            'alt_Szoveg' => 'Default profile picture',
            'leiras' => 'This is the default profile picture for users without a custom image.'
        ]);
        // Add your images
        $yourImages = [
            [
                'url_Link' => 'blog/default.jpeg',
                'alt_Szoveg' => 'My first blog post main image',
                'leiras' => 'Description of the main image'
            ],
            [
                'url_Link' => 'blog/post1-image1.jpg',
                'alt_Szoveg' => 'Additional image for first post',
                'leiras' => 'Description of additional image'
            ],
            [
                'url_Link' => 'blog/post1-image2.jpg',
                'alt_Szoveg' => 'My first blog post main image',
                'leiras' => 'Description of the main image'
            ],
            [
                'url_Link' => 'blog/post2-main.jpg',
                'alt_Szoveg' => 'Additional image for first post',
                'leiras' => 'Description of additional image'
            ],
            [
                'url_Link' => 'blog/post2-image1.jpg',
                'alt_Szoveg' => 'My first blog post main image',
                'leiras' => 'Description of the main image'
            ],
            [
                'url_Link' => 'blog/post2-image2.jpg',
                'alt_Szoveg' => 'Additional image for first post',
                'leiras' => 'Description of additional image'
            ],
            [
                'url_Link' => 'blog/post3-main.jpg',
                'alt_Szoveg' => 'My first blog post main image',
                'leiras' => 'Description of the main image'
            ],
            [
                'url_Link' => 'blog/post4-main.jpg',
                'alt_Szoveg' => 'Additional image for first post',
                'leiras' => 'Description of additional image'
            ],
            [
                'url_Link' => 'blog/post4-image1.jpg',
                'alt_Szoveg' => 'My first blog post main image',
                'leiras' => 'Description of the main image'
            ]
        ];

        foreach ($yourImages as $image) {
            Kepek::create($image);
        }


        Kepek::factory(100)->create();

        $this->command->info('Kep table seeded with 20 images!');
    }
}