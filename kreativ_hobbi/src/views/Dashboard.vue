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
              <h3 class="chart-title">Legnépszerűbb Kategóriák</h3>
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

    <!-- Product Modal -->
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

    <!-- Blog Modal -->
    <div v-if="showBlogModal" class="modal-overlay" @click.self="showBlogModal = false">
      <div class="modal">
        <div class="modal-header">
          <h3 class="modal-title">{{ editingBlogPost.id ? 'Bejegyzés Szerkesztése' : 'Új Bejegyzés' }}</h3>
          <button class="btn btn-icon" @click="showBlogModal = false">✕</button>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label class="form-label">Cím</label>
            <input type="text" class="form-input" v-model="editingBlogPost.title" placeholder="Bejegyzés címe">
          </div>
          <div class="form-group">
            <label class="form-label">Kategória</label>
            <select class="form-select" v-model="editingBlogPost.category">
              <option>Tippek & Trükkök</option>
              <option>Minták</option>
              <option>Útmutatók</option>
              <option>Inspiráció</option>
              <option>Hírek</option>
            </select>
          </div>
          <div class="form-group">
            <label class="form-label">Szerző</label>
            <input type="text" class="form-input" v-model="editingBlogPost.author" placeholder="Szerző neve">
          </div>
          <div class="form-group">
            <label class="form-label">Tartalom</label>
            <textarea class="form-textarea" v-model="editingBlogPost.content" placeholder="Bejegyzés tartalma..." style="min-height: 200px;"></textarea>
          </div>
          <div class="form-group">
            <label class="form-label">
              <input type="checkbox" v-model="editingBlogPost.published"> Publikálás
            </label>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn" @click="showBlogModal = false">Mégse</button>
          <button class="btn btn-primary" @click="saveBlogPost">Mentés</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, nextTick, watch } from 'vue';
import Chart from 'chart.js/auto';

// Reactive state
const currentView = ref('dashboard');
const productSearch = ref('');
const blogSearch = ref('');
const showProductModal = ref(false);
const showBlogModal = ref(false);
const editingProduct = ref({});
const editingBlogPost = ref({});

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

// Stats data
const stats = ref({
  totalSales: 2847500,
  totalOrders: 143,
  totalProducts: 87,
  totalCustomers: 456
});

// Products data
const products = ref([
  { id: 1, name: 'Akril Fonál 100g - Piros', category: 'Fonalak', price: 1290, stock: 45, image: 'https://images.unsplash.com/photo-1608987825835-ed116c900875?w=100&h=100&fit=crop' },
  { id: 2, name: 'Bambusz Kötőtű Szett', category: 'Kötőtűk', price: 3490, stock: 23, image: 'https://images.unsplash.com/photo-1611652022419-a9419f74343b?w=100&h=100&fit=crop' },
  { id: 3, name: 'Gyapjú Fonál 50g - Kék', category: 'Fonalak', price: 1890, stock: 8, image: 'https://images.unsplash.com/photo-1598122541148-eb9e39ca1c35?w=100&h=100&fit=crop' },
  { id: 4, name: 'Horgolótű Készlet', category: 'Horgolótűk', price: 2990, stock: 15, image: 'https://images.unsplash.com/photo-1618220179428-22790b461013?w=100&h=100&fit=crop' },
  { id: 5, name: 'DMC Hímzőfonal Szett', category: 'Hímzőfonalak', price: 4500, stock: 0, image: 'https://images.unsplash.com/photo-1604242692219-da8e8b0d3366?w=100&h=100&fit=crop' },
  { id: 6, name: 'Fonalvágó Olló', category: 'Kellékek', price: 890, stock: 67, image: 'https://images.unsplash.com/photo-1588776814546-1ffcf47267a5?w=100&h=100&fit=crop' }
]);

