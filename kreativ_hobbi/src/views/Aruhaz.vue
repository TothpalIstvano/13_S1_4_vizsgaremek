<template>
  <div class="app-container">
    <!-- Header -->
    <header>
      <div class="container header-inner">
        <div class="logo">M.SHOPIFY</div>
        <div class="nav-icons">
          <i class="fas fa-search"></i>
          <i class="far fa-heart"></i>
          <i class="fas fa-shopping-bag"></i>
        </div>
      </div>
    </header>

    <!-- Toolbar -->
    <div class="container">
      <div class="toolbar">
        <nav class="breadcrumbs">
          Bags & Backpacks <span>/</span> Decoration <span>/</span> Essentials <span>/</span> Interior
        </nav>

        <div class="controls">
          <!-- Sort (Stays in toolbar) -->
          <select v-model="filters.sortBy" class="sort-select">
            <option value="default">Sort By</option>
            <option value="price-asc">Price: Low to High</option>
            <option value="price-desc">Price: High to Low</option>
          </select>

          <!-- HAMBURGER BUTTON (Triggers Expansion) -->
          <button 
            class="filter-trigger" 
            :class="{ active: isFilterOpen }"
            @click="isFilterOpen = !isFilterOpen"
          >
            <svg class="hamburger-icon" viewBox="0 0 24 24">
              <line x1="3" y1="12" x2="21" y2="12"></line>
              <line x1="3" y1="6" x2="21" y2="6"></line>
              <line x1="3" y1="18" x2="21" y2="18"></line>
            </svg>
            <span class="hamburger-text">Filter</span>
          </button>
        </div>
      </div>
    </div>

    <!-- EXPANDABLE FILTER SECTION (Under Toolbar) -->
    <div class="container">
      <div class="filter-section-wrapper" :class="{ open: isFilterOpen }">
        
        <div class="filter-inner">
          <!-- Color -->
          <div class="filter-block">
            <h4>Color</h4>
            <div class="swatch-list">
              <div 
                v-for="color in colors" 
                :key="color.name"
                class="swatch"
                :style="{ backgroundColor: color.hex }"
                :class="{ active: filters.color === color.name }"
                @click="filters.color = filters.color === color.name ? null : color.name"
                :title="color.name"
              ></div>
            </div>
          </div>

          <!-- Price -->
          <div class="filter-block">
            <h4>Price Range</h4>
            <input type="range" min="0" max="300" v-model.number="filters.maxPrice" class="price-slider">
            <div class="price-display">
              <span>$0</span>
              <span>${{ filters.maxPrice }}</span>
            </div>
            <p style="font-size:11px; color:#999; margin-top:5px;">Price changes are not counted as active filters.</p>
          </div>

          <!-- Tags -->
          <div class="filter-block">
            <h4>Tags</h4>
            <div class="tag-list">
              <span 
                v-for="tag in tags" 
                :key="tag"
                class="tag"
                :class="{ active: filters.tags.includes(tag) }"
                @click="toggleTag(tag)"
              >
                {{ tag }}
              </span>
            </div>
          </div>
          
          <!-- Active Filters (Removable) -->
          <div class="filter-block">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px;">
              <h4>Active Filters ({{ activeFiltersCount }})</h4>
              <button @click="resetFilters" style="font-size:11px; text-decoration:underline; color:#000; font-weight:600;">Reset All</button>
            </div>

            <div v-if="activeFiltersCount === 0" style="font-size:13px; color:#aaa;">
              No specific filters selected.
            </div>

            <!-- CHIPS WITH X -->
            <div v-else class="active-chips">
              <!-- Remove Color Chip -->
              <div v-if="filters.color" class="chip" @click="filters.color = null">
                Color: {{ filters.color }}
                <i class="fas fa-times"></i>
              </div>

              <!-- Remove Tag Chips -->
              <div v-for="tag in filters.tags" :key="tag" class="chip" @click="toggleTag(tag)">
                {{ tag }}
                <i class="fas fa-times"></i>
              </div>
            </div>
          </div>
        </div>

      </div>
    </div>

    <!-- Main Grid -->
    <div class="container">
      <main class="grid">
        
        <article class="card" v-for="product in filteredProducts" :key="product.id">
          
          <div class="card-img">
            <div class="badges">
              <span v-if="product.badges.new" class="badge">New</span>
              <span v-if="product.badges.sale" class="badge sale">{{ product.badges.sale }}</span>
            </div>
            
            <div 
              class="wishlist-icon" 
              @click="product.liked = !product.liked"
            >
              <i :class="product.liked ? 'fas fa-heart' : 'far fa-heart'"></i>
            </div>

            <img 
              :src="product.image" 
              :alt="product.name"
              @error="handleImageError"
            >
          </div>

          <h3 class="card-title">{{ product.name }}</h3>
          
          <div v-if="product.hasOptions" class="select-link">Select options</div>
          <div v-else class="card-price">${{ product.price }}</div>

          <!-- UPDATED: Show all orderable variants for this product -->
          <div class="card-swatches" v-if="product.variants && product.variants.length">
            <span 
              v-for="variant in product.variants" 
              :key="variant.name"
              class="mini-swatch" 
              :style="{ backgroundColor: variant.hex }"
              :class="{ active: filters.color === variant.name }"
              @click="filterByVariant(variant.name)"
              :title="'Order ' + product.name + ' in ' + variant.name"
            ></span>
          </div>

        </article>

      </main>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';

// --- State ---
const isFilterOpen = ref(false);

const filters = ref({
  sortBy: 'default',
  maxPrice: 300,
  color: null,
  tags: []
});

// UPDATED: Added 'variants' array to show orderable colors
const products = ref([
  {
    id: 1,
    name: "Modern Shell Chair",
    price: 139.00,
    hasOptions: false,
    image: "https://images.unsplash.com/photo-1592078615290-033ee584e267?auto=format&fit=crop&q=80&w=600&h=700",
    badges: { new: true, sale: "-18%" },
    colorName: "Black",
    variants: [
      { name: "Black", hex: "#111111" },
      { name: "White", hex: "#ffffff" },
      { name: "Brown", hex: "#8D6E63" } // Added orderable variant
    ],
    liked: false
  },
  {
    id: 2,
    name: "Pendant Lamp",
    price: 0,
    hasOptions: true,
    image: "https://images.unsplash.com/photo-1513506003011-3b03c801992a?auto=format&fit=crop&q=80&w=600&h=700",
    badges: { new: true, sale: null },
    colorName: "Dark Grey",
    variants: [
      { name: "Black", hex: "#222222" },
      { name: "White", hex: "#ffffff" }
    ],
    liked: false
  },
  {
    id: 3,
    name: "Lighthouse Lantern",
    price: 69.00,
    hasOptions: false,
    image: "https://images.unsplash.com/photo-1544367563-12123d8965cd?auto=format&fit=crop&q=80&w=600&h=700",
    badges: { new: true, sale: null },
    colorName: "White",
    variants: [
      { name: "White", hex: "#ffffff" },
      { name: "Brown", hex: "#8D6E63" }
    ],
    liked: false
  },
  {
    id: 4,
    name: "Hans Backpack",
    price: 79.00,
    hasOptions: false,
    image: "https://images.unsplash.com/photo-1553062407-98eeb64c6a62?auto=format&fit=crop&q=80&w=600&h=700",
    badges: { new: false, sale: null },
    colorName: "Army Green",
    variants: [
      { name: "Army Green", hex: "#556B2F" },
      { name: "Black", hex: "#111111" } // Added orderable variant
    ],
    liked: false
  }
]);

const colors = [
  { name: "Black", hex: "#111111" },
  { name: "White", hex: "#ffffff" },
  { name: "Brown", hex: "#8D6E63" },
  { name: "Green", hex: "#556B2F" }
];
const tags = ["Decoration", "Interior", "Essentials", "Bags", "Lighting"];

// --- Methods ---
const toggleTag = (tag) => {
  const idx = filters.value.tags.indexOf(tag);
  if (idx > -1) filters.value.tags.splice(idx, 1);
  else filters.value.tags.push(tag);
};

const handleImageError = (event) => {
  event.target.src = "https://placehold.co/600x700?text=Image+Not+Found";
};

const resetFilters = () => {
  filters.value = { sortBy: 'default', maxPrice: 300, color: null, tags: [] };
}

// Filter by clicking a variant dot on the card
const filterByVariant = (variantName) => {
  if (filters.value.color === variantName) {
    filters.value.color = null;
  } else {
    filters.value.color = variantName;
  }
}

// --- Computed ---
const activeFiltersCount = computed(() => {
  let count = 0;
  if(filters.value.color) count++;
  if(filters.value.tags.length) count++;
  return count;
});

const filteredProducts = computed(() => {
  let res = [...products.value];

  // Price Filter
  res = res.filter(p => (p.price <= filters.value.maxPrice) || p.hasOptions);

  // Color Filter
  if (filters.value.color) {
    res = res.filter(p => 
      // Check if default color matches OR if it has a variant matching the filter
      p.colorName === filters.value.color || 
      p.variants.some(v => v.name === filters.value.color)
    );
  }

  // Tag Filter
  if (filters.value.tags.length > 0) {
    res = res.filter(p => 
      filters.value.tags.some(t => 
        p.name.toLowerCase().includes(t.toLowerCase()) || 
        p.image.includes(t)
      )
    );
  }

  // Sorting
  if (filters.value.sortBy === 'price-asc') res.sort((a,b) => a.price - b.price);
  if (filters.value.sortBy === 'price-desc') res.sort((a,b) => b.price - a.price);

  return res;
});
</script>

<style scoped>
/* --- CSS Variables & Reset --- */
:root {
  --bg-body: #ffffff;
  --text-main: #111;
  --text-muted: #666;
  --border-color: #e5e5e5;
  --transition: all 0.4s cubic-bezier(0.25, 0.8, 0.25, 1);
}

.app-container * { margin: 0; padding: 0; box-sizing: border-box; }

.app-container {
  font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
  background-color: var(--bg-body);
  color: var(--text-main);
  font-size: 14px;
}

a { text-decoration: none; color: inherit; }
ul { list-style: none; }
button { border: none; background: none; cursor: pointer; font-family: inherit; }

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
}

/* --- Header --- */
header {
  padding: 25px 0;
  border-bottom: 1px solid var(--border-color);
  margin-bottom: 20px;
}

.header-inner {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.logo { font-size: 24px; font-weight: 800; text-transform: uppercase; letter-spacing: 1px; }
.nav-icons i { font-size: 18px; margin-left: 25px; color: #333; cursor: pointer; transition: 0.2s; }

/* --- Toolbar --- */
.toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 0;
  margin-bottom: 10px;
}

.breadcrumbs { font-size: 13px; color: var(--text-muted); letter-spacing: 0.5px; }
.breadcrumbs span { margin: 0 8px; color: #ccc; }

.controls { display: flex; align-items: center; gap: 30px; }

/* --- Hamburger Button --- */
.filter-trigger {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 0;
  border: none;
  background: none;
}
.filter-trigger:hover .hamburger-text { text-decoration: underline; }

.hamburger-icon {
  width: 24px;
  height: 24px;
  stroke: #111;
  stroke-width: 2.5;
  stroke-linecap: round;
  stroke-linejoin: round;
  fill: none;
  transition: transform 0.3s;
}
.filter-trigger.active .hamburger-icon { transform: rotate(90deg); }

.hamburger-text {
  font-size: 12px;
  text-transform: uppercase;
  font-weight: 700;
  letter-spacing: 1px;
}

/* Sort Select */
.sort-select {
  font-size: 13px;
  font-weight: 500;
  color: #333;
  padding: 5px 0;
  border-bottom: 1px solid #ddd;
  outline: none;
  cursor: pointer;
}

/* --- EXPANDABLE FILTER SECTION --- */
.filter-section-wrapper {
  background: #fff;
  overflow: hidden;
  max-height: 0;
  opacity: 0;
  transition: max-height 0.5s ease, opacity 0.4s ease;
  border-bottom: 1px solid transparent;
}

.filter-section-wrapper.open {
  max-height: 600px;
  opacity: 1;
  border-bottom: 1px solid var(--border-color);
  margin-bottom: 40px;
}

.filter-inner {
  padding: 30px 0;
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 40px;
}

.filter-block h4 {
  font-size: 12px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 1px;
  margin-bottom: 20px;
  border-bottom: 1px solid #eee;
  padding-bottom: 8px;
}

/* --- ACTIVE FILTER CHIPS WITH X --- */
.active-chips {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin-bottom: 10px;
}

.chip {
  display: inline-flex;
  align-items: center;
  background: #f5f5f5;
  border: 1px solid #ddd;
  padding: 6px 12px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
  color: #333;
  transition: all 0.2s;
  cursor: pointer;
}

.chip:hover {
  background: #e0e0e0;
  border-color: #ccc;
}

.chip i {
  margin-left: 8px;
  color: #888;
  font-size: 10px;
  padding: 2px;
  border-radius: 50%;
  transition: 0.2s;
}

.chip:hover i {
  color: #e74c3c;
  background: #fff;
}

/* Swatches (Sidebar) */
.swatch-list { display: flex; gap: 12px; flex-wrap: wrap; }
.swatch {
  width: 30px; height: 30px;
  border-radius: 50%;
  cursor: pointer;
  border: 1px solid #eee;
  position: relative;
  transition: transform 0.2s;
}
.swatch:hover { transform: scale(1.1); }
.swatch.active { border-color: #000; box-shadow: 0 0 0 2px rgba(0,0,0,0.1); }

/* Price Slider */
.price-slider { width: 100%; margin: 15px 0; accent-color: #000; }
.price-display { display: flex; justify-content: space-between; font-size: 13px; color: #777; }

/* Tags */
.tag-list { display: flex; flex-wrap: wrap; gap: 8px; }
.tag {
  font-size: 12px;
  padding: 6px 12px;
  border: 1px solid #eee;
  border-radius: 20px;
  cursor: pointer;
  transition: 0.2s;
  color: #555;
}
.tag:hover, .tag.active { background: #000; color: #fff; border-color: #000; }

/* --- Product Grid --- */
.grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 30px;
  margin-bottom: 80px;
}

/* Card */
.card { position: relative; }

.card-img {
  position: relative;
  padding-top: 115%;
  background: #f0f0f0;
  margin-bottom: 15px;
  overflow: hidden;
  border: 1px solid #f0f0f0;
}

.card-img img {
  position: absolute;
  top: 0; left: 0; width: 100%; height: 100%;
  object-fit: cover;
  transition: transform 0.6s ease;
}
.card:hover .card-img img { transform: scale(1.03); }

.badges {
  position: absolute; top: 10px; left: 10px;
  display: flex; flex-direction: column; gap: 4px;
  z-index: 2;
}
.badge {
  font-size: 10px; font-weight: 700; text-transform: uppercase;
  padding: 4px 8px; background: #000; color: #fff;
  border-radius: 2px;
}
.badge.sale { background: #e74c3c; }

.wishlist-icon {
  position: absolute; top: 10px; right: 10px;
  width: 30px; height: 30px;
  background: rgba(255,255,255,0.9);
  border-radius: 50%;
  display: flex; align-items: center; justify-content: center;
  cursor: pointer; z-index: 2;
  font-size: 14px; color: #aaa; transition: 0.2s;
}
.wishlist-icon:hover, .wishlist-icon.active { color: #e74c3c; background: #fff; }

.card-title { font-size: 15px; font-weight: 500; margin-bottom: 6px; line-height: 1.4; }
.card-price { font-weight: 700; color: #000; }
.select-link { color: #0066cc; text-decoration: underline; font-size: 13px; cursor: pointer; }

/* UPDATED: Product Card Swatches (Variants) */
.card-swatches {
  display: flex;
  gap: 8px;
  margin-top: 12px;
  justify-content: center;
}

.mini-swatch {
  width: 16px;
  height: 16px;
  border-radius: 50%;
  border: 1px solid #ddd;
  display: inline-block;
  cursor: pointer;
  transition: all 0.2s;
}

.mini-swatch:hover {
  transform: scale(1.2);
  border-color: #999;
}

/* Active state for mini swatch (when filtered by this color) */
.mini-swatch.active {
  border-color: #000;
  box-shadow: 0 0 0 2px rgba(0,0,0,0.2);
  transform: scale(1.1);
}

/* Responsive */
@media (max-width: 1024px) { .grid { grid-template-columns: repeat(3, 1fr); } .filter-inner { grid-template-columns: repeat(2, 1fr); } }
@media (max-width: 768px) { 
  .grid { grid-template-columns: repeat(2, 1fr); } 
  .filter-inner { grid-template-columns: 1fr; }
}
@media (max-width: 480px) { .grid { grid-template-columns: 1fr; } }
</style>