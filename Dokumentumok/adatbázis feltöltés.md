##### **Using Seeders and Factories**



1. Seeders: For adding specific, static data (like your main categories or a default admin user).
2. Factories: For generating large amounts of random, fake data for testing (like 50 random products, 100 users, etc.).



###### **Run Your Migration First** - php artisan migrate



Create Seeders for Essential Data

This is for data that your application needs to function. For your shop, the main categories are essential.



###### **A. Create a Seeder File**



**php artisan make:seeder CategorySeeder**

This creates a new file at database/seeders/CategorySeeder.php.



###### **B. Write the Seeder Logic**

Open database/seeders/CategorySeeder.php and add the data you want to insert.

*<?php*



*namespace Database\\Seeders;*



*use Illuminate\\Database\\Console\\Seeds\\WithoutModelEvents;*

*use Illuminate\\Database\\Seeder;*

*use Illuminate\\Support\\Facades\\DB; // Import the DB facade*



*class CategorySeeder extends Seeder*

*{*

    */\*\**

     *\* Run the database seeds.*

     *\*/*

    *public function run(): void*

    *{*

        *// Define the categories we want to insert*

        *$categories = \[*

            *\['nev' => 'Crafts', 'fo\_kategoria\_id' => null],*

            *\['nev' => 'Knitting \& Crochet', 'fo\_kategoria\_id' => 1], // Child of 'Crafts'*

            *\['nev' => 'DIY \& Woodworking', 'fo\_kategoria\_id' => 1], // Child of 'Crafts'*

            *\['nev' => 'Yarn', 'fo\_kategoria\_id' => 2], // Child of 'Knitting \& Crochet'*

            *\['nev' => 'Tools', 'fo\_kategoria\_id' => 2],*

            *\['nev' => 'Hand Tools', 'fo\_kategoria\_id' => 3], // Child of 'DIY \& Woodworking'*

            *\['nev' => 'Materials', 'fo\_kategoria\_id' => 3],*

        *];*



        *// Insert them into the categories table*

        *DB::table('categories')->insert($categories);*

    *}*

*}*



###### **C. Call the Seeder**

Open the main seeder file: database/seeders/DatabaseSeeder.php. You need to tell Laravel to run your new CategorySeeder.



*<?php*



*namespace Database\\Seeders;*



*use Illuminate\\Database\\Seeder;*



*class DatabaseSeeder extends Seeder*

*{*

    */\*\**

     *\* Seed the application's database.*

     *\*/*

    *public function run(): void*

    *{*

        *$this->call(\[*

            *CategorySeeder::class,*

            *// You will add other seeders here, like TagSeeder, ColorSeeder, etc.*

        *]);*

    *}*

*}*



###### **D. Run the Seeder**

Now, execute the seeder command from your terminal: **php artisan db:seed**



##### **Use Factories for Sample Data**



###### **A. Create a Factory**

When you created your Product model, you could have used php artisan make:model Product -f. Let's create it manually now.

**php artisan make:factory ProductFactory --model=Product**

This creates database/factories/ProductFactory.php.



###### **B. Define the Factory**

Open the factory file and define what a fake product should look like.

*<?php*



*namespace Database\\Factories;*



*use Illuminate\\Database\\Eloquent\\Factories\\Factory;*



*/\*\**

 *\* @extends \\Illuminate\\Database\\Eloquent\\Factories\\Factory<\\App\\Models\\Product>*

 *\*/*

*class ProductFactory extends Factory*

*{*

    */\*\**

     *\* Define the model's default state.*

     *\**

     *\* @return array<string, mixed>*

     *\*/*

    *public function definition(): array*

    *{*

        *return \[*

            *'name' => fake()->words(3, true), // e.g., "Soft Wool Yarn"*

            *'description' => fake()->sentence(10),*

            *'sku' => 'PRD-' . fake()->unique()->numerify('######'),*

            *'price' => fake()->randomFloat(2, 5, 100), // Random price between 5 and 100*

            *'stock\_quantity' => fake()->numberBetween(10, 200),*

            *'category\_id' => fake()->numberBetween(4, 7), // Assumes categories 4-7 are leaf nodes*

            *// We'll handle images and tags later in a more advanced seeder*

        *];*

    *}*

*}*



###### **C. Create a Seeder to Use the Factory**

Let's create a seeder that will generate 20 random products. - **php artisan make:seeder ProductSeeder**

Open database/seeders/ProductSeeder.php and use the factory.

*<?php*



*namespace Database\\Seeders;*



*use Illuminate\\Database\\Seeder;*

*use App\\Models\\Product; // Import the Product model*



*class ProductSeeder extends Seeder*

*{*

    */\*\**

     *\* Run the database seeds.*

     *\*/*

    *public function run(): void*

    *{*

        *// Create 20 products using the ProductFactory*

        *Product::factory(20)->create();*

    *}*

*}*



###### **D. Add it to DatabaseSeeder.php and Run**

Don't forget to add ProductSeeder::class to your DatabaseSeeder.php file's $this->call() array.

Run all seeders at once:

**php artisan db:seed**

*Or* 

\# This will drop all tables, re-run all migrations, and then run all seeders

**php artisan migrate:fresh --seed**

This migrate:fresh --seed command will become your best friend during development. It lets you reset your entire database to a perfectly structured and populated state in seconds.