// Blog posts data
const blogPosts = ref([
  { id: 1, title: '10 Tipp Kezdő Kötőknek', author: 'Kovács Edit', category: 'Tippek & Trükkök', date: '2026-02-10', published: true },
  { id: 2, title: 'Tavaszi Virágminták Horgoláshoz', author: 'Tóthpál István', category: 'Minták', date: '2026-02-08', published: true },
  { id: 3, title: 'Hímzési Alapok Kezdőknek', author: 'Nagy Anna', category: 'Útmutatók', date: '2026-02-05', published: false },
  { id: 4, title: 'Fonalválasztás Útmutató', author: 'Kovács Edit', category: 'Útmutatók', date: '2026-02-01', published: true }
]);

// Recent orders data
const recentOrders = ref([
  { id: 'ORD-1234', customer: 'Kiss Mária', items: 3, total: 8970, status: 'Kiszállítva', date: '2026-02-15' },
  { id: 'ORD-1233', customer: 'Nagy Péter', items: 1, total: 3490, status: 'Feldolgozás alatt', date: '2026-02-15' },
  { id: 'ORD-1232', customer: 'Szabó Anna', items: 5, total: 12450, status: 'Kiszállítva', date: '2026-02-14' },
  { id: 'ORD-1231', customer: 'Horváth Éva', items: 2, total: 5980, status: 'Csomagolás alatt', date: '2026-02-14' },
  { id: 'ORD-1230', customer: 'Tóth István', items: 4, total: 9360, status: 'Kiszállítva', date: '2026-02-13' }
]);

// Computed properties
const filteredProducts = computed(() => {
  if (!productSearch.value) return products.value;
  const search = productSearch.value.toLowerCase();
  return products.value.filter(p => 
    p.name.toLowerCase().includes(search) || 
    p.category.toLowerCase().includes(search)
  );
});

const filteredBlogPosts = computed(() => {
  if (!blogSearch.value) return blogPosts.value;
  const search = blogSearch.value.toLowerCase();
  return blogPosts.value.filter(p => 
    p.title.toLowerCase().includes(search) || 
    p.author.toLowerCase().includes(search)
  );
});

// Methods
const formatCurrency = (value) => {
  return new Intl.NumberFormat('hu-HU', { 
    style: 'currency', 
    currency: 'HUF', 
    minimumFractionDigits: 0 
  }).format(value);
};

const getOrderBadgeClass = (status) => {
  if (status === 'Kiszállítva') return 'badge-success';
  if (status === 'Feldolgozás alatt' || status === 'Csomagolás alatt') return 'badge-warning';
  return 'badge-danger';
};

const openProductModal = (product = null) => {
  editingProduct.value = product 
    ? { ...product } 
    : { name: '', category: 'Fonalak', price: 0, stock: 0, image: '', description: '' };
  showProductModal.value = true;
};

const saveProduct = () => {
  if (editingProduct.value.id) {
    const index = products.value.findIndex(p => p.id === editingProduct.value.id);
    products.value[index] = { ...editingProduct.value };
  } else {
    editingProduct.value.id = Date.now();
    products.value.push({ ...editingProduct.value });
  }
  showProductModal.value = false;
};

const deleteProduct = (id) => {
  if (confirm('Biztosan törölni szeretnéd ezt a terméket?')) {
    products.value = products.value.filter(p => p.id !== id);
  }
};

const openBlogModal = (post = null) => {
  editingBlogPost.value = post 
    ? { ...post } 
    : { title: '', author: '', category: 'Tippek & Trükkök', content: '', published: false, date: new Date().toISOString().split('T')[0] };
  showBlogModal.value = true;
};

const saveBlogPost = () => {
  if (editingBlogPost.value.id) {
    const index = blogPosts.value.findIndex(p => p.id === editingBlogPost.value.id);
    blogPosts.value[index] = { ...editingBlogPost.value };
  } else {
    editingBlogPost.value.id = Date.now();
    blogPosts.value.push({ ...editingBlogPost.value });
  }
  showBlogModal.value = false;
};

const deleteBlogPost = (id) => {
  if (confirm('Biztosan törölni szeretnéd ezt a bejegyzést?')) {
    blogPosts.value = blogPosts.value.filter(p => p.id !== id);
  }
};

const refreshData = () => {
  alert('Adatok frissítve!');
};

