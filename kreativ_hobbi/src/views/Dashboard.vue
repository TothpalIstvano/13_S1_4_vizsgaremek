<template>
  <div class="dashboard-wrapper">
    <!-- Sidebar -->
    <div class="sidebar">
      <div class="sidebar-header">
        <h1>🎨 Kreatív Hobbi</h1>
        <p>Admin Dashboard</p>
      </div>
      <ul class="nav-menu">
        <li class="nav-item">
          <a class="nav-link" :class="{active: currentView === 'dashboard'}" @click="currentView = 'dashboard'">
            <span class="nav-icon">📊</span>
            Dashboard
          </a>
        </li>
        <li class="nav-item">
          <a class="nav-link" :class="{active: currentView === 'products'}" @click="currentView = 'products'">
            <span class="nav-icon">🛍️</span>
            Termékek
          </a>
        </li>
        <li class="nav-item">
          <a class="nav-link" :class="{active: currentView === 'blog'}" @click="currentView = 'blog'">
            <span class="nav-icon">📝</span>
            Blog Bejegyzések
          </a>
        </li>
        <li class="nav-item">
          <a class="nav-link" :class="{active: currentView === 'users'}" @click="currentView = 'users'">
            <span class="nav-icon">👤</span>
            Felhasznalok
          </a>
        </li>
        <li class="nav-item">
          <a class="nav-link" :class="{active: currentView === 'analytics'}" @click="currentView = 'analytics'">
            <span class="nav-icon">📈</span>
            Analitika
          </a>
        </li>
      </ul>
    </div>

    <!-- Main Content -->
    <main class="main-content">
      <!-- Dashboard View -->
      <div v-if="currentView === 'dashboard'">
        <div class="header">
          <h2>Dashboard</h2>
          <div class="header-actions">
            <button class="btn btn-primary" @click="refreshData">
              🔄 Frissítés
            </button>
          </div>
        </div>

        <!-- Stats Cards -->
        <div class="stats-grid">
          <div class="stat-card">
            <div class="stat-header">
              <div>
                <div class="stat-title">Összes Értékesítés</div>
              </div>
              <div class="stat-icon" style="background: #dbeafe; color: #1e40af;">
                💰
              </div>
            </div>
            <div class="stat-value">{{ formatCurrency(stats.totalSales) }}</div>
            <div class="stat-change positive">↑ 12.5% az elmúlt hónaphoz képest</div>
          </div>

          <div class="stat-card">
            <div class="stat-header">
              <div>
                <div class="stat-title">Rendelések</div>
              </div>
              <div class="stat-icon" style="background: #dcfce7; color: #166534;">
                📦
              </div>
            </div>
            <div class="stat-value">{{ stats.totalOrders }}</div>
            <div class="stat-change positive">↑ 8.2% az elmúlt hónaphoz képest</div>
          </div>

          <div class="stat-card">
            <div class="stat-header">
              <div>
                <div class="stat-title">Termékek</div>
              </div>
              <div class="stat-icon" style="background: #fef3c7; color: #92400e;">
                🛍️
              </div>
            </div>
            <div class="stat-value">{{ stats.totalProducts }}</div>
            <div class="stat-change positive">↑ 3 új termék</div>
          </div>

          <div class="stat-card">
            <div class="stat-header">
              <div>
                <div class="stat-title">Vásárlók</div>
              </div>
              <div class="stat-icon" style="background: #e9d5ff; color: #6b21a8;">
                👥
              </div>
            </div>
            <div class="stat-value">{{ stats.totalCustomers }}</div>
            <div class="stat-change positive">↑ 15.3% új regisztrációk</div>
          </div>
        </div>

        <!-- Charts -->
        <div class="charts-grid">
          <div class="chart-card">
            <div class="chart-header">
              <h3 class="chart-title">Havi Értékesítés</h3>
            </div>
            <canvas ref="salesChart"></canvas>
          </div>

          <div class="chart-card">
            <div class="chart-header">
              <h3 class="chart-title">Kategóriák szerinti termék megosztás</h3>
            </div>
            <canvas ref="categoryChart"></canvas>
          </div>
        </div>

        <!-- Recent Orders -->
        <div class="table-container">
          <div class="table-header">
            <h3 class="table-title">Legújabb Rendelések</h3>
          </div>
          <table>
            <thead>
              <tr>
                <th>Rendelés ID</th>
                <th>Vásárló</th>
                <th>Termékek</th>
                <th>Összeg</th>
                <th>Státusz</th>
                <th>Dátum</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="order in recentOrders" :key="order.id">
                <td><strong>#{{ order.id }}</strong></td>
                <td>{{ order.customer }}</td>
                <td>{{ order.items }}</td>
                <td><strong>{{ formatCurrency(order.total) }}</strong></td>
                <td>
                  <span class="badge" :class="getOrderBadgeClass(order.status)">
                    {{ order.status }}
                  </span>
                </td>
                <td>{{ order.date }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Products View -->
      <div v-if="currentView === 'products'">
        <div class="header">
          <h2>Termékek</h2>
          <div class="header-actions">
            <button class="btn btn-primary" @click="openProductModal()">
              ➕ Új Termék
            </button>
          </div>
        </div>

        <div class="table-container">
          <div class="table-header">
            <h3 class="table-title">Összes Termék</h3>
            <div class="search-box">
              <input 
                type="text" 
                class="search-input" 
                placeholder="Keresés termékek között..."
                v-model="productSearch"
              >
            </div>
          </div>
          <table>
            <thead>
              <tr>
                <th>Kép</th>
                <th>Név</th>
                <th>Kategória</th>
                <th>Ár</th>
                <th>Készlet</th>
                <th>Státusz</th>
                <th>Műveletek</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="product in filteredProducts" :key="product.id">
                <td>
                  <img :src="product.image" :alt="product.name" class="product-img">
                </td>
                <td><strong>{{ product.name }}</strong></td>
                <td>{{ product.category }}</td>
                <td><strong>{{ formatCurrency(product.price) }}</strong></td>
                <td>{{ product.stock }} db</td>
                <td>
                  <span class="badge" :class="product.stock > 10 ? 'badge-success' : product.stock > 0 ? 'badge-warning' : 'badge-danger'">
                    {{ product.stock > 10 ? 'Raktáron' : product.stock > 0 ? 'Kevés' : 'Nincs készleten' }}
                  </span>
                </td>
                <td>
                  <div class="action-buttons">
                    <button class="btn btn-sm btn-warning" @click="openProductModal(product)">
                      ✏️
                    </button>
                    <button class="btn btn-sm btn-danger" @click="deleteProduct(product.id)">
                      🗑️
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Users View -->
      <div v-if="currentView === 'users'">
        <div class="header">
          <h2>Felhasználók</h2>
          <div class="header-actions">
            <button class="btn btn-primary" @click="openUserModal()">
              ➕ Új felhasználó
            </button>
          </div>
        </div>

        <div class="table-container">
          <div class="table-header">
            <h3 class="table-title">Összes felhasználó</h3>
            <div class="search-box">
              <input 
                type="text" 
                class="search-input" 
                placeholder="Keresés felhasználók között..."
                v-model="userSearch"
              >
            </div>
          </div>
          <table>
            <thead>
              <tr>
                <th>Profilkép</th>
                <th>Név</th>
                <th>Szerepkör</th>
                <th>Email</th>
                <th>Aktív</th>
                <th>Rendelések</th>
                <th>Regisztráció ideje</th>
                <th>Útolsó bejelentkezés</th>
                <th>Műveletek</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="user in filteredUsers" :key="user.id">
                <td>
                  <img :src="user.profileImage" :alt="user.name" class="avatar">
                </td>
                <td><strong>{{ user.name }}</strong></td>
                <td>
                  <span class="badge" :class="user.role === 'admin' ? 'badge-blue' : user.role === 'moderator' ? 'badge-warning' : user.role === 'sima' ? 'badge-success' : 'badge-danger'">
                    {{user.role}}
                  </span>
                </td>
                <td>{{ user.email }}</td>
                <td>
                  <span class="badge" :class="user.active ? 'badge-success' : 'badge-danger'">
                    {{ user.active ? 'Aktív' : 'Inaktív' }}
                  </span>
                </td>
                <td>
                  <div v-if="user.orderStats?.total > 0" style="display:flex; flex-direction:column; gap:4px;">
                    <span class="badge" :class="user.orderStats.active > 0 ? 'badge-warning' : 'badge-success'">
                      {{ user.orderStats.active > 0 ? `⚠️ ${user.orderStats.active} aktív` : '✅ Mind teljesítve' }}
                    </span>
                    <small style="color:#6b7280; font-size:11px;">
                      Utolsó: <strong>{{ 
                        user.orderStats.lastStatus === 'törölve' ? '🚫 Törölve' :
                        user.orderStats.lastStatus === 'teljesítve' ? '✅ Teljesítve' :
                        user.orderStats.lastStatus === 'függőben' ? '⏳ Függőben' :
                        user.orderStats.lastStatus === 'szállítás alatt' ? '🚚 Szállítás alatt' :
                        user.orderStats.lastStatus ?? '-'
                      }}</strong>
                    </small>
                    <small style="color:#94a3b8; font-size:11px;">  
                      Összesen: {{ user.orderStats.total }} db
                    </small>
                  </div>
                  <span v-else style="color:#94a3b8; font-size:13px;">Nincs rendelés</span>
                </td>
                <td>{{ user.registrationDate ? formatDate(user.registrationDate) : '-' }}</td>
                <td>{{ user.utolso_Belepes ? formatDate(user.utolso_Belepes) : '-' }}</td>
                <td>
                  <div class="action-buttons">
                    <button class="btn btn-sm btn-warning" 
                      @click="openUserModal(user)"       
                      :disabled="user.id === currentUserId"
                      :style="user.id === currentUserId ? 'opacity: 0.4; cursor: not-allowed;' : ''"
                      :title="user.id === currentUserId ? 'Saját fiókod nem módosíthatod' : ''"
                    >
                      ✏️
                    </button>
                    <button class="btn btn-sm btn-danger" 
                      @click="deleteUser(user.id)"
                      :disabled="user.id === currentUserId || user.orderStats.active > 0"
                      :style="user.id === currentUserId || user.orderStats.active > 0 ? 'opacity: 0.4; cursor: not-allowed;' : ''"
                      :title="user.id === currentUserId || user.orderStats.active > 0 ? 'Saját fiókod nem törölheted' : ''"
                    >
                      🗑️
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Blog View -->
      <div v-if="currentView === 'blog'">
        <div class="header">
          <h2>Blog Bejegyzések</h2>
          <div class="header-actions">
            <button class="btn btn-primary" @click="openBlogModal()">
              ➕ Új Bejegyzés
            </button>
          </div>
        </div>

        <div class="table-container">
          <div class="table-header">
            <h3 class="table-title">Összes Bejegyzés</h3>
            <div class="search-box">
              <input 
                type="text" 
                class="search-input" 
                placeholder="Keresés bejegyzések között..."
                v-model="blogSearch"
              >
            </div>
          </div>
          <table>
            <thead>
              <tr>
                <th>Cím</th>
                <th>Szerző</th>
                <th>Kategória</th>
                <th>Dátum</th>
                <th>Státusz</th>
                <th>Műveletek</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="post in filteredBlogPosts" :key="post.id">
                <td><strong>{{ post.title }}</strong></td>
                <td>{{ post.author }}</td>
                <td>{{ post.category }}</td>
                <td>{{ post.date }}</td>
                <td>
                  <span class="badge" :class="post.published ? 'badge-success' : 'badge-warning'">
                    {{ post.published ? 'Publikálva' : 'Piszkozat' }}
                  </span>
                </td>
                <td>
                  <div class="action-buttons">
                    <button class="btn btn-sm btn-warning" @click="openBlogModal(post)">
                      ✏️
                    </button>
                    <button class="btn btn-sm btn-danger" @click="deleteBlogPost(post.id)">
                      🗑️
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Analytics View -->
      <div v-if="currentView === 'analytics'">
        <div class="header">
          <h2>Analitika</h2>
        </div>

        <div class="charts-grid" style="grid-template-columns: 1fr;">
          <div class="chart-card">
            <div class="chart-header">
              <h3 class="chart-title">Eladott Termékek Havi Bontásban</h3>
            </div>
            <canvas ref="productSalesChart"></canvas>
          </div>

          <div class="chart-card">
            <div class="chart-header">
              <h3 class="chart-title">Bevétel Havi Trendje</h3>
            </div>
            <canvas ref="revenueChart"></canvas>
          </div>
        </div>
      </div>
    </main>

    <!-- Product Modal (Simple - kept original) -->
    <div v-if="showProductModal" class="modal-overlay" @click.self="showProductModal = false">
      <div class="modal">
        <div class="modal-header">
          <h3 class="modal-title">{{ editingProduct.id ? 'Termék Szerkesztése' : 'Új Termék' }}</h3>
          <button class="btn btn-icon" @click="showProductModal = false">✕</button>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label class="form-label">Termék Neve</label>
            <input type="text" class="form-input" v-model="editingProduct.name" placeholder="pl. Kötőfonal 100g">
          </div>
          <div class="form-group">
            <label class="form-label">Kategória</label>
            <select class="form-select" v-model="editingProduct.category">
              <option>Fonalak</option>
              <option>Kötőtűk</option>
              <option>Horgolótűk</option>
              <option>Hímzőfonalak</option>
              <option>Kellékek</option>
              <option>Minták</option>
            </select>
          </div>
          <div class="form-group">
            <label class="form-label">Ár (Ft)</label>
            <input type="number" class="form-input" v-model="editingProduct.price" placeholder="2990">
          </div>
          <div class="form-group">
            <label class="form-label">Készlet (db)</label>
            <input type="number" class="form-input" v-model="editingProduct.stock" placeholder="50">
          </div>
          <div class="form-group">
            <label class="form-label">Kép URL</label>
            <input type="text" class="form-input" v-model="editingProduct.image" placeholder="https://...">
          </div>
          <div class="form-group">
            <label class="form-label">Leírás</label>
            <textarea class="form-textarea" v-model="editingProduct.description" placeholder="Termék leírása..."></textarea>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn" @click="showProductModal = false">Mégse</button>
          <button class="btn btn-primary" @click="saveProduct">Mentés</button>
        </div>
      </div>
    </div>

    <!-- Blog Modal (Complex - similar to new-post.vue) -->
    <div v-if="showBlogModal" class="modal-overlay" @click.self="showBlogModal = false">
      <div class="modal blog-modal-large">
        <div class="modal-header">
          <h3 class="modal-title">{{ editingBlogPost.id ? 'Poszt szerkesztése' : 'Új poszt hozzáadása' }}</h3>
          <button class="btn btn-icon" @click="showBlogModal = false">✕</button>
        </div>
        
        <div class="modal-body-scrollable">
          <form @submit.prevent="saveBlogPost" class="post-form">
            
            <div class="form-section">
              <label for="postTitle" class="form-label">
                Poszt címe
                <span class="required-indicator">*</span>
              </label>
              <InputText 
                id="postTitle" 
                v-model="editingBlogPost.title" 
                placeholder="Add meg a poszt címét..." 
                class="w-full mb-2" 
              />
              <small class="form-hint">Adj egy rövid, informatív címet a posztodnak</small>
            </div>

            <div class="form-section">
              <label for="postCimkek" class="form-label">
                Címkék
                <span class="required-indicator">*</span>
              </label>
              <MultiSelect
                id="postCimkek"
                v-model="selectedTags" 
                :options="tagOptions" 
                optionLabel="name" 
                placeholder="Válassz címkét" 
                display="chip" 
                filter
                class="w-full mb-2"
              />
              <small class="form-hint">Válassz témához kapcsolódó címkéket a jobb kereshetőségért</small>
            </div>

            <div class="form-section">
              <label for="postSubtext" class="form-label">
                Poszt rövid leírása
              </label>
              <InputText 
                id="postSubtext"
                placeholder="Add meg a poszt leírását..."
                v-model="editingBlogPost.kivonat"
                class="w-full mb-2" 
              />
              <small class="form-hint">Adj egy rövid, tömör leírást a posztod tartalmáról</small>
            </div>

            <div class="form-section">
              <label class="form-label">
                Tartalom
                <span class="required-indicator">*</span>
              </label>
              <Editor 
                v-model="editingBlogPost.content" 
                editorStyle="height: 320px"
                class="mb-2 editor-container"
                :pt="{
                  toolbar: { class: 'editor-toolbar' },
                  content: { style: { 'min-height': '250px', 'font-family': 'inherit' } }
                }"
              />
              <small class="form-hint">Használhatsz formázást és linkeket a tartalomban</small>
            </div>

            <div class="form-section">
              <label class="form-label">
                Képek feltöltése
              </label>
              <FileUpload
                ref="fileUploadRef"
                name="images[]"
                @select="onFileSelect"
                :multiple="true"
                accept="image/avif,image/jpeg,image/png,image/gif,image/webp"
                :maxFileSize="5000000"
                :auto="false"
                :showUploadButton="false"
                :showCancelButton="false"
                chooseLabel="Képek kiválasztása"
                class="mb-2"
              >
                <template #empty>
                  <div class="drag-drop-area">
                    <i class="pi pi-cloud-upload" style="font-size: 3rem; color: #667eea; margin-bottom: 1rem;"></i>
                    <p>Húzd ide a képeidet vagy kattints a feltöltéshez</p>
                  </div>
                </template>
              </FileUpload>
              <div v-if="uploadedImages.length > 0" class="image-preview-container">
                <div v-for="(image, index) in uploadedImages" :key="index" class="image-preview">
                  <img :src="image.preview" class="preview-image" />
                  <button 
                    type="button" 
                    class="p-button-rounded p-button-danger image-remove-btn"
                    @click="removeImage(index)">
                    <i class="pi pi-times"></i>
                  </button>
                  <InputText 
                    v-model="image.alt" 
                    placeholder="Alt szöveg" 
                    class="image-alt-input"
                  />
                </div>
              </div>
            </div>

            <div class="form-section">
                <label class="form-label">Státusz</label>
                <div class="flex align-items-center">
                    <Checkbox v-model="editingBlogPost.published" inputId="published" :binary="true" />
                    <label for="published" class="ml-2">Közvetlenül közzététel</label>
                </div>
            </div>

          </form>
        </div>

        <div class="modal-footer">
          <button class="btn btn-secondary" @click="showBlogModal = false">Mégse</button>
          <button class="btn btn-primary" @click="saveBlogPost">
            {{ editingBlogPost.published ? 'Poszt feltöltése' : 'Mentés piszkozként' }}
          </button>
        </div>
      </div>
    </div>
        <!-- User Modal -->
    <div v-if="showUserModal" class="modal-overlay" @click.self="showUserModal = false">
      <div class="modal">
        <div class="modal-header">
          <h3 class="modal-title">{{ editingUser.id ? 'Felhasználó Szerkesztése' : 'Új Felhasználó' }}</h3>
          <button class="btn btn-icon" @click="showUserModal = false">✕</button>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label class="form-label">Felhasználónév</label>
            <input type="text" class="form-input" v-model="editingUser.name" placeholder="pl. János">
          </div>
          <div class="form-group">
            <label class="form-label">Email</label>
            <input type="email" class="form-input" v-model="editingUser.email" placeholder="janos@pelda.hu">
          </div>
          <div class="form-group">
            <label class="form-label">Szerepkör</label>
            <select class="form-select" v-model="editingUser.role">
              <option :value="'admin'">Admin</option>
              <option :value="'moderator'">Moderátor</option>
              <option :value="'sima'">Felhasználó</option>
              <option :value="'felfuggesztett'">Felfüggesztett</option>
            </select>
          </div>
          <div class="form-group" v-if="!editingUser.id">
            <label class="form-label">Jelszó</label>
            <input type="password" class="form-input" v-model="editingUser.password" placeholder="•••••••••">
          </div>
          <!-- PROFILE PICTURE RESET -->
          <div class="form-group">
            <label class="form-label">Profilkép</label>
            <div class="flex items-center gap-2">
              <input type="checkbox" id="resetPic" v-model="editingUser.resetProfilePic" :disabled="editingUser.profileImage?.includes('default.jpg')" :checked="editingUser.profileImage?.includes('default.jpg')">
              <label for="resetPic" style="cursor: pointer; font-size: 14px; color: #4b5563;">
                Visszaállítás alapértelmezett képre (default.jpg)
              </label>
            </div>
            <small style="color: #6b7280; font-size: 12px; margin-top: 4px; display:block;">
              Jelöld be, ha törölni akarod a jelenlegi profilképet.
            </small>
          </div>
          <div class="form-group">
            <label class="form-label">Státusz</label>
            <select class="form-select" v-model="editingUser.active">
              <option :value="true" >Aktív</option>
              <option :value="false">Inaktív</option>
            </select>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn" @click="showUserModal = false">Mégse</button>
          <button class="btn btn-primary" @click="saveUser">Mentés</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, nextTick, watch } from 'vue';
import Chart from 'chart.js/auto';
import axios from 'axios';
// PrimeVue Imports necessary for the complex form
import MultiSelect from 'primevue/multiselect';
import Editor from 'primevue/editor';
import FileUpload from 'primevue/fileupload';
import InputText from 'primevue/inputtext';
import Checkbox from 'primevue/checkbox';
import { useAuthStore } from '@/stores/auth.js';
import Button from 'primevue/button';

const API = '/api/admin';

// Reactive state
const currentView = ref('dashboard');
const productSearch = ref('');
const userSearch = ref('');
const blogSearch = ref('');
const showProductModal = ref(false);
const showUserModal = ref(false);
const showBlogModal = ref(false);
const editingProduct = ref({});
const editingUser = ref({});
const editingBlogPost = ref({});
const loading = ref(false);

// Complex Form State (from new-post.vue)
const selectedTags = ref([]); 
const uploadedImages = ref([]);   // { file: File, preview: string, alt: string, id?: number }
const tagOptions = ref([]);
const fileUploadRef = ref(null);

// Chart refs
const salesChart = ref(null);
const categoryChart = ref(null);
const productSalesChart = ref(null);
const revenueChart = ref(null);

// Chart instances
let salesChartInstance = null;
let categoryChartInstance = null;
let productSalesChartInstance = null;
let revenueChartInstance = null;

// Data
const stats = ref({ totalSales: 0, totalOrders: 0, totalProducts: 0, totalCustomers: 0 });
const products = ref([]);
const users = ref([]);
const blogPosts = ref([]);
const recentOrders = ref([]);
const analyticsData = ref({ monthlySales: [], monthlyOrders: [], categories: [] });

// --- API hívások ---

const fetchStats = async () => {
  const { data } = await axios.get(`${API}/stats`);
  stats.value = data;
};

const fetchOrders = async () => {
  const { data } = await axios.get(`${API}/rendelesek`);
  recentOrders.value = data.map(r => ({
    id: r.id,
    customer: r.felhasznalo?.nev ?? 'Vendég',
    items: r.termekek_szama,
    total: r.osszeg,
    status: r.statusz,
    date: r.rendeles_datuma?.split('T')[0] ?? '',
  }));
};

const fetchAnalytics = async () => {
  const { data } = await axios.get(`${API}/analytics`);
  analyticsData.value = data;
};

const fetchProducts = async () => {
  const { data } = await axios.get('/api/termekek');
  products.value = data.map(p => ({
    id: p.id,
    name: p.nev,
    category: p.termek_kategoria?.nev ?? '-',
    price: p.ar,
    stock: p.darab,
    image: p.termek_fo_kep?.url_Link
      ? p.termek_fo_kep.url_Link
      : 'https://placehold.co/100x100',
  }));
};

const authStore = useAuthStore();
const currentUserId = computed(() => authStore.user?.id ?? null);

const fetchUsers = async () => {
  const { data } = await axios.get(`${API}/users`);
  console.log(data);
  users.value = data.map(u => ({
    id: u.id,
    name: u.name,
    email: u.email,
    role: u.role ?? 'user',
    active: u.statusz,
    profileImage: u.profileImage,
    registrationDate: u.created_at,
    utolso_Belepes: u.utolso_Belepes,
    orderStats: u.orderStats ?? null,
  }));
};

const fetchTagsFromDatabase = async () => {
    try {
        const response = await axios.get('/api/cimkek'); // Same endpoint as new-post
        tagOptions.value = response.data.map(tag => ({
            id: tag.id,
            name: tag.nev,
            code: tag.nev.toLowerCase().replace(/\s+/g, '_')
        }));
    } catch (error) {
        console.error('Error fetching tags:', error);
    }
};

const fetchBlogPosts = async () => {
  const { data } = await axios.get('/api/blog');
  blogPosts.value = data.map(p => ({
    id: p.id,
    title: p.cim,
    author: p.szerzo ?? '-',
    category: p.cimkek?.[0]?.nev ?? '-', // Adjust based on actual API structure
    date: p.letrehozas_datuma ?? '',
    published: p.statusz === 'közzétett',
    content: p.tartalom ?? '',
    kivonat: p.kivonat || '',
    tagsData: p.cimkek || [],
    imagesData: p.kepek || []
  }));
};

// --- Image Handling Logic (from new-post.vue) ---
const onFileSelect = (event) => {
    const files = event.files.filter(file => 
        file.type.startsWith('image/')
    );
    files.forEach(file => {
        const reader = new FileReader();
        reader.onload = (e) => {
            uploadedImages.value.push({
                file: file,
                preview: e.target.result,
                alt: '',
                id: null // New file, no server ID yet
            });
        };
        reader.readAsDataURL(file);
    });
    
    if (fileUploadRef.value) {
        fileUploadRef.value.clear();
    }
};

const removeImage = (index) => {
  uploadedImages.value.splice(index, 1);
};

// --- CRUD ---

const saveProduct = async () => {
  const payload = {
    nev: editingProduct.value.name,
    kategoria_id: editingProduct.value.kategoria_id ?? 1,
    ar: editingProduct.value.price,
    darab: editingProduct.value.stock,
    leiras: editingProduct.value.description ?? '',
  };

  if (editingProduct.value.id) {
    await axios.put(`${API}/termekek/${editingProduct.value.id}`, payload);
  } else {
    await axios.post(`${API}/termekek`, payload);
  }

  showProductModal.value = false;
  await fetchProducts();
};

const deleteProduct = async (id) => {
  if (!confirm('Biztosan törölni szeretnéd ezt a terméket?')) return;
  await axios.delete(`${API}/termekek/${id}`);
  await fetchProducts();
};

const saveUser = async () => {
  if (editingUser.value.id && editingUser.value.id === currentUserId.value) {
    alert('Saját fiókodat nem módosíthatod az admin felületen!');
    return;
  }
  if(!editingUser.value.id && !editingUser.value.password) {
    alert('A jelszó meg kell adni a felhasznált felhasználoknak!');
    return;
  }
  const payload = {
    felhasz_nev: editingUser.value.name,
    email: editingUser.value.email,
    szerepkor: editingUser.value.role,
    statusz: editingUser.value.active,
    password: editingUser.value.password,
  };

  if (!editingUser.value.id) {
    payload.password = editingUser.value.password;
  }

  if (editingUser.value.resetProfilePic) {
    payload.resetProfilePic = true;
  }

  try{
    if (editingUser.value.id) {
      await axios.put(`${API}/users/${editingUser.value.id}`, payload);
    } else {
      await axios.post(`${API}/users`, payload);
    }

    showUserModal.value = false;
    await fetchUsers();
  } catch (error) {
    alert('Hiba történt a felhasználók feltöltése:', error);
  }

};

const deleteUser = async (id) => {
  if (!confirm('Biztosan törölni szeretnéd ezt a felhasználót?')) return;
  
  try {
    const response = await axios.delete(`${API}/users/${id}`);
    
    // If successful, refresh list and show success message
    await fetchUsers();
    alert(response.data.message || 'Sikeresen törölve!');
    
  } catch (error) {
    // If error (like 403 for active orders), show the backend error message
    const errorMessage = error.response?.data?.error || 'Ismeretlen hiba történt';
    alert(errorMessage);
  }
};

const saveBlogPost = async () => {
  // Reuse logic from new-post.vue's savePost
  try {
    // 1. Upload new images
    const newImageIds = []
    const newImages = uploadedImages.value.filter(img => img.file)
    if (newImages.length > 0) {
      const formData = new FormData()
      newImages.forEach((img, index) => {
        formData.append('images[]', img.file)
        formData.append(`alt[${index}]`, img.alt || '')
      })
      const uploadRes = await axios.post('/api/upload-images', formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
        withCredentials: true
      })
      uploadRes.data.images.forEach((uploaded) => {
        newImageIds.push(uploaded.id)
      })
    }

    // 2. Collect all image ids
    const existingImageIds = uploadedImages.value
      .filter(img => img.id && !img.file)
      .map(img => img.id)
    const allImageIds = [...existingImageIds, ...newImageIds]

    const status = editingBlogPost.value.published ? 'közzétett' : 'piszkozat';

    const payload = {
      title: editingBlogPost.value.title,
      content: editingBlogPost.value.content,
      kivonat: editingBlogPost.value.kivonat || null,
      status: status,
      tags: selectedTags.value.map(tag => tag.id),
      images: allImageIds.map(id => ({ id }))
    };

    if (editingBlogPost.value.id) {
      await axios.put(`/api/posts/${editingBlogPost.value.id}`, payload);
    } else {
      await axios.post('/api/posts', payload);
    }

    showBlogModal.value = false;
    await fetchBlogPosts();
  } catch (error) {
    console.error('Save error:', error);
    alert('Hiba történt a mentés során');
  }
};

const deleteBlogPost = async (id) => {
  if (!confirm('Biztosan törölni szeretnéd ezt a bejegyzést?')) return;
  await axios.delete(`/api/posts/${id}`);
  await fetchBlogPosts();
};

const refreshData = async () => {
  loading.value = true;
  await Promise.all([fetchStats(), fetchOrders(), fetchAnalytics()]);
  loading.value = false;
};

// --- Modals ---

const openProductModal = (product = null) => {
  editingProduct.value = product
    ? { ...product }
    : { name: '', category: 'Fonalak', price: 0, stock: 0, image: '', description: '' };
  showProductModal.value = true;
};

const openUserModal = (user = null) => {
  if (user) {
    const isDefault = !user.profileImage || user  .profileImage?.includes('default.jpg');
    editingUser.value = { ...user, resetProfilePic: isDefault, isSelf: user.id === currentUserId.value };
  } else {
    editingUser.value = {
      name: '',
      email: '',
      role: 'sima',
      active: true,
      password: '',
      resetProfilePic: false,
      isSelf: false
    };
  }
  showUserModal.value = true;
}

const openBlogModal = (post = null) => {
  // Reset complex form state
  selectedTags.value = [];
  uploadedImages.value = [];

  if (post) {
    // Edit mode
    editingBlogPost.value = {
        id: post.id,
        title: post.title,
        content: post.content,
        kivonat: post.kivonat,
        published: post.published
    };
    
    // Populate tags
    selectedTags.value = post.tagsData ? post.tagsData.map(tag => ({
        id: tag.id,
        name: tag.nev
    })) : [];

    // Populate images
    uploadedImages.value = post.imagesData ? post.imagesData.map(img => ({
        id: img.id,
        file: null,
        preview: img.url_Link,
        alt: img.alt_Szoveg || ''
    })) : [];

  } else {
    // New mode
    editingBlogPost.value = {
        title: '',
        content: '',
        kivonat: '',
        published: false
    };
  }
  showBlogModal.value = true;
};

// --- Computed ---

const filteredProducts = computed(() => {
  if (!productSearch.value) return products.value;
  const s = productSearch.value.toLowerCase();
  return products.value.filter(p =>
    p.name.toLowerCase().includes(s) || p.category.toLowerCase().includes(s)
  );
});

const filteredBlogPosts = computed(() => {
  if (!blogSearch.value) return blogPosts.value;
  const s = blogSearch.value.toLowerCase();
  return blogPosts.value.filter(p =>
    p.title.toLowerCase().includes(s) || p.author.toLowerCase().includes(s)
  );
});

const filteredUsers = computed(() => {
  if (!userSearch.value) return users.value;
  const s = userSearch.value.toLowerCase();
  return users.value.filter(p =>
    p.name.toLowerCase().includes(s) || p.email.toLowerCase().includes(s) || p.role.toLowerCase().includes(s)
  );
});

// --- Helpers ---

const formatDate = (dateString) => {
  if (!dateString) return '-';
  
  const date = new Date(dateString);
  
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0'); // Months are 0-indexed
  const day = String(date.getDate()).padStart(2, '0');
  const hours = String(date.getHours()).padStart(2, '0');   // Use getUTCHours() if you don't want timezone conversion
  const minutes = String(date.getMinutes()).padStart(2, '0');

  return `${year}-${month}-${day} ${hours}:${minutes}`;
};

const formatCurrency = (value) =>
  new Intl.NumberFormat('hu-HU', { style: 'currency', currency: 'HUF', minimumFractionDigits: 0 }).format(value);

const getOrderBadgeClass = (status) => {
  if (status === 'teljesítve') return 'badge-success';
  if (['szállítás alatt', 'függőben'].includes(status)) return 'badge-warning';
  return 'badge-danger';
};

// --- Charts ---

const destroyDashboardCharts = () => {
  if (salesChartInstance) { salesChartInstance.destroy(); salesChartInstance = null; }
  if (categoryChartInstance) { categoryChartInstance.destroy(); categoryChartInstance = null; }
};

const destroyAnalyticsCharts = () => {
  if (productSalesChartInstance) { productSalesChartInstance.destroy(); productSalesChartInstance = null; }
  if (revenueChartInstance) { revenueChartInstance.destroy(); revenueChartInstance = null; }
};

const MONTHS = ['Jan', 'Feb', 'Már', 'Ápr', 'Máj', 'Jún', 'Júl', 'Aug', 'Sze', 'Okt', 'Nov', 'Dec'];

const initCharts = () => {
  nextTick(() => {
    if (salesChart.value && !salesChartInstance) {
      salesChartInstance = new Chart(salesChart.value, {
        type: 'line',
        data: {
          labels: MONTHS.slice(0, analyticsData.value.monthlySales.length),
          datasets: [{
            label: 'Értékesítés (Ft)',
            data: analyticsData.value.monthlySales,
            borderColor: '#6366f1',
            backgroundColor: 'rgba(99, 102, 241, 0.1)',
            tension: 0.4, fill: true
          }]
        },
        options: {
          responsive: true,
          plugins: { legend: { display: false } },
          scales: { y: { beginAtZero: true, ticks: { callback: v => v.toLocaleString('hu-HU') + ' Ft' } } }
        }
      });
    }

    if (categoryChart.value && !categoryChartInstance) {
      categoryChartInstance = new Chart(categoryChart.value, {
        type: 'doughnut',
        data: {
          labels: analyticsData.value.categories.map(c => c.nev),
          datasets: [{ data: analyticsData.value.categories.map(c => c.db), backgroundColor: ['#6366f1','#8b5cf6','#ec4899','#f59e0b','#10b981'] }]
        },
        options: { responsive: true, plugins: { legend: { position: 'bottom' } } }
      });
    }

    if (productSalesChart.value && !productSalesChartInstance) {
      productSalesChartInstance = new Chart(productSalesChart.value, {
        type: 'bar',
        data: {
          labels: MONTHS.slice(0, analyticsData.value.monthlyOrders.length),
          datasets: [{ label: 'Eladott Termékek', data: analyticsData.value.monthlyOrders, backgroundColor: '#10b981' }]
        },
        options: { responsive: true, plugins: { legend: { display: false } }, scales: { y: { beginAtZero: true } } }
      });
    }

    if (revenueChart.value && !revenueChartInstance) {
      revenueChartInstance = new Chart(revenueChart.value, {
        type: 'line',
        data: {
          labels: MONTHS.slice(0, analyticsData.value.monthlySales.length),
          datasets: [{
            label: 'Bevétel',
            data: analyticsData.value.monthlySales,
            borderColor: '#8b5cf6',
            backgroundColor: 'rgba(139, 92, 246, 0.1)',
            tension: 0.4, fill: true
          }]
        },
        options: {
          responsive: true,
          plugins: { legend: { display: false } },
          scales: { y: { beginAtZero: true, ticks: { callback: v => v.toLocaleString('hu-HU') + ' Ft' } } }
        }
      });
    }
  });
};

// --- Lifecycle ---

onMounted(async () => {
  await Promise.all([
      fetchStats(), 
      fetchOrders(), 
      fetchAnalytics(), 
      fetchProducts(),
      fetchUsers(),
      fetchBlogPosts(),
      fetchTagsFromDatabase() // Load tags for the blog modal
  ]);
  initCharts();
});

watch(currentView, (newView, oldView) => {
  if (oldView === 'dashboard') destroyDashboardCharts();
  if (oldView === 'analytics') destroyAnalyticsCharts();
  initCharts();
});
</script>

<style scoped>
.dashboard-wrapper {
  display: flex;
  min-height: calc(100vh - 160px);
  background: #f8fafc;
  margin-top: 10px;
}

/* Sidebar */
.sidebar {
  width: 260px;
  background: #1e293b;
  color: white;
  padding: 0;
  overflow-y: auto;
  box-shadow: 0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1);
}

.sidebar-header {
  padding: 24px 20px;
  border-bottom: 1px solid #334155;
}

.sidebar-header h1 {
  font-size: 22px;
  font-weight: 700;
  color: white;
  margin-bottom: 4px;
}

.sidebar-header p {
  font-size: 13px;
  color: #94a3b8;
}

.nav-menu {
  list-style: none;
  padding: 16px 0;
}

.nav-item {
  margin: 4px 12px;
}

.nav-link {
  display: flex;
  align-items: center;
  padding: 12px 16px;
  color: #cbd5e1;
  text-decoration: none;
  border-radius: 8px;
  transition: all 0.2s;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
}

.nav-link:hover {
  background: #334155;
  color: white;
}

.nav-link.active {
  background: #6366f1;
  color: white;
}

.nav-icon {
  margin-right: 12px;
  font-size: 18px;
}

/* Main Content */
.main-content {
  flex: 1;
  padding: 24px;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 32px;
}

.header h2 {
  font-size: 28px;
  font-weight: 700;
  color: #1e293b;
}

.header-actions {
  display: flex;
  gap: 12px;
}

/* Stats Grid */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
  margin-bottom: 32px;
}

.stat-card {
  background: white;
  padding: 24px;
  border-radius: 12px;
  box-shadow: 0 1px 3px 0 rgb(0 0 0 / 0.1), 0 1px 2px -1px rgb(0 0 0 / 0.1);
  border: 1px solid #e2e8f0;
  transition: transform 0.2s, box-shadow 0.2s;
}

.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1);
}

.stat-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 16px;
}

.stat-title {
  font-size: 14px;
  color: #64748b;
  font-weight: 500;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.stat-icon {
  width: 48px;
  height: 48px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
}

.stat-value {
  font-size: 32px;
  font-weight: 700;
  color: #1e293b;
  margin-bottom: 8px;
}

.stat-change {
  font-size: 13px;
  font-weight: 600;
}

.stat-change.positive {
  color: #10b981;
}

/* Charts */
.charts-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
  gap: 20px;
  margin-bottom: 32px;
}

.chart-card {
  background: white;
  padding: 24px;
  border-radius: 12px;
  box-shadow: 0 1px 3px 0 rgb(0 0 0 / 0.1), 0 1px 2px -1px rgb(0 0 0 / 0.1);
  border: 1px solid #e2e8f0;
}

.chart-header {
  margin-bottom: 20px;
}

.chart-title {
  font-size: 18px;
  font-weight: 600;
  color: #1e293b;
}

/* Table */
.table-container {
  background: white;
  border-radius: 12px;
  box-shadow: 0 1px 3px 0 rgb(0 0 0 / 0.1), 0 1px 2px -1px rgb(0 0 0 / 0.1);
  border: 1px solid #e2e8f0;
  overflow: hidden;
}

.table-header {
  padding: 20px 24px;
  border-bottom: 1px solid #e2e8f0;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.table-title {
  font-size: 18px;
  font-weight: 600;
  color: #1e293b;
}

.search-box {
  display: flex;
  gap: 12px;
}

.search-input {
  padding: 8px 16px;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  font-size: 14px;
  width: 250px;
  transition: border-color 0.2s;
}

.search-input:focus {
  outline: none;
  border-color: #6366f1;
}

table {
  width: 100%;
  border-collapse: collapse;
}

thead {
  background: #f8fafc;
  border-bottom: 2px solid #e2e8f0;
}

th {
  padding: 10px 16px;
  text-align: left;
  font-size: 13px;
  font-weight: 600;
  color: #64748b;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

td {
  padding: 16px 24px;
  border-bottom: 1px solid #e2e8f0;
  font-size: 14px;
}

tbody tr:hover {
  background: #f8fafc;
}

/* Buttons */
.btn {
  padding: 10px 20px;
  border: none;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  display: inline-flex;
  align-items: center;
  gap: 8px;
}

.btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 1px 3px 0 rgb(0 0 0 / 0.1), 0 1px 2px -1px rgb(0 0 0 / 0.1);
}

.btn-primary {
  background: #6366f1;
  color: white;
}

.btn-primary:hover {
  background: #4f46e5;
}

.btn-secondary {
    background: #e2e8f0;
    color: #1e293b;
}

.btn-secondary:hover {
    background: #cbd5e1;
}

.btn-warning {
  background: #0094dbb5;
  color: white;
}

.btn-danger {
  background: #ef4444;
  color: white;
}

.btn-sm {
  padding: 6px 12px;
  font-size: 12px;
}

.btn-icon {
  padding: 8px;
  width: 36px;
  height: 36px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

/* Modal */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  animation: fadeIn 0.2s;
  padding: 20px;
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

.modal {
  background: white;
  border-radius: 12px;
  width: 100%;
  max-width: 600px;
  max-height: 90vh;
  overflow-y: auto;
  animation: slideUp 0.3s;
  display: flex;
  flex-direction: column;
}

.blog-modal-large {
    max-width: 1000px;
    height: 90vh;
}

@keyframes slideUp {
  from {
    transform: translateY(20px);
    opacity: 0;
  }
  to {
    transform: translateY(0);
    opacity: 1;
  }
}

.modal-header {
  padding: 24px;
  border-bottom: 1px solid #e2e8f0;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: white;
  z-index: 10;
}

.modal-title {
  font-size: 20px;
  font-weight: 600;
  color: #1e293b;
}

.modal-body-scrollable {
    padding: 24px;
    overflow-y: auto;
    flex: 1;
}

.modal-body {
  padding: 24px;
}

.modal-footer {
  padding: 20px 24px;
  border-top: 1px solid #e2e8f0;
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  background: white;
  z-index: 10;
}

/* Forms */
.form-group {
  margin-bottom: 20px;
}

.form-section {
    margin-bottom: 24px;
}

.form-label {
  display: block;
  margin-bottom: 8px;
  font-size: 14px;
  font-weight: 600;
  color: #1e293b;
}

.required-indicator {
    color: #f87171;
    margin-left: 4px;
}

.form-hint {
    display: block;
    margin-top: 6px;
    color: #718096;
    font-size: 13px;
}

.post-form {
    display: flex;
    flex-direction: column;
    gap: 20px;
}

.form-input,
.form-select,
.form-textarea {
  width: 100%;
  padding: 10px 14px;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  font-size: 14px;
  transition: border-color 0.2s;
}

.form-input:focus,
.form-select:focus,
.form-textarea:focus {
  outline: none;
  border-color: #6366f1;
}

.form-textarea {
  resize: vertical;
  min-height: 100px;
}

/* Badge */
.badge {
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 600;
  display: inline-block;
}

.badge-success {
  background: #dcfce7;
  color: #166534;
}

.badge-warning {
  background: #fef3c7;
  color: #92400e;
}

.badge-danger {
  background: #fee2e2;
  color: #991b1b;
}

.badge-blue {
  background: #1d4fd84d;
  color: #0c004e;
}

/* Product Image */
.product-img {
  width: 50px;
  height: 50px;
  object-fit: cover;
  border-radius: 8px;
}

/* Avatar */
.avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  object-fit: cover;
}

/* Action Buttons */
.action-buttons {
  display: flex;
  gap: 8px;
}

/* Styles specific to the Complex Blog Form (from new-post.vue) */
.image-preview-container {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
  gap: 15px;
  margin-top: 15px;
}
.image-preview {
  position: relative;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}
.preview-image {
  width: 100%;
  height: 120px;
  object-fit: cover;
  display: block;
}
.image-remove-btn {
  position: absolute;
  top: 5px;
  right: 5px;
  z-index: 10;
  width: 24px;
  height: 24px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0;
  border: none;
  background: #ef4444;
  color: white;
  cursor: pointer;
}
.image-alt-input {
  width: 100%;
  margin-top: 5px;
  font-size: 12px;
  padding: 4px 8px;
}

.drag-drop-area {
    border: 2px dashed #cbd5e0;
    border-radius: 10px;
    padding: 30px 10px;
    text-align: center;
    cursor: pointer;
    transition: all 0.3s ease;
    background-color: #f8fafc;
    margin-bottom: 1rem;
}

.drag-drop-area:hover {
    border-color: #4d8af0;
    background-color: #f0f7ff;
}



:deep(.p-fileupload) {
  border: 2px solid #e2e8f0;
  border-radius: 10px;
  padding: 15px;
}

:deep() {
    .p-inputtext {
        border: 2px solid #e2e8f0;
        border-radius: 10px;
        padding: 12px 16px;
        font-size: 16px;
        transition: all 0.3s ease;
        background-color: white;
    }
    
    .p-inputtext:focus {
        border-color: #4d8af0;
        box-shadow: 0 0 0 3px rgba(77, 138, 240, 0.1);
        outline: none;
    }
    
    .p-multiselect {
        border: 2px solid #e2e8f0;
        border-radius: 10px;
        transition: all 0.3s ease;
        width: 100%;
    }
    
    .p-multiselect:not(.p-disabled):hover {
        border-color: #cbd5e0;
    }
    
    .p-multiselect:not(.p-disabled).p-focus {
        border-color: #4d8af0;
        box-shadow: 0 0 0 3px rgba(77, 138, 240, 0.1);
    }
    
    .p-multiselect-panel {
        border-radius: 10px;
        border: 1px solid #e2e8f0;
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
    }
    
    .p-multiselect-chip .p-chip {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        border-radius: 20px;
        padding: 4px 10px;
        font-weight: 500;
    }
    
    .editor-toolbar {
        border: 2px solid #e2e8f0;
        border-bottom: none;
        border-radius: 10px 10px 0 0;
        padding: 12px;
        background: #f8fafc;
    }
    
    .p-editor-container .p-editor-content {
        border: 2px solid #e2e8f0;
        border-top: none;
        border-radius: 0 0 10px 10px;
        min-height: 250px;
    }
}
</style>