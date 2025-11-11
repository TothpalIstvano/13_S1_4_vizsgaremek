##### **Phase 1: Prerequisites \& Environment Setup**

Before you begin, make sure you have the following installed on your system:



1. PHP (v8.1 or newer): The core of Laravel.
2. Composer: The dependency manager for PHP.
3. Node.js \& npm: For managing frontend dependencies (Vue.js).
4. A Database: MySQL or PostgreSQL are the most common choices for Laravel.
5. A Local Development Environment (Optional but Recommended): nálunk Ampps



##### **Phase 2: Database Setup**

Phpmyadminba csak az adatbázist hozzuk létre, ne töltsük fel táblákkal



Ha fancyk akarunk lenni:

-- Create the database itself

CREATE DATABASE your\_db\_name CHARACTER SET utf8mb4 COLLATE utf8mb4\_unicode\_ci;



-- Create a user that Laravel will use to connect

CREATE USER 'your\_db\_user'@'localhost' IDENTIFIED BY 'your\_password';



-- Grant all permissions on the new database to the new user

GRANT ALL PRIVILEGES ON your\_db\_name.\* TO 'your\_db\_user'@'localhost';



-- Apply the changes

FLUSH PRIVILEGES;



##### **Phase 3: Laravel Backend Setup**

Új Laravel projekt: **composer create-project laravel/laravel kreativhobbi**

**cd kreativhobbi**

Laravel .env fájlban változások (ehhez és a többihez segítség a laravel setup.txt fájlban)



##### **Phase 4: Translating Your Schema to Laravel (Migrations \& Models)**

A mappa/projekt termináljába:

\# Users table already exists, so we modify it

**php artisan make:migration add\_name\_fields\_to\_users\_table --table=users**



\# Create all other tables

**php artisan make:migration create\_kepek\_table**

**php artisan make:migration create\_cimkek\_table**

**php artisan make:migration create\_kategoriak\_table**

**php artisan make:migration create\_szinek\_table**

**php artisan make:migration create\_posztok\_table**

**php artisan make:migration create\_termekek\_table**

**php artisan make:migration create\_poszt\_kepek\_table**

**php artisan make:migration create\_termek\_kepek\_table**

**php artisan make:migration create\_poszt\_cimkek\_table**

**php artisan make:migration create\_termek\_cimkek\_table**

**php artisan make:migration create\_termek\_szinek\_table**

**php artisan make:migration create\_kommentek\_table**

**php artisan make:migration create\_poszt\_reakciok\_table**

**php artisan make:migration create\_kedvencek\_table**



Open the newly created migration files in database/migrations/. You need to write the schema inside the up() method.



Például a database/migrations/YYYY\_MM\_DD\_HHMMSS\_create\_termekek\_table.php-ba:

*<?php*



*use Illuminate\\Database\\Migrations\\Migration;*

*use Illuminate\\Database\\Schema\\Blueprint;*

*use Illuminate\\Support\\Facades\\Schema;*



*return new class extends Migration*

*{*

&nbsp;   \*public function up(): void\*

    \*{\*

        \*Schema::create('products', function (Blueprint $table) {\*

            \*$table->id();\*

            \*$table->string('nev');\*

            \*$table->text('leiras')->nullable();\*

            \*$table->decimal('ar', 10, 2);\*

            \*$table->integer('darab')->default(0);\*

            \*$table->foreignId('kategoria\\\_id')->nullable()->constrained('kategoriak')->onDelete('set null');\*

            \*$table->foreignId('fo\\\_kep\\\_id')->nullable()->constrained('kepek')->onDelete('set null');\*

            \*$table->timestamps();\*

        \*});\*

    \*}\*



    \*public function down(): void\*

    \*{\*

        \*Schema::dropIfExists('products');\*

    \*}\*


*};*



Key Points:



$table->id() is shorthand for a primary key.

$table->foreignId('column\_name')->constrained('table\_name') creates a foreign key that references the id on the specified table. This is much cleaner than raw SQL.

->onDelete('set null') or ->onDelete('cascade') defines the behavior when the parent record is deleted.

You will need to do this for all your migration files, carefully translating the SQL schema we designed.



###### **Create models**

Models are PHP classes that represent your database tables and allow you to interact with your data.



**php artisan make:model Image -m**

**php artisan make:model Tag -m**

**php artisan make:model Category -m**

\# ... and so on for all tables

(The -m flag also creates a migration file, which is handy if you're doing this from scratch.)



Now, open the generated model files in app/Models/ and define the relationships.

Például app/Models/Product.php-ba:

*<?php*



*namespace App\\Models;*



*use Illuminate\\Database\\Eloquent\\Factories\\HasFactory;*

*use Illuminate\\Database\\Eloquent\\Model;*



*class Product extends Model*

*{*

&nbsp;   \*use HasFactory;\*



    \*protected $fillable = \\\[\*

        \*'name', 'description', 'sku', 'price', 'stock\\\_quantity', 'category\\\_id', 'featured\\\_image\\\_id'\*

    \*];\*



    \*// A product belongs to one category\*

    \*public function category()\*

    \*{\*

        \*return $this->belongsTo(Category::class);\*

    \*}\*



    \*// A product belongs to one featured image\*

    \*public function featuredImage()\*

    \*{\*

        \*return $this->belongsTo(Image::class, 'featured\\\_image\\\_id');\*

    \*}\*



    \*// A product can have many gallery images (many-to-many)\*

    \*public function images()\*

    \*{\*

        \*return $this->belongsToMany(Image::class, 'product\\\_images')->withPivot('sort\\\_order');\*

    \*}\*



    \*// A product can have many tags (many-to-many)\*

    \*public function tags()\*

    \*{\*

        \*return $this->belongsToMany(Tag::class, 'product\\\_tags');\*

    \*}\*



    \*// A product can have many colors (many-to-many)\*

    \*public function colors()\*

    \*{\*

        \*return $this->belongsToMany(Color::class, 'product\\\_colors');\*

    \*}\*



    \*// A product can be favorited by many users (many-to-many)\*

    \*public function favoritedBy()\*

    \*{\*

        \*return $this->belongsToMany(User::class, 'user\\\_favorites');\*

    \*}\*


*}*



You will need to define the inverse and other relationships for all your models (e.g., Category has many Products, User has many Comments, etc.).



###### **Run Migrations**

Once all your migrations and models are set up, run this command to create the tables in your database:

**php artisan migrate**



You can now check your database, and you will see all the tables have been created with the correct columns and relationships!



##### **Phase 5: Building the API**

Laravel will serve as a RESTful API for your Vue frontend.



###### **Create a Controller**

Controllers handle incoming requests and return responses.

**php artisan make:controller Api/ProductController --api**

(The --api flag scaffolds the controller with empty methods for index, store, show, update, destroy.)



Open app/Http/Controllers/Api/ProductController.php and fill in the index method to fetch products.

*<?php*



*namespace App\\Http\\Controllers\\Api;*



*use App\\Http\\Controllers\\Controller;*

*use App\\Models\\Product;*

*use Illuminate\\Http\\Request;*



*class ProductController extends Controller*

*{*

&nbsp;   \*/\\\*\\\*\*

     \*\\\* Display a listing of the resource.\*

     \*\\\*/\*

    \*public function index()\*

    \*{\*

        \*// Eager load relationships to avoid N+1 problems\*

        \*$products = Product::with(\\\['category', 'featuredImage', 'tags', 'colors'])->get();\*

        \*return response()->json($products);\*

    \*}\*



    \*// ... other methods (show, store, etc.)\*


*}*



###### **Define API Routes**

Open routes/api.php and define the route for your products.

*<?php*



*use Illuminate\\Http\\Request;*

*use Illuminate\\Support\\Facades\\Route;*

*use App\\Http\\Controllers\\Api\\ProductController;*



*// ... other routes*



*Route::apiResource('products', ProductController::class);*



##### **Phase 6: Vue.js Frontend Setup**

Navigate to your Vue project's root directory in the terminal and install Axios, which we'll use to make HTTP requests.

\# Make sure you are in your existing Vue project folder

**npm install axios**



###### **Create a Pinia Store for Products**

1. Create a new file: src/stores/productsStore.js.
2. Add the following code to set up the store with an action to fetch products.

*// src/stores/productsStore.js*

*import { defineStore } from 'pinia';*

*import axios from 'axios';*



*// Create an Axios instance with base URL and other defaults*

*const apiClient = axios.create({*

*baseURL: 'http://localhost:8000/api', // Your Laravel API URL*

*headers: {*

&nbsp;   \*'Accept': 'application/json',\*

    \*'Content-Type': 'application/json',\*


*}*

*});*



*export const useProductsStore = defineStore('products', {*

*state: () => ({*

&nbsp;   \*products: \\\[],\*

    \*loading: false,\*

    \*error: null,\*


*}),*



*actions: {*

&nbsp;   \*async fetchProducts() {\*

      \*this.loading = true;\*

      \*this.error = null;\*

      \*try {\*

        \*const response = await apiClient.get('/products');\*

        \*this.products = response.data;\*

      \*} catch (error) {\*

        \*this.error = 'Failed to fetch products. Please try again.';\*

        \*console.error("Error fetching products:", error);\*

      \*} finally {\*

        \*this.loading = false;\*

      \*}\*

    \*},\*


*},*

*});*



###### **Create a Products View Component**

Egy alap kinézet az áruház részre Piniát használva:

*<!-- src/views/ProductsView.vue -->*

*<script setup>*

*import { onMounted } from 'vue';*

*import { useProductsStore } from '@/stores/productsStore';*



*const productsStore = useProductsStore();*



*// Fetch products when the component is mounted*

*onMounted(() => {*

*productsStore.fetchProducts();*

*});*

*</script>*



*<template>*

*<div>*

&nbsp;   \*<h1>Our Products</h1>\*



    \*<!-- Loading state -->\*

    \*<div v-if="productsStore.loading">Loading products...</div>\*



    \*<!-- Error state -->\*

    \*<div v-if="productsStore.error" class="error">{{ productsStore.error }}</div>\*



    \*<!-- Products list -->\*

    \*<div v-if="!productsStore.loading \\\&\\\& !productsStore.error" class="product-grid">\*

      \*<div v-for="product in productsStore.products" :key="product.id" class="product-card">\*

        \*<img v-if="product.featured\\\_image" :src="`http://localhost:8000/storage/${product.featured\\\_image.url}`" :alt="product.featured\\\_image.alt\\\_text" />\*

        \*<h2>{{ product.name }}</h2>\*

        \*<p class="price">${{ product.price }}</p>\*

        \*<p>{{ product.description }}</p>\*

        \*<div class="tags">\*

          \*<span v-for="tag in product.tags" :key="tag.id" class="tag">{{ tag.name }}</span>\*

        \*</div>\*

      \*</div>\*

    \*</div>\*


*</div>*

*</template>*



*<style scoped>*

*.product-grid {*

*display: grid;*

*grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));*

*gap: 20px;*

*}*

*//meg a többi style dolgok*

*</style>*



Route hozzáadása - ✅



##### **Phase 7: Handle CORS and Run the Applications**

Your Vue app (e.g., on localhost:5173) and Laravel API (on localhost:8000) are on different origins. You must tell Laravel it's okay to accept requests from your Vue app.



1. In your kreativhobbi project, open config/cors.php.
2. Add your Vue app's URL to the allowed\_origins array.

*// config/cors.php*

*return \[*

&nbsp;   \*// ...\*

    \*'paths' => \\\['api/\\\*', 'sanctum/csrf-cookie'],\*



    \*'allowed\\\_methods' => \\\['\\\*'],\*



    \*'allowed\\\_origins' => \\\[\*

        \*'http://localhost:5173', // Add your Vue dev server URL here\*

    \*],\*



    \*'allowed\\\_origins\\\_patterns' => \\\[],\*



    \*'allowed\\\_headers' => \\\['\\\*'],\*



    \*'exposed\\\_headers' => \\\[],\*



    \*'max\\\_age' => 0,\*



    \*'supports\\\_credentials' => false,\*


*];*



###### **Run Both Applications**

You need two terminal windows.



1. Terminal 1 (Backend): Navigate to kreativhobbi and start the Laravel server. - php artisan serve
2. Terminal 2 (Frontend): Navigate to your existing Vue project and start the dev server. - npm run dev



Így ha megnyitjuk a Vue-t, akkor látni kéne a termékeket amik Laravelen keresztül jöttek az adatbázisból