const initCharts = () => {
  nextTick(() => {
    // Sales Chart
    if (salesChart.value && !salesChartInstance) {
      salesChartInstance = new Chart(salesChart.value, {
        type: 'line',
        data: {
          labels: ['Jan', 'Feb', 'Már', 'Ápr', 'Máj', 'Jún', 'Júl'],
          datasets: [{
            label: 'Értékesítés (Ft)',
            data: [320000, 390000, 410000, 520000, 480000, 550000, 620000],
            borderColor: '#6366f1',
            backgroundColor: 'rgba(99, 102, 241, 0.1)',
            tension: 0.4,
            fill: true
          }]
        },
        options: {
          responsive: true,
          plugins: {
            legend: { display: false }
          },
          scales: {
            y: {
              beginAtZero: true,
              ticks: {
                callback: function(value) {
                  return value.toLocaleString('hu-HU') + ' Ft';
                }
              }
            }
          }
        }
      });
    }

    // Category Chart
    if (categoryChart.value && !categoryChartInstance) {
      categoryChartInstance = new Chart(categoryChart.value, {
        type: 'doughnut',
        data: {
          labels: ['Fonalak', 'Kötőtűk', 'Horgolótűk', 'Hímzőfonalak', 'Kellékek'],
          datasets: [{
            data: [35, 20, 18, 15, 12],
            backgroundColor: [
              '#6366f1',
              '#8b5cf6',
              '#ec4899',
              '#f59e0b',
              '#10b981'
            ]
          }]
        },
        options: {
          responsive: true,
          plugins: {
            legend: {
              position: 'bottom'
            }
          }
        }
      });
    }

    // Product Sales Chart
    if (productSalesChart.value && !productSalesChartInstance) {
      productSalesChartInstance = new Chart(productSalesChart.value, {
        type: 'bar',
        data: {
          labels: ['Jan', 'Feb', 'Már', 'Ápr', 'Máj', 'Jún'],
          datasets: [{
            label: 'Eladott Termékek',
            data: [145, 178, 192, 234, 198, 256],
            backgroundColor: '#10b981'
          }]
        },
        options: {
          responsive: true,
          plugins: {
            legend: { display: false }
          },
          scales: {
            y: { beginAtZero: true }
          }
        }
      });
    }

    // Revenue Chart
    if (revenueChart.value && !revenueChartInstance) {
      revenueChartInstance = new Chart(revenueChart.value, {
        type: 'line',
        data: {
          labels: ['Jan', 'Feb', 'Már', 'Ápr', 'Máj', 'Jún'],
          datasets: [{
            label: 'Bevétel',
            data: [320000, 390000, 410000, 520000, 480000, 550000],
            borderColor: '#8b5cf6',
            backgroundColor: 'rgba(139, 92, 246, 0.1)',
            tension: 0.4,
            fill: true
          }]
        },
        options: {
          responsive: true,
          plugins: {
            legend: { display: false }
          },
          scales: {
            y: {
              beginAtZero: true,
              ticks: {
                callback: function(value) {
                  return value.toLocaleString('hu-HU') + ' Ft';
                }
              }
            }
          }
        }
      });
    }
  });
};

// Lifecycle hooks
onMounted(() => {
  initCharts();
});

// Watchers
watch(currentView, () => {
  initCharts();
});
</script>

<style scoped>
.dashboard-wrapper {
  display: flex;
  min-height: calc(100vh - 160px);
  background: #f8fafc;
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
  padding: 14px 24px;
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

.btn-warning {
  background: #f59e0b;
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
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

.modal {
  background: white;
  border-radius: 12px;
  width: 90%;
  max-width: 600px;
  max-height: 90vh;
  overflow-y: auto;
  animation: slideUp 0.3s;
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
}

.modal-title {
  font-size: 20px;
  font-weight: 600;
  color: #1e293b;
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
}

/* Forms */
.form-group {
  margin-bottom: 20px;
}

.form-label {
  display: block;
  margin-bottom: 8px;
  font-size: 14px;
  font-weight: 600;
  color: #1e293b;
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

/* Product Image */
.product-img {
  width: 50px;
  height: 50px;
  object-fit: cover;
  border-radius: 8px;
}

/* Action Buttons */
.action-buttons {
  display: flex;
  gap: 8px;
}
</style>