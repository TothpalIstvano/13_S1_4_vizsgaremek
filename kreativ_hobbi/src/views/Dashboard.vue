<template>
  <div class="dashboard-wrapper">
    <!-- Sidebar -->
    <div class="sidebar" :class="{ 'sidebar-open': sidebarOpen }">
      <div class="sidebar-header">
        <h1>Kreatív Hobbi</h1>
        <p>Adminisztrációs felület</p>
      </div>
      <ul class="nav-menu">
        <li class="nav-item">
          <a class="nav-link" :class="{active: currentView === 'dashboard'}" @click="currentView = 'dashboard'">
            <span class="nav-icon"><FontAwesomeIcon icon="fa-poll" /></span>Dashboard
          </a>
        </li>
        <li class="nav-item">
          <a class="nav-link" :class="{active: currentView === 'products'}" @click="currentView = 'products'">
            <span class="nav-icon"><FontAwesomeIcon icon="fa-bag-shopping" /></span>
            Termékek
          </a>
        </li>
        <li class="nav-item">
          <a class="nav-link" :class="{active: currentView === 'blog'}" @click="currentView = 'blog'">
            <span class="nav-icon"><FontAwesomeIcon icon="fa-file-lines" /></span>
            Blogbejegyzések
          </a>
        </li>
        <li class="nav-item">
          <a class="nav-link" :class="{active: currentView === 'users'}" @click="currentView = 'users'">
            <span class="nav-icon"><FontAwesomeIcon icon="fa-user" /></span>
            Felhasználók
          </a>
        </li>
        <li class="nav-item">
          <a class="nav-link" :class="{active: currentView === 'analytics'}" @click="currentView = 'analytics'">
            <span class="nav-icon"><FontAwesomeIcon icon="fa-chart-line" /></span>
            Analitika
          </a>
        </li>
      </ul>
    </div>
    <div v-if="sidebarOpen" class="sidebar-overlay" @click="sidebarOpen = false"></div>

    <!-- Main Content -->
    <main class="main-content">
      <button class="sidebar-toggle" @click="sidebarOpen = !sidebarOpen">
        {{ sidebarOpen ? '✕' : '☰' }}
      </button>
      <!-- Dashboard View -->
      <div v-if="currentView === 'dashboard'">
        <div class="header">
          <h2>Dashboard</h2>
          <div class="header-actions">
            <button class="btn btn-primary" @click="refreshData">
              <FontAwesomeIcon icon="fa-refresh" /> Frissítés
            </button>
          </div>
        </div>

        <!-- Stats Cards -->
        <div class="stats-grid">
          <div class="stat-card">
            <div class="stat-header">
              <div>
                <div class="stat-title">Összes értékesítés</div>
              </div>
              <div class="stat-icon" style="background: #fff7ed; color: #c2410c;">
                <FontAwesomeIcon icon="fa-coins" />
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
                <FontAwesomeIcon icon="fa-truck" />
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
                <FontAwesomeIcon icon="fa-bag-shopping" />
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
                <FontAwesomeIcon icon="fa-users" />
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
              <h3 class="chart-title">Havi értékesítés</h3>
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
            <h3 class="table-title">Rendelések</h3>
            <div class="filters-row">
              <div class="search-box">
                <input 
                  type="text" 
                  class="search-input" 
                  placeholder="Keresés (név vagy ID alapján)..."
                  v-model="orderSearch"
                >
              </div>
              <select 
                v-model="orderStatusFilter" 
                style="padding:8px 12px; font-size:14px; border:1px solid #e2e8f0; border-radius:8px; height:38px; min-width:160px; background:white; cursor:pointer;"
              >
                <option value="">Összes státusz</option>
                <option value="teljesítve">✅ Teljesítve</option>
                <option value="függőben">⏳ Függőben</option>
                <option value="szállítás alatt">🚚 Szállítás alatt</option>
                <option value="törölve">🚫 Törölve</option>
              </select>
            </div>
          </div>
          <table>
            <thead>
              <tr>
                <th @click="toggleOrderSort('id')" style="cursor:pointer; user-select:none; white-space:nowrap;">
                  Rendelés ID
                  <span style="margin-left:4px; font-size:11px; color:#94a3b8;">
                    <span :style="orderSortKey === 'id' && orderSortDir === 'asc' ? 'color:#f97316;' : ''">▲</span>
                    <span :style="orderSortKey === 'id' && orderSortDir === 'desc' ? 'color:#f97316;' : ''">▼</span>
                  </span>
                </th>
                <th @click="toggleOrderSort('customer')" style="cursor:pointer; user-select:none; white-space:nowrap;">
                  Vásárló
                  <span style="margin-left:4px; font-size:11px; color:#94a3b8;">
                    <span :style="orderSortKey === 'customer' && orderSortDir === 'asc' ? 'color:#f97316;' : ''">▲</span>
                    <span :style="orderSortKey === 'customer' && orderSortDir === 'desc' ? 'color:#f97316;' : ''">▼</span>
                  </span>
                </th>
                <th @click="toggleOrderSort('items')" style="cursor:pointer; user-select:none; white-space:nowrap;">
                  Termékek
                  <span style="margin-left:4px; font-size:11px; color:#94a3b8;">
                    <span :style="orderSortKey === 'items' && orderSortDir === 'asc' ? 'color:#f97316;' : ''">▲</span>
                    <span :style="orderSortKey === 'items' && orderSortDir === 'desc' ? 'color:#f97316;' : ''">▼</span>
                  </span>
                </th>
                <th @click="toggleOrderSort('total')" style="cursor:pointer; user-select:none; white-space:nowrap;">
                  Összeg
                  <span style="margin-left:4px; font-size:11px; color:#94a3b8;">
                    <span :style="orderSortKey === 'total' && orderSortDir === 'asc' ? 'color:#f97316;' : ''">▲</span>
                    <span :style="orderSortKey === 'total' && orderSortDir === 'desc' ? 'color:#f97316;' : ''">▼</span>
                  </span>
                </th>
                <th style="cursor:pointer; user-select:none; white-space:nowrap;">
                  Státusz
                </th>
                <th @click="toggleOrderSort('date')" style="cursor:pointer; user-select:none; white-space:nowrap;">
                  Dátum
                  <span style="margin-left:4px; font-size:11px; color:#94a3b8;">
                    <span :style="orderSortKey === 'date' && orderSortDir === 'asc' ? 'color:#f97316;' : ''">▲</span>
                    <span :style="orderSortKey === 'date' && orderSortDir === 'desc' ? 'color:#f97316;' : ''">▼</span>
                  </span>
                </th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="order in paginatedOrders" :key="order.id">
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
          <!-- Üres állapot -->
          <div v-if="filteredOrders.length === 0" style="text-align:center; padding:40px; color:#94a3b8;">
            Nincs találat a megadott feltételekre.
          </div>

          <!-- Rendelések pagináció -->
          <div v-if="totalOrderPages > 1" style="display:flex; justify-content:center; align-items:center; gap:8px; padding:16px; border-top:1px solid #e2e8f0;">
            <button 
              class="btn btn-sm" 
              @click="currentOrderPage--" 
              :disabled="currentOrderPage === 1"
              style="background:#f1f5f9;"
            >← Előző</button>
            
            <template v-for="page in totalOrderPages" :key="page">
              <button 
                class="btn btn-sm"
                @click="currentOrderPage = page"
                :style="currentOrderPage === page ? 'background:#f97316; color:white;' : 'background:#f1f5f9;'"
              >{{ page }}</button>
            </template>
            
            <button 
              class="btn btn-sm" 
              @click="currentOrderPage++" 
              :disabled="currentOrderPage === totalOrderPages"
              style="background:#f1f5f9;"
            >Következő →</button>
            
            <span style="color:#64748b; font-size:13px; margin-left:8px;">
              {{ filteredOrders.length }} rendelés / {{ currentOrderPage }}.oldal
            </span>
          </div>
        </div>
      </div>

      <!-- Products View -->
      <div v-if="currentView === 'products'">
        <div class="header">
          <h2>Termékek</h2>
          <div class="header-actions">
            <button class="btn btn-primary" @click="openProductModal()">
              <FontAwesomeIcon icon="fa-plus" /> Új termék
            </button>
          </div>
        </div>

        <div class="table-container">
          <div class="table-header">
            <h3 class="table-title">Összes termék</h3>
            <div class="filters-row">
              <input type="text" class="search-input" placeholder="Keresés termékek között..." v-model="productSearch">
              <select v-model="productCategoryFilter" style="padding:8px 12px; font-size:14px; border:1px solid #e2e8f0; border-radius:8px; height:38px; background:white; cursor:pointer;">
                <option value="">Összes kategória</option>
                <option>Fonalak</option>
                <option>Kötőtűk</option>
                <option>Horgolótűk</option>
                <option>Hímzőfonalak</option>
                <option>Kellékek</option>
                <option>Minták</option>
              </select>
              <select v-model="productStockFilter" style="padding:8px 12px; font-size:14px; border:1px solid #e2e8f0; border-radius:8px; height:38px; background:white; cursor:pointer;">
                <option value="">Összes készlet</option>
                <option value="raktaron">✅ Raktáron</option>
                <option value="keves">⚠️ Kevés</option>
                <option value="nincs">🚫 Nincs készleten</option>
              </select>
            </div>
          </div>
          <table>
            <thead>
              <tr>
                <th>Kép</th>
                <th @click="toggleProductSort('name')" style="cursor:pointer; user-select:none; white-space:nowrap;">
                  Név
                  <span style="margin-left:4px; font-size:11px; color:#94a3b8;">
                    <span :style="productSortKey === 'name' && productSortDir === 'asc' ? 'color:#f97316;' : ''">▲</span>
                    <span :style="productSortKey === 'name' && productSortDir === 'desc' ? 'color:#f97316;' : ''">▼</span>
                  </span>
                </th>
                <th @click="toggleProductSort('category')" style="cursor:pointer; user-select:none; white-space:nowrap;">
                  Kategória
                  <span style="margin-left:4px; font-size:11px; color:#94a3b8;">
                    <span :style="productSortKey === 'category' && productSortDir === 'asc' ? 'color:#f97316;' : ''">▲</span>
                    <span :style="productSortKey === 'category' && productSortDir === 'desc' ? 'color:#f97316;' : ''">▼</span>
                  </span>
                </th>
                <th @click="toggleProductSort('price')" style="cursor:pointer; user-select:none; white-space:nowrap;">
                  Ár
                  <span style="margin-left:4px; font-size:11px; color:#94a3b8;">
                    <span :style="productSortKey === 'price' && productSortDir === 'asc' ? 'color:#f97316;' : ''">▲</span>
                    <span :style="productSortKey === 'price' && productSortDir === 'desc' ? 'color:#f97316;' : ''">▼</span>
                  </span>
                </th>
                <th @click="toggleProductSort('stock')" style="cursor:pointer; user-select:none; white-space:nowrap;">
                  Készlet
                  <span style="margin-left:4px; font-size:11px; color:#94a3b8;">
                    <span :style="productSortKey === 'stock' && productSortDir === 'asc' ? 'color:#f97316;' : ''">▲</span>
                    <span :style="productSortKey === 'stock' && productSortDir === 'desc' ? 'color:#f97316;' : ''">▼</span>
                  </span>
                </th>
                <th>Státusz</th>
                <th>Színek</th>
                <th>Műveletek</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="product in paginatedProducts" :key="product.id">
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
                  <div style="display:flex; gap:4px; flex-wrap:wrap;">
                    <span
                      v-for="color in (product.colors ?? []).slice(0, 6)"
                      :key="color.id"
                      :title="color.nev"
                      style="width:20px; height:20px; border-radius:50%; display:inline-block; border:1.5px solid #e2e8f0; cursor:default;"
                      :style="{ background: color.hex_kod }"
                    ></span>
                    <span
                      v-if="(product.colors ?? []).length > 6"
                      style="font-size:11px; color:#94a3b8; align-self:center;"
                    >+{{ product.colors.length - 6 }}</span>
                    <span v-if="!(product.colors ?? []).length" style="color:#94a3b8; font-size:13px;">—</span>
                  </div>
                </td>
                <td>
                  <div class="action-buttons">
                    <button class="btn btn-sm btn-warning" @click="openProductModal(product)">
                      <FontAwesomeIcon icon="fa-pen" />
                    </button>
                    <button class="btn btn-sm btn-danger" @click="deleteProduct(product.id)">
                      <FontAwesomeIcon icon="fa-trash-alt" />
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
          <!-- Users pagináció -->
          <div v-if="totalProductPages > 1" style="display:flex; justify-content:center; align-items:center; gap:8px; padding:16px; border-top:1px solid #e2e8f0;">
            <button 
              class="btn btn-sm" 
              @click="currentProductPage--" 
              :disabled="currentProductPage === 1"
              style="background:#f1f5f9;"
            >← Előző</button>
            
            <template v-for="page in totalProductPages" :key="page">
              <button 
                class="btn btn-sm"
                @click="currentProductPage = page"
                :style="currentProductPage === page ? 'background:#f97316; color:white;' : 'background:#f1f5f9;'"
              >{{ page }}</button>
            </template>
            
            <button 
              class="btn btn-sm" 
              @click="currentProductPage++" 
              :disabled="currentProductPage === totalProductPages"
              style="background:#f1f5f9;"
            >Következő →</button>
            
            <span style="color:#64748b; font-size:13px; margin-left:8px;">
              {{ filteredProducts.length }} felhasználó / {{ currentProductPage }}.oldal
            </span>
          </div>
        </div>
      </div>

      <!-- Users View -->
      <div v-if="currentView === 'users'">
        <div class="header">
          <h2>Felhasználók</h2>
          <div class="header-actions">
            <button class="btn btn-primary" @click="openUserModal()">
              <FontAwesomeIcon icon="fa-plus" /> Új felhasználó
            </button>
          </div>
        </div>

        <div class="table-container">
          <div class="table-header">
            <h3 class="table-title">Összes felhasználó</h3>
            <div class="filters-row">
              <input type="text" class="search-input" placeholder="Keresés felhasználók között..." v-model="userSearch">
              <select v-model="userRoleFilter" style="padding:8px 12px; font-size:14px; border:1px solid #e2e8f0; border-radius:8px; height:38px; background:white; cursor:pointer;">
                <option value="">Összes szerepkör</option>
                <option value="admin">Admin</option>
                <option value="moderator">Moderátor</option>
                <option value="sima">Felhasználó</option>
                <option value="felfuggesztett">Felfüggesztett</option>
              </select>
              <select v-model="userActiveFilter" style="padding:8px 12px; font-size:14px; border:1px solid #e2e8f0; border-radius:8px; height:38px; background:white; cursor:pointer;">
                <option value="">Összes státusz</option>
                <option value="true">✅ Aktív</option>
                <option value="false">🚫 Inaktív</option>
              </select>
              <select v-model="userOrderFilter" style="padding:8px 12px; font-size:14px; border:1px solid #e2e8f0; border-radius:8px; height:38px; background:white; cursor:pointer;">
                <option value="">Összes rendelés</option>
                <option value="van">📦 Van rendelése</option>
                <option value="aktiv">⚠️ Aktív rendelése van</option>
                <option value="nincs">— Nincs rendelése</option>
              </select>
            </div>
          </div>
          <table>
            <thead>
              <tr>
                <th>Profilkép</th>
                <th @click="toggleUserSort('name')" style="cursor:pointer; user-select:none; white-space:nowrap;">
                  Név
                  <span style="margin-left:4px; font-size:11px; color:#94a3b8;">
                    <span :style="userSortKey === 'name' && userSortDir === 'asc' ? 'color:#f97316;' : ''">▲</span>
                    <span :style="userSortKey === 'name' && userSortDir === 'desc' ? 'color:#f97316;' : ''">▼</span>
                  </span>
                </th>
                <th>Szerepkör</th>
                <th @click="toggleUserSort('email')" style="cursor:pointer; user-select:none; white-space:nowrap;">
                  Email
                  <span style="margin-left:4px; font-size:11px; color:#94a3b8;">
                    <span :style="userSortKey === 'email' && userSortDir === 'asc' ? 'color:#f97316;' : ''">▲</span>
                    <span :style="userSortKey === 'email' && userSortDir === 'desc' ? 'color:#f97316;' : ''">▼</span>
                  </span>
                </th>
                <th>Aktív</th>
                <th>Rendelések</th>
                <th @click="toggleUserSort('registrationDate')" style="cursor:pointer; user-select:none; white-space:nowrap;">
                  Regisztráció ideje
                  <span style="margin-left:4px; font-size:11px; color:#94a3b8;">
                    <span :style="userSortKey === 'registrationDate' && userSortDir === 'asc' ? 'color:#f97316;' : ''">▲</span>
                    <span :style="userSortKey === 'registrationDate' && userSortDir === 'desc' ? 'color:#f97316;' : ''">▼</span>
                  </span>
                </th>
                <th @click="toggleUserSort('utolso_Belepes')" style="cursor:pointer; user-select:none; white-space:nowrap;">
                  Utolsó bejelentkezés
                  <span style="margin-left:4px; font-size:11px; color:#94a3b8;">
                    <span :style="userSortKey === 'utolso_Belepes' && userSortDir === 'asc' ? 'color:#f97316;' : ''">▲</span>
                    <span :style="userSortKey === 'utolso_Belepes' && userSortDir === 'desc' ? 'color:#f97316;' : ''">▼</span>
                  </span>
                </th>
                <th>Műveletek</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="user in paginatedUsers" :key="user.id">
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
                      <FontAwesomeIcon icon="fa-pen" />
                    </button>
                    <button class="btn btn-sm btn-danger" 
                      @click="deleteUser(user.id)"
                      :disabled="user.id === currentUserId || user.orderStats.active > 0"
                      :style="user.id === currentUserId || user.orderStats.active > 0 ? 'opacity: 0.4; cursor: not-allowed;' : ''"
                      :title="user.id === currentUserId || user.orderStats.active > 0 ? 'Saját fiókod nem törölheted' : ''"
                    >
                      <FontAwesomeIcon icon="fa-trash-alt" />
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
          <!-- Users pagináció -->
          <div v-if="totalPages > 1" style="display:flex; justify-content:center; align-items:center; gap:8px; padding:16px; border-top:1px solid #e2e8f0;">
            <button 
              class="btn btn-sm" 
              @click="currentPage--" 
              :disabled="currentPage === 1"
              style="background:#f1f5f9;"
            >← Előző</button>
            
            <template v-for="page in totalPages" :key="page">
              <button 
                class="btn btn-sm"
                @click="currentPage = page"
                :style="currentPage === page ? 'background:#f97316; color:white;' : 'background:#f1f5f9;'"
              >{{ page }}</button>
            </template>
            
            <button 
              class="btn btn-sm" 
              @click="currentPage++" 
              :disabled="currentPage === totalPages"
              style="background:#f1f5f9;"
            >Következő →</button>
            
            <span style="color:#64748b; font-size:13px; margin-left:8px;">
              {{ filteredUsers.length }} felhasználó / {{ currentPage }}.oldal
            </span>
          </div>
        </div>
      </div>

      <!-- Blog View -->
      <div v-if="currentView === 'blog'">
        <div class="header">
          <h2>Blogbejegyzések</h2>
          <div class="header-actions">
            <button class="btn btn-primary" @click="openBlogModal()">
              <FontAwesomeIcon icon="fa-plus" /> Új bejegyzés
            </button>
          </div>
        </div>

        <div class="table-container">
          <div class="table-header">
            <h3 class="table-title">Összes bejegyzés</h3>
            <div class="filters-row">
              <input 
                type="text" 
                class="search-input" 
                placeholder="Keresés bejegyzések között..." 
                v-model="blogSearch"
              >
              <MultiSelect
                v-model="blogTagFilter"
                :options="tagOptions"
                optionLabel="name"
                placeholder="Szűrés címke alapján"
                display="chip"
                filter
                :maxSelectedLabels="2"
                style="min-width:200px; max-width:200px; font-size:13px;"
              />
              <select 
                v-model="blogPublishedFilter" 
                style="padding:8px 10px; font-size:13px; border:1px solid #e2e8f0; border-radius:8px; height:38px; background:white; cursor:pointer;"
              >
                <option value="">Összes státusz</option>
                <option value="true">✅ Publikálva</option>
                <option value="false">🗑️ Törölt</option>
              </select>
            </div>
          </div>
          <table>
            <thead>
              <tr>
                <th @click="toggleBlogSort('title')" style="cursor:pointer; user-select:none; white-space:nowrap;">
                  Cím
                  <span style="margin-left:4px; font-size:11px; color:#94a3b8;">
                    <span :style="blogSortKey === 'title' && blogSortDir === 'asc' ? 'color:#f97316;' : ''">▲</span>
                    <span :style="blogSortKey === 'title' && blogSortDir === 'desc' ? 'color:#f97316;' : ''">▼</span>
                  </span>
                </th>
                <th @click="toggleBlogSort('author')" style="cursor:pointer; user-select:none; white-space:nowrap;">
                  Szerző
                  <span style="margin-left:4px; font-size:11px; color:#94a3b8;">
                    <span :style="blogSortKey === 'author' && blogSortDir === 'asc' ? 'color:#f97316;' : ''">▲</span>
                    <span :style="blogSortKey === 'author' && blogSortDir === 'desc' ? 'color:#f97316;' : ''">▼</span>
                  </span>
                </th>
                <th>Címkék</th>
                <th @click="toggleBlogSort('date')" style="cursor:pointer; user-select:none; white-space:nowrap;">
                  Dátum
                  <span style="margin-left:4px; font-size:11px; color:#94a3b8;">
                    <span :style="blogSortKey === 'date' && blogSortDir === 'asc' ? 'color:#f97316;' : ''">▲</span>
                    <span :style="blogSortKey === 'date' && blogSortDir === 'desc' ? 'color:#f97316;' : ''">▼</span>
                  </span>
                </th>
                <th>Státusz</th>
                <th>Műveletek</th>
              </tr>
          </thead>
            <tbody>
              <tr v-for="post in paginatedBlogPosts" :key="post.id">
                <td><strong>{{ post.title }}</strong></td>
                <td>{{ post.author }}</td>
                <td>
                  <div style="display:flex; flex-wrap:wrap; gap:4px; align-items:center;">
                    <span 
                      v-for="tag in post.tags.slice(0, 2)" 
                      :key="tag.id"
                      class="badge badge-blue"
                      style="font-size:11px; padding:2px 8px;"
                    >
                      {{ tag.nev }}
                    </span>
                    <span 
                      v-if="post.tags.length > 2"
                      class="badge"
                      style="background:#e2e8f0; color:#475569; font-size:11px; padding:2px 8px; cursor:default;"
                      :title="post.tags.slice(2).map(t => t.nev).join(', ')"
                    >
                      +{{ post.tags.length - 2 }}
                    </span>
                    <span v-if="post.tags.length === 0" style="color:#94a3b8; font-size:13px;">-</span>
                  </div>
                </td>
                <td>{{ post.date }}</td>
                <td style="text-align: center;">
                  <span class="badge" :class="post.published ? 'badge-success' : 'badge-danger'">
                    {{ post.published ? 'Publikálva' : 'törölt' }}
                  </span>
                </td>
                <td>
                  <div class="action-buttons">
                    <button class="btn btn-sm btn-warning" @click="openBlogModal(post)">
                      <FontAwesomeIcon icon="fa-pen" />
                    </button>
                    <button class="btn btn-sm btn-danger" @click="deleteBlogPost(post.id)">
                      <FontAwesomeIcon icon="fa-trash-alt" />
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
          <!-- Users pagináció -->
          <div v-if="totalBlogPages > 1" style="display:flex; justify-content:center; align-items:center; gap:8px; padding:16px; border-top:1px solid #e2e8f0;">
            <button 
              class="btn btn-sm" 
              @click="currentBlogPage--" 
              :disabled="currentBlogPage === 1"
              style="background:#f1f5f9;"
            >← Előző</button>
            
            <template v-for="page in totalBlogPages" :key="page">
              <button 
                class="btn btn-sm"
                @click="currentBlogPage = page"
                :style="currentBlogPage === page ? 'background:#f97316; color:white;' : 'background:#f1f5f9;'"
              >{{ page }}</button>
            </template>
            
            <button 
              class="btn btn-sm" 
              @click="currentBlogPage++" 
              :disabled="currentBlogPage === totalBlogPages"
              style="background:#f1f5f9;"
            >Következő →</button>
            
            <span style="color:#64748b; font-size:13px; margin-left:8px;">
              {{ filteredBlogPosts.length }} bejegyzés / {{ currentBlogPage }}.oldal
            </span>
          </div>
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
              <h3 class="chart-title">Eladott termékek havi bontásban</h3>
            </div>
            <canvas ref="productSalesChart"></canvas>
          </div>

          <div class="chart-card">
            <div class="chart-header">
              <h3 class="chart-title">Bevétel havi megoszlása</h3>
            </div>
            <canvas ref="revenueChart"></canvas>
          </div>
        </div>
      </div>
    </main>

    <!-- Product Modal (Updated - same style as Blog) -->
    <div v-if="showProductModal" class="modal-overlay" @click.self="closeProductModal">
      <div class="modal blog-modal-large">
        <div class="modal-header">
          <h3 class="modal-title">{{ editingProduct.id ? 'Termék szerkesztése' : 'Új termék' }}</h3>
          <button class="btn btn-icon" @click="closeProductModal">✕</button>
        </div>
    
        <div class="modal-body-scrollable">
          <div class="post-form">
    
            <!-- ── Név ── -->
            <div class="form-section">
              <label class="form-label">
                Termék neve <span class="required-indicator">*</span>
              </label>
              <InputText
                v-model="editingProduct.name"
                placeholder="pl. Prémium gyapjú fonal 100g"
                class="w-full mb-2"
              />
              <small class="form-hint">Adj egyértelmű, leíró nevet a terméknek</small>
            </div>
    
            <!-- ── Fő kategória (Dropdown) + Több kategória (MultiSelect) ── -->
            <div class="form-section">
              <label class="form-label">
                Fő kategória <span class="required-indicator">*</span>
              </label>
              <div style="display:flex; gap:8px; align-items:center;">
                <Dropdown
                  v-model="selectedProductCategory"
                  :options="productCategoryOptions"
                  optionLabel="nev"
                  optionValue="id"
                  placeholder="Válassz fő kategóriát"
                  filter
                  class="w-full"
                  style="flex:1;"
                />
                <button
                  type="button"
                  class="btn btn-sm"
                  style="background:#f1f5f9; white-space:nowrap; flex-shrink:0;"
                  @click="showNewCategoryInline = !showNewCategoryInline"
                  title="Új kategória létrehozása"
                ><FontAwesomeIcon icon="fa-plus" /> Új</button>
              </div>
    
              <!-- Inline új kategória -->
              <div v-if="showNewCategoryInline" class="inline-create-box">
                <input
                  type="text"
                  class="form-input"
                  v-model="newCategoryName"
                  placeholder="Kategória neve..."
                  style="flex:1;"
                  @keyup.enter="createCategory"
                />
                <select class="form-select" v-model="newCategoryParentId" style="flex:1; max-width:200px;">
                  <option :value="null">— Főkategória (nincs szülő)</option>
                  <option v-for="cat in productCategoryOptions.filter(c => !c.fo_kategoria_id)" :key="cat.id" :value="cat.id">
                    {{ cat.nev }}
                  </option>
                </select>
                <button type="button" class="btn btn-primary btn-sm" @click="createCategory" :disabled="!newCategoryName.trim()">
                  Létrehozás
                </button>
                <button type="button" class="btn btn-sm" style="background:#f1f5f9;" @click="showNewCategoryInline = false; newCategoryName = ''">
                  Mégse
                </button>
              </div>
              <small class="form-hint">Ez jelenik meg a terméklistában és a szűrőkben</small>
            </div>
    
            <!-- ── További kategóriák (MultiSelect) ── -->
            <div class="form-section">
              <label class="form-label">További kategóriák</label>
              <MultiSelect
                v-model="selectedProductCategories"
                :options="productCategoryOptions"
                optionLabel="nev"
                placeholder="Válassz további kategóriákat (opcionális)"
                display="chip"
                filter
                class="w-full mb-2"
              >
                <template #option="{ option }">
                  <div style="display:flex; align-items:center; gap:8px;">
                    <span v-if="option.fo_kategoria_id" style="color:#94a3b8; font-size:12px; margin-left:12px;">↳</span>
                    <span>{{ option.nev }}</span>
                  </div>
                </template>
              </MultiSelect>
              <small class="form-hint">A termék több kategóriában is megjelenhet (pl. alkategóriák)</small>
            </div>
    
            <!-- ── Ár és Készlet ── -->
            <div class="form-section" style="display:grid; grid-template-columns:1fr 1fr; gap:20px;">
              <div>
                <label class="form-label">Ár (Ft) <span class="required-indicator">*</span></label>
                <InputText v-model="editingProduct.price" type="number" placeholder="2990" class="w-full mb-2" />
                <small class="form-hint">Nettó ár forintban</small>
              </div>
              <div>
                <label class="form-label">Készlet (db) <span class="required-indicator">*</span></label>
                <InputText v-model="editingProduct.stock" type="number" placeholder="50" class="w-full mb-2" />
                <small class="form-hint">Aktuális raktárkészlet</small>
              </div>
            </div>
    
            <!-- ── Színek MultiSelect + Új szín ── -->
            <div class="form-section">
              <label class="form-label">
                Elérhető színek <span class="required-indicator">*</span>
              </label>
              <div style="display:flex; gap:8px; align-items:flex-start;">
                <MultiSelect
                  v-model="selectedProductColors"
                  :options="availableColors"
                  optionLabel="nev"
                  placeholder="Válassz legalább 1 színt"
                  display="chip"
                  filter
                  class="w-full"
                  style="flex:1;"
                >
                  <template #option="{ option }">
                    <div style="display:flex; align-items:center; gap:10px;">
                      <span
                        style="width:18px; height:18px; border-radius:50%; border:1.5px solid #e2e8f0; flex-shrink:0;"
                        :style="{ background: option.hex_kod }"
                      ></span>
                      <span>{{ option.nev }}</span>
                      <span style="color:#94a3b8; font-size:12px;">{{ option.hex_kod }}</span>
                    </div>
                  </template>
                  <template #chip="{ value }">
                    <div style="display:flex; align-items:center; gap:5px;">
                      <span
                        style="width:12px; height:12px; border-radius:50%; border:1px solid rgba(0,0,0,0.15); flex-shrink:0;"
                        :style="{ background: value.hex_kod }"
                      ></span>
                      <span style="font-size:12px;">{{ value.nev }}</span>
                    </div>
                  </template>
                </MultiSelect>
                <button
                  type="button"
                  class="btn btn-sm"
                  style="background:#f1f5f9; white-space:nowrap; flex-shrink:0; margin-top:2px;"
                  @click="showNewColorInline = !showNewColorInline"
                ><FontAwesomeIcon icon="fa-plus" /> Új</button>
              </div>
    
              <!-- Inline új szín -->
              <div v-if="showNewColorInline" class="inline-create-box">
                <input
                  type="text"
                  class="form-input"
                  v-model="newColorName"
                  placeholder="Szín neve (pl. Égkék)..."
                  style="flex:1;"
                  @keyup.enter="createColor"
                />
                <div style="display:flex; align-items:center; gap:8px;">
                  <label style="font-size:13px; color:#4b5563; white-space:nowrap;">Hex kód:</label>
                  <input
                    type="color"
                    v-model="newColorHex"
                    style="width:44px; height:36px; border:1px solid #e2e8f0; border-radius:6px; cursor:pointer; padding:2px;"
                  />
                  <input
                    type="text"
                    class="form-input"
                    v-model="newColorHex"
                    placeholder="#ff5733"
                    style="width:100px;"
                    @keyup.enter="createColor"
                  />
                </div>
                <button type="button" class="btn btn-primary btn-sm" @click="createColor" :disabled="!newColorName.trim()">
                  Létrehozás
                </button>
                <button type="button" class="btn btn-sm" style="background:#f1f5f9;" @click="showNewColorInline = false; newColorName = ''; newColorHex = '#000000'">
                  Mégse
                </button>
              </div>
              <small class="form-hint">Legalább 1 szín szükséges. Megjelenik a termékkártyán.</small>
            </div>
    
            <!-- ── Leírás (Editor) ── -->
            <div class="form-section">
              <label class="form-label">Leírás</label>
              <Editor
                v-model="editingProduct.description"
                :key="productEditorKey"
                ref="productEditorRef"
                editorStyle="height: 220px"
                class="mb-2 editor-container"
                :pt="{
                  toolbar: { class: 'editor-toolbar' },
                  content: { style: { 'min-height': '180px', 'font-family': 'inherit' } }
                }"
              />
              <small class="form-hint">Részletes termékleírás, anyagok, méretek, használati útmutató</small>
            </div>
    
            <!-- ── Képek feltöltése ── -->
            <div class="form-section">
              <label class="form-label">Termékképek</label>
              <FileUpload
                ref="productFileUploadRef"
                name="images[]"
                @select="onProductFileSelect"
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
                    <i class="pi pi-cloud-upload" style="font-size: 2.5rem; color: #667eea; margin-bottom: 0.75rem;"></i>
                    <p>Húzd ide a termékképeket vagy kattints a feltöltéshez</p>
                  </div>
                </template>
              </FileUpload>
    
              <!-- Képek előnézete + főkép kiválasztás -->
              <div v-if="uploadedProductImages.length > 0">
                <p style="font-size:13px; color:#64748b; margin-bottom:8px;">
                  🖱️ Kattints egy képre a <strong>főkép</strong> beállításához
                </p>
                <div class="image-preview-container">
                  <div
                    v-for="(image, index) in uploadedProductImages"
                    :key="index"
                    class="image-preview"
                    :class="{ 'image-preview-main': productMainImageIndex === index }"
                    @click="productMainImageIndex = index"
                  >
                    <!-- Főkép koronája -->
                    <div v-if="productMainImageIndex === index" class="main-image-badge">
                      ⭐ Főkép
                    </div>
                    <img :src="image.preview" class="preview-image" />
                    <!-- Törlés gomb -->
                    <button
                      type="button"
                      class="image-remove-btn"
                      @click.stop="removeProductImage(index)"
                    >
                      <i class="pi pi-times"></i>
                    </button>
                    <InputText
                      v-model="image.alt"
                      placeholder="Alt szöveg"
                      class="image-alt-input"
                      @click.stop
                    />
                  </div>
                </div>
              </div>
              <small class="form-hint">Az első (vagy kiválasztott ⭐) kép lesz a főkép. Max. 5MB/kép.</small>
            </div>
    
          </div>
        </div>
    
        <div class="modal-footer">
          <button class="btn btn-secondary" @click="closeProductModal">Mégse</button>
          <button class="btn btn-primary" @click="saveProduct" :disabled="productSaving">
            <span v-if="productSaving"><FontAwesomeIcon icon="fa-hourglass-half" /> Mentés...</span>
            <span v-else>Mentés</span>
          </button>
        </div>
      </div>
    </div>

    <!-- Blog Modal -->
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

              <label for="newTag">Ha nem találod amit keresel, akkor hozzá is tudod adni a saját címkédet:</label>
              <div class="new-tag-row">
                <InputText 
                  id="newTag"
                  v-model="newTagInput"
                  placeholder="Írj egy új címkét..."
                  class="w-full"
                  @keyup.enter="addNewTag"
                />
                <Button
                  type="button"
                  label="Hozzáadás"
                  icon="pi pi-plus"
                  class="add-tag-btn"
                  :loading="newTagLoading"
                  :disabled="!newTagInput.trim()"
                  @click="addNewTag">
                </Button>
              </div>
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
                :key="editorKey"
                ref="editorRef"
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
            <input type="text" class="form-input" v-model="editingUser.password" placeholder="•••••••••">
          </div>
          <!-- PROFILE PICTURE RESET -->
          <div class="form-group">
            <label class="form-label">Profilkép</label>
            <div class="flex items-center gap-2">
              <input type="checkbox" id="resetPic" v-model="editingUser.resetProfilePic" :disabled="editingUser.profileImage?.includes('default.jpg') || !editingUser.id" :checked="editingUser.profileImage?.includes('default.jpg') || !editingUser.id">
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
    <div 
    v-if="sidebarOpen" 
    class="sidebar-overlay" 
    @click="sidebarOpen = false"
  ></div>
    <Teleport to="body">
      <div v-if="confirmModal.visible" class="confirm-backdrop" @click.self="confirmNo">
        <div class="confirm-modal">
          <p class="confirm-message">{{ confirmModal.message }}</p>
          <div class="confirm-actions">
            <button class="confirm-btn cancel" @click="confirmNo">Mégse</button>
            <button class="confirm-btn danger" @click="confirmYes">Törlés</button>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, nextTick, watch, inject } from 'vue';
import Chart from 'chart.js/auto';
import axios from 'axios';
import MultiSelect from 'primevue/multiselect';
import Editor from 'primevue/editor';
import FileUpload from 'primevue/fileupload';
import InputText from 'primevue/inputtext';
import Checkbox from 'primevue/checkbox';
import Dropdown from 'primevue/dropdown';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import { library } from '@fortawesome/fontawesome-svg-core'
import {
  faPlus, faRefresh, faCoins,
  faTruck, faBagShopping, faUsers,
  faUser, faPoll, faChartLine,
  faFileLines, faPen, faTrashAlt,
  faHourglassHalf
} from '@fortawesome/free-solid-svg-icons'

library.add(
  faPlus, faRefresh, faCoins,
  faTruck, faBagShopping, faUsers,
  faUser, faPoll, faChartLine,
  faFileLines, faPen, faTrashAlt,
  faHourglassHalf
)

const API = '/api/admin';

// Reactive state
const currentView = ref('dashboard');
const productSearch = ref('');
const userSearch = ref('');
const blogSearch = ref('');
const showProductModal = ref(false);
const showUserModal = ref(false);
const showBlogModal = ref(false);

// Scroll lock — prevents background scroll whenever any modal is open
const isAnyModalOpen = computed(
  () => showProductModal.value || showUserModal.value || showBlogModal.value
);

watch(isAnyModalOpen, (open) => {
  document.body.style.overflow = open ? 'hidden' : '';
});

onUnmounted(() => {
  document.body.style.overflow = '';
});
const editingProduct = ref({});
const editingUser = ref({});
const editingBlogPost = ref({});
const editorKey = ref(0);
const editorRef = ref(null);
const loading = ref(false);
const sidebarOpen = ref(false);
const availableColors = ref([]);
const selectedProductColors = ref([]);
const selectedProductCategories = ref([]); 
const selectedProductCategory = ref(null); 
const uploadedProductImages = ref([]);
const productFileUploadRef = ref(null);
const productEditorKey = ref(0);
const productCategoryOptions = ref([]);
const productMainImageIndex = ref(0); 
const productSaving = ref(false);

const { showToast, showErrorModal } = inject('toast')

// Confirm modal
const confirmModal = ref({ visible: false, message: '', resolve: null })
function showConfirm(message) {
  return new Promise(resolve => {
    confirmModal.value = { visible: true, message, resolve }
  })
}
function confirmYes() { confirmModal.value.resolve(true);  confirmModal.value.visible = false }
function confirmNo()  { confirmModal.value.resolve(false); confirmModal.value.visible = false }

// Complex Form State (from new-post.vue)
const selectedTags = ref([]); 
const uploadedImages = ref([]);   // { file: File, preview: string, alt: string, id?: number }
const tagOptions = ref([]);
const fileUploadRef = ref(null);

// Új tag
const newTagInput = ref('');
const newTagLoading = ref(false);

// Inline létrehozás state-ek
const showNewCategoryInline = ref(false);
const newCategoryName = ref('');
const newCategoryParentId = ref(null);
const showNewColorInline = ref(false);
const newColorName = ref('');
const newColorHex = ref('#000000');

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
const changes = ref({
  sales: null,
  orders: null,
  products: null,
  customers: null,
});
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
  analyticsData.value = {
    ...data,
    monthlySales:  Array.isArray(data.monthlySales)  ? data.monthlySales  : Object.values(data.monthlySales  ?? {}),
    monthlyOrders: Array.isArray(data.monthlyOrders) ? data.monthlyOrders : Object.values(data.monthlyOrders ?? {}),
  };
};

const fetchProducts = async () => {
  const { data } = await axios.get('/api/termekek');
  products.value = data.map(p => ({
    id:             p.id,
    name:           p.nev,
    category:       p.termek_kategoria?.nev ?? '-',
    kategoria_id:   p.kategoria_id,
    fo_kep_id:      p.fo_kep_id,
    price:          p.ar,
    stock:          p.darab,
    description:    p.leiras ?? '',
    image:          p.termek_fo_kep?.url_Link ?? 'https://placehold.co/100x100',
    imagesData:     (p.termek_kepek ?? []).map(k => ({
      id:        k.id,
      url_Link:  k.url_Link ?? k.pivot?.url_Link ?? '',
      alt_szoveg: k.alt_Szoveg ?? k.alt_szoveg ?? ''
    })),
    colors: (p.termek_szinek ?? []).map(s => ({
      id:      s.id,
      nev:     s.nev,
      hex_kod: s.hex_kod
    })),
    extraCategories: (p.termek_kategoriak ?? []).map(k => k.id),
  }));
};


const fetchColors = async () => {
  try {
    const { data } = await axios.get('/api/szinek');
    availableColors.value = data;
  } catch (e) {
    console.error('Színek betöltése sikertelen:', e);
  }
};

const fetchProductCategories = async () => {
  try {
    const { data } = await axios.get('/api/termekek/kategoriak');
    productCategoryOptions.value = data;
  } catch (e) {
    console.error('Kategóriák betöltése sikertelen:', e);
  }
};

const onProductFileSelect = (event) => {
  const files = event.files.filter(f => f.type.startsWith('image/'));
  files.forEach(file => {
    const reader = new FileReader();
    reader.onload = (e) => {
      uploadedProductImages.value.push({ file, preview: e.target.result, alt: '', id: null });
    };
    reader.readAsDataURL(file);
  });
  if (productFileUploadRef.value) productFileUploadRef.value.clear();
};


const removeProductImage = (index) => {
  uploadedProductImages.value.splice(index, 1);
  if (productMainImageIndex.value >= uploadedProductImages.value.length) {
    productMainImageIndex.value = Math.max(0, uploadedProductImages.value.length - 1);
  }
};

const currentUserId = ref(null);
const fetchUsers = async () => {
  const { data } = await axios.get(`${API}/users`);
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
  const { data } = await axios.get('/api/admin/blog');
  blogPosts.value = data.map(p => ({
    id: p.id,
    title: p.cim,
    author: p.szerző ?? '-',
    tags: p.cimkek || [],
    date: p.letrehozas_datuma ?? '',
    published: p.statusz === 'közzétett',
    content: p.tartalom ?? '',
    kivonat: p.kivonat || '',
    imagesData: p.kepek || [],
    foKep: p.fo_kep ?? '',
  }));
};

const notification = ref({
    show: false,
    message: '',
    type: 'info'
});

const showNotification = (type, message, duration = 3500) => {
    notification.value = {
        show: true,
        message,
        type
    };
    
    setTimeout(() => {
        notification.value.show = false;
    }, duration);
};

const addNewTag = async () => {
    const name = newTagInput.value.trim();
    if (!name) return;

    const exists = tagOptions.value.find(t => t.name.toLowerCase() === name.toLowerCase());
    if (exists) {
        if (!selectedTags.value.find(t => t.id === exists.id)) {
            selectedTags.value.push(exists);
        }
        newTagInput.value = '';
        showNotification('info', `"${name}" már létező címke, kiválasztva.`);
        return;
    }

    newTagLoading.value = true;
    try {
        const response = await axios.post('/api/cimkek', { nev: name }, { withCredentials: true });
        const tag = {
            id: response.data.id,
            name: response.data.nev,
            code: response.data.nev.toLowerCase().replace(/\s+/g, '_')
        };
        tagOptions.value.push(tag);
        selectedTags.value.push(tag);
        newTagInput.value = '';
        showNotification('success', `"${name}" címke hozzáadva és kiválasztva!`);
    } catch (error) {
        const msg = error.response?.data?.errors?.nev?.[0] || 'Nem sikerült hozzáadni a címkét.';
        showNotification('error', msg);
    } finally {
        newTagLoading.value = false;
    }
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
  if (!editingProduct.value.name?.trim()) {
    showToast('A termék neve kötelező!', 'error');
    return;
  }
  if (!selectedProductCategory.value) {
    showToast('Válassz fő kategóriát!', 'error');
    return;
  }
  if (selectedProductColors.value.length === 0) {
    showToast('Legalább 1 színt válassz!', 'error');
    return;
  }

  productSaving.value = true;

  try {
    // ── 1. Csak az ÚJ képeket töltjük fel a szerverre ────────
    const newImageIds = [];
    const newImages = uploadedProductImages.value.filter(img => img.file);

    if (newImages.length > 0) {
      const formData = new FormData();
      newImages.forEach((img, index) => {
        formData.append('images[]', img.file);
        formData.append(`alt[${index}]`, img.alt || '');
      });
      const uploadRes = await axios.post('/api/upload-termekek-pictures', formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
        withCredentials: true
      });
      uploadRes.data.images.forEach(u => newImageIds.push(u.id));
    }

    // ── 2. Összes kép ID-jét összegyűjtjük a helyes sorrendben
    // uploadedProductImages sorrendje meghatározza a rendezes-t
    let newImageIdxCounter = 0;
    const allImageIds = uploadedProductImages.value.map(img => {
      if (img.file) {
        // Új feltöltött kép — a newImageIds tömbből vesszük sorban
        return newImageIds[newImageIdxCounter++] ?? null;
      }
      // Meglévő kép — az id-je már van
      return img.id ?? null;
    }).filter(id => id !== null);

    // ── 3. Főkép ID — a kiválasztott index alapján ────────────
    const foKepId = allImageIds[productMainImageIndex.value] ?? allImageIds[0] ?? null;

    // ── 4. Payload összeállítása ──────────────────────────────
    const payload = {
      nev:           editingProduct.value.name.trim(),
      kategoria_id:  selectedProductCategory.value,
      ar:            Number(editingProduct.value.price),
      darab:         Number(editingProduct.value.stock),
      leiras:        productEditorRef.value?.quill
                        ? productEditorRef.value.quill.root.innerHTML
                        : (editingProduct.value.description ?? ''),
      fo_kep_id:     foKepId,
      szinek:        selectedProductColors.value.map(c => c.id),
      extra_kategoriak: selectedProductCategories.value.map(c => c.id),
      kepek:         allImageIds,
    };

    let savedId;
    if (editingProduct.value.id) {
      await axios.put(`${API}/termekek/${editingProduct.value.id}`, payload);
      savedId = editingProduct.value.id;
    } else {
      const { data } = await axios.post(`${API}/termekek`, payload);
      savedId = data.id;
    }

    showProductModal.value = false;

    // ── 5. Teljes lista frissítése a szerverről ───────────────
    await fetchProducts();

  } catch (error) {
    console.error('Mentési hiba:', error);
    showToast(
      'Hiba történt a termék mentése során.',
      'error',
      error.response?.data?.message ?? error.message
    )
  } finally {
    productSaving.value = false;
  }
};


const deleteProduct = async (id) => {
  const confirmed = await showConfirm('Biztosan törölni szeretnéd ezt a terméket?')
  if (!confirmed) return;
  await axios.delete(`${API}/termekek/${id}`);
  await fetchProducts();
  showToast('Termék törölve.', 'info')
};

const saveUser = async () => {
  if (editingUser.value.id && editingUser.value.id === currentUserId.value) {
    showToast('Saját fiókodat nem módosíthatod az admin felületen!', 'error');
    return;
  }
  if(!editingUser.value.id && !editingUser.value.password) {
    showToast('Új felhasználónál a jelszó megadása kötelező.', 'error');
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
    showToast('Felhasználó sikeresen mentve.')
  } catch (error) {
    showToast('Hiba történt a felhasználó mentése során.', 'error');
  }

};

const deleteUser = async (id) => {
  const confirmed = await showConfirm('Biztosan törölni szeretnéd ezt a felhasználót?')
  if (!confirmed) return;
  
  try {
    const response = await axios.delete(`${API}/users/${id}`);
    
    // If successful, refresh list and show success message
    await fetchUsers();
    showToast(response.data.message || 'Sikeresen törölve!');
    
  } catch (error) {
    // If error (like 403 for active orders), show the backend error message
    showToast(
      'Nem sikerült törölni.',
      'error',
      error.response?.data?.error || 'Ismeretlen hiba történt.'
    )
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
      const uploadRes = await axios.post('/api/upload-termekek-pictures', formData, {
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
    showToast('Bejegyzés sikeresen mentve.')
  } catch (error) {
    console.error('Save error:', error);
    showToast('Hiba történt a mentés során.', 'error')
  }
};

const deleteBlogPost = async (id) => {
  const confirmed = await showConfirm('Biztosan törölni szeretnéd ezt a bejegyzést?')
  if (!confirmed) return;
  await axios.delete(`/api/posts/${id}`);
  await fetchBlogPosts();
  showToast('Bejegyzés törölve.', 'info')
};

const refreshData = async () => {
  loading.value = true;
  await Promise.all([fetchStats(), fetchOrders(), fetchAnalytics()]);
  loading.value = false;
};


const createCategory = async () => {
  if (!newCategoryName.value.trim()) return;
  try {
    const { data } = await axios.post(`${API}/kategoriak`, {
      nev: newCategoryName.value.trim(),
      fo_kategoria_id: newCategoryParentId.value ?? null,
    });
    await fetchProductCategories();
    selectedProductCategory.value = data.id;
    newCategoryName.value = '';
    newCategoryParentId.value = null;
    showNewCategoryInline.value = false;
  } catch (e) {
    const status = e.response?.status;
    const dbMsg  = e.response?.data?.message ?? '';
    if (status === 422 || (status === 500 && dbMsg.includes('Duplicate entry'))) {
      let existing = productCategoryOptions.value.find(
        c => c.nev.toLowerCase() === newCategoryName.value.trim().toLowerCase()
      );
      if (!existing) {
        await fetchProductCategories();
        existing = productCategoryOptions.value.find(
          c => c.nev.toLowerCase() === newCategoryName.value.trim().toLowerCase()
        );
      }
      if (existing) {
        selectedProductCategory.value = existing.id;
        newCategoryName.value = '';
        newCategoryParentId.value = null;
        showNewCategoryInline.value = false;
      } else {
        showToast(`"${newCategoryName.value}" kategória már létezik, de nem sikerült megtalálni.`, 'error');
      }
    } else {
      showToast('Hiba a kategória létrehozásakor.', 'error', dbMsg || e.message);
    }
  }
};

const createColor = async () => {
  if (!newColorName.value.trim()) return;
  try {
    const { data } = await axios.post(`${API}/szinek`, {
      nev: newColorName.value.trim(),
      hex_kod: newColorHex.value,
    });
    await fetchColors();
    const newColor = availableColors.value.find(c => c.id === data.id);
    if (newColor) selectedProductColors.value = [...selectedProductColors.value, newColor];
    newColorName.value = '';
    newColorHex.value = '#000000';
    showNewColorInline.value = false;
  } catch (e) {
    const status = e.response?.status;
    const dbMsg  = e.response?.data?.message ?? '';
    if (status === 422 || (status === 500 && dbMsg.includes('Duplicate entry'))) {
      // Meglévő szín keresése
      let existing = availableColors.value.find(
        c => c.nev.toLowerCase() === newColorName.value.trim().toLowerCase()
      );
      if (!existing) {
        await fetchColors();
        existing = availableColors.value.find(
          c => c.nev.toLowerCase() === newColorName.value.trim().toLowerCase()
        );
      }
      if (existing) {
        // Csak akkor adjuk hozzá, ha még nincs kijelölve
        const alreadySelected = selectedProductColors.value.some(c => c.id === existing.id);
        if (!alreadySelected) {
          selectedProductColors.value = [...selectedProductColors.value, existing];
        }
        newColorName.value = '';
        newColorHex.value = '#000000';
        showNewColorInline.value = false;
      } else {
        showToast(`"${newColorName.value}" szín már létezik, de nem sikerült megtalálni.`, 'error');
      }
    } else {
      showToast('Hiba a szín létrehozásakor.', 'error', dbMsg || e.message)
    }
  }
};

// --- Modals ---

const closeProductModal = () => {
  showProductModal.value = false;
  showNewCategoryInline.value = false;
  showNewColorInline.value = false;
  newCategoryName.value = '';
  newColorName.value = '';
};

const openProductModal = async (product = null) => {
  // Reset
  uploadedProductImages.value = [];
  selectedProductCategory.value = null;
  selectedProductCategories.value = [];
  selectedProductColors.value = [];
  productMainImageIndex.value = 0;
  showNewCategoryInline.value = false;
  showNewColorInline.value = false;
  productEditorKey.value++; // Editor újrarendereléséhez

  // Adatok betöltése ha még nincs
  await Promise.all([
    productCategoryOptions.value.length === 0 ? fetchProductCategories() : Promise.resolve(),
    availableColors.value.length === 0 ? fetchColors() : Promise.resolve(),
  ]);

  if (product) {
    editingProduct.value = { ...product };

    // FŐ kategória
    selectedProductCategory.value = product.kategoria_id ?? null;

    // TÖBB kategória — a pivot táblából
    selectedProductCategories.value = product.extraCategories
      ? product.extraCategories
          .map(id => productCategoryOptions.value.find(c => c.id === id))
          .filter(Boolean)
      : [];

    // Képek visszatöltése
    if (product.imagesData?.length) {
      uploadedProductImages.value = product.imagesData.map(img => ({
        id: img.id,
        file: null,
        preview: img.url_Link,
        alt: img.alt_szoveg || ''
      }));
      // Főkép indexe: amelyik kép ID megegyezik a fo_kep_id-vel
      const mainIdx = product.imagesData.findIndex(img => img.id === product.fo_kep_id);
      productMainImageIndex.value = mainIdx >= 0 ? mainIdx : 0;
    } else if (product.fo_kep_id && product.image && !product.image.includes('placehold.co')) {
      uploadedProductImages.value = [{ id: product.fo_kep_id, file: null, preview: product.image, alt: product.name }];
      productMainImageIndex.value = 0;
    }

    // Színek visszatöltése
    selectedProductColors.value = product.colors
      ? product.colors.map(c => availableColors.value.find(a => a.id === c.id)).filter(Boolean)
      : [];

  } else {
    editingProduct.value = { name: '', price: 0, stock: 0, description: '' };
  }

  showProductModal.value = true;

  await nextTick();

  const descriptionHtml = product?.description ?? '';

  await new Promise(resolve => {
    const interval = setInterval(() => {
      if (productEditorRef.value?.quill) {
        clearInterval(interval);
        resolve();
      }
    }, 20);
    setTimeout(() => { clearInterval(interval); resolve(); }, 2000);
  });

  if (productEditorRef.value?.quill && descriptionHtml) {
    const quill = productEditorRef.value.quill;
    quill.setText(''); 
    const editorEl = quill.root; 
    editorEl.innerHTML = descriptionHtml; 
    quill.update();
  }
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

const openBlogModal = async (post = null) => {
  // Reset complex form state
  selectedTags.value = [];
  uploadedImages.value = [];
  if (tagOptions.value.length === 0) {
    await fetchTagsFromDatabase();
  }

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
    selectedTags.value = post.tags
      ? post.tags.map(tag => 
          tagOptions.value.find(opt => opt.id === tag.id)
        ).filter(Boolean)
      : [];

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

  editorKey.value++;
await nextTick();

// Poll until Quill is ready (it initializes async after mount)
await new Promise(resolve => {
    const interval = setInterval(() => {
        if (editorRef.value?.quill) {
            clearInterval(interval);
            resolve();
        }
    }, 20);
    // Safety timeout after 2s
    setTimeout(() => { clearInterval(interval); resolve(); }, 2000);
});

if (editorRef.value?.quill) {
    editorRef.value.quill.clipboard.dangerouslyPasteHTML(editingBlogPost.value.content);
}
};

// --- Oldalbontas ---
const ITEMS_PER_PAGE = 10;
const currentPage = ref(1);
const currentProductPage = ref(1);
const currentBlogPage = ref(1);
const totalPages = computed(() => Math.ceil(filteredUsers.value.length / ITEMS_PER_PAGE));
const currentOrderPage = ref(1);
const orderSearch = ref('');
const orderStatusFilter = ref('');
const blogTagFilter = ref([]);
const orderSortKey = ref('');
const orderSortDir = ref('asc');

const toggleOrderSort = (key) => {
  if (orderSortKey.value === key) {
    orderSortDir.value = orderSortDir.value === 'asc' ? 'desc' : 'asc';
  } else {
    orderSortKey.value = key;
    orderSortDir.value = 'asc';
  }
  currentOrderPage.value = 1;
};

const filteredOrders = computed(() => {
  let result = recentOrders.value.filter(order => {
    const s = orderSearch.value.toLowerCase();
    const matchesSearch = !s || 
      order.customer.toLowerCase().includes(s) ||
      String(order.id).includes(s);
    const matchesStatus = !orderStatusFilter.value || order.status === orderStatusFilter.value;
    return matchesSearch && matchesStatus;
  });

  if (orderSortKey.value) {
    result = [...result].sort((a, b) => {
      let aVal = a[orderSortKey.value];
      let bVal = b[orderSortKey.value];

      // Dátum összehasonlítás
      if (orderSortKey.value === 'date') {
        aVal = new Date(aVal);
        bVal = new Date(bVal);
      }
      // Szám összehasonlítás (id, total, items)
      else if (['id', 'total', 'items'].includes(orderSortKey.value)) {
        aVal = parseInt(String(aVal).replace(/[^0-9]/g, ''), 10);
        bVal = parseInt(String(bVal).replace(/[^0-9]/g, ''), 10);
      }
      // String összehasonlítás
      else {
        aVal = String(aVal).toLowerCase();
        bVal = String(bVal).toLowerCase();
      }

      if (aVal < bVal) return orderSortDir.value === 'asc' ? -1 : 1;
      if (aVal > bVal) return orderSortDir.value === 'asc' ? 1 : -1;
      return 0;
    });
  }

  return result;
});

// --- Termék rendezés + szűrés ---
const productSortKey = ref('');
const productSortDir = ref('asc');
const productCategoryFilter = ref('');
const productStockFilter = ref('');
const productEditorRef = ref(null);
const toggleProductSort = (key) => {
  if (productSortKey.value === key) {
    productSortDir.value = productSortDir.value === 'asc' ? 'desc' : 'asc';
  } else {
    productSortKey.value = key;
    productSortDir.value = 'asc';
  }
  currentProductPage.value = 1;
};

const filteredProducts = computed(() => {
  let result = products.value.filter(p => {
    const s = productSearch.value.toLowerCase();
    const matchesSearch = !s || p.name.toLowerCase().includes(s) || p.category.toLowerCase().includes(s);
    const matchesCategory = !productCategoryFilter.value || p.category === productCategoryFilter.value;
    const matchesStock = !productStockFilter.value ||
      (productStockFilter.value === 'raktaron' && p.stock > 10) ||
      (productStockFilter.value === 'keves' && p.stock > 0 && p.stock <= 10) ||
      (productStockFilter.value === 'nincs' && p.stock === 0);
    return matchesSearch && matchesCategory && matchesStock;
  });

  if (productSortKey.value) {
    result = [...result].sort((a, b) => {
      let aVal = a[productSortKey.value];
      let bVal = b[productSortKey.value];
      if (['price', 'stock'].includes(productSortKey.value)) {
        aVal = Number(aVal); bVal = Number(bVal);
      } else {
        aVal = String(aVal).toLowerCase(); bVal = String(bVal).toLowerCase();
      }
      if (aVal < bVal) return productSortDir.value === 'asc' ? -1 : 1;
      if (aVal > bVal) return productSortDir.value === 'asc' ? 1 : -1;
      return 0;
    });
  }
  return result;
});

// --- Felhasználó rendezés + szűrés ---
const userSortKey = ref('');
const userSortDir = ref('asc');
const userRoleFilter = ref('');
const userActiveFilter = ref('');
const userOrderFilter = ref('');

const toggleUserSort = (key) => {
  if (userSortKey.value === key) {
    userSortDir.value = userSortDir.value === 'asc' ? 'desc' : 'asc';
  } else {
    userSortKey.value = key;
    userSortDir.value = 'asc';
  }
  currentPage.value = 1;
};

const filteredUsers = computed(() => {
  let result = users.value.filter(u => {
    const s = userSearch.value.toLowerCase();
    const matchesSearch = !s || u.name.toLowerCase().includes(s) || u.email.toLowerCase().includes(s) || u.role.toLowerCase().includes(s);
    const matchesRole = !userRoleFilter.value || u.role === userRoleFilter.value;
    const matchesActive = userActiveFilter.value === '' || u.active === (userActiveFilter.value === 'true');
    const matchesOrder = !userOrderFilter.value ||
      (userOrderFilter.value === 'van' && u.orderStats?.total > 0) ||
      (userOrderFilter.value === 'aktiv' && u.orderStats?.active > 0) ||
      (userOrderFilter.value === 'nincs' && !u.orderStats?.total);
    return matchesSearch && matchesRole && matchesActive && matchesOrder;
  });

  if (userSortKey.value) {
    result = [...result].sort((a, b) => {
      let aVal = a[userSortKey.value];
      let bVal = b[userSortKey.value];
      if (['registrationDate', 'utolso_Belepes'].includes(userSortKey.value)) {
        aVal = new Date(aVal || 0); bVal = new Date(bVal || 0);
      } else {
        aVal = String(aVal ?? '').toLowerCase(); bVal = String(bVal ?? '').toLowerCase();
      }
      if (aVal < bVal) return userSortDir.value === 'asc' ? -1 : 1;
      if (aVal > bVal) return userSortDir.value === 'asc' ? 1 : -1;
      return 0;
    });
  }
  return result;
});

// --- Blog rendezés + szűrés ---
const blogSortKey = ref('');
const blogSortDir = ref('asc');
const blogPublishedFilter = ref('');

const toggleBlogSort = (key) => {
  if (blogSortKey.value === key) {
    blogSortDir.value = blogSortDir.value === 'asc' ? 'desc' : 'asc';
  } else {
    blogSortKey.value = key;
    blogSortDir.value = 'asc';
  }
  currentBlogPage.value = 1;
};

const filteredBlogPosts = computed(() => {
  let result = blogPosts.value.filter(p => {
    const s = blogSearch.value.toLowerCase();
    const matchesSearch = !s || p.title.toLowerCase().includes(s) || p.author.toLowerCase().includes(s);
    const matchesPublished = blogPublishedFilter.value === '' || p.published === (blogPublishedFilter.value === 'true');
    const matchesTag = blogTagFilter.value.length === 0 || 
      blogTagFilter.value.every(selectedTag => 
        p.tags.some(t => t.id === selectedTag.id)
      );
    return matchesSearch && matchesPublished && matchesTag;
  });

  if (blogSortKey.value) {
    result = [...result].sort((a, b) => {
      let aVal = a[blogSortKey.value];
      let bVal = b[blogSortKey.value];
      if (blogSortKey.value === 'date') {
        aVal = new Date(aVal || 0); bVal = new Date(bVal || 0);
      } else {
        aVal = String(aVal ?? '').toLowerCase(); bVal = String(bVal ?? '').toLowerCase();
      }
      if (aVal < bVal) return blogSortDir.value === 'asc' ? -1 : 1;
      if (aVal > bVal) return blogSortDir.value === 'asc' ? 1 : -1;
      return 0;
    });
  }
  return result;
});

const totalOrderPages = computed(() => Math.ceil(filteredOrders.value.length / ITEMS_PER_PAGE));

const paginatedOrders = computed(() => {
  const start = (currentOrderPage.value - 1) * ITEMS_PER_PAGE;
  return filteredOrders.value.slice(start, start + ITEMS_PER_PAGE);
});

const paginatedUsers = computed(() => {
  const start = (currentPage.value - 1) * ITEMS_PER_PAGE;
  return filteredUsers.value.slice(start, start + ITEMS_PER_PAGE);
});

const paginatedProducts = computed(() => {
  const start = (currentProductPage.value - 1) * ITEMS_PER_PAGE;
  return filteredProducts.value.slice(start, start + ITEMS_PER_PAGE);
});

const totalProductPages = computed(() => Math.ceil(filteredProducts.value.length / ITEMS_PER_PAGE));

const paginatedBlogPosts = computed(() => {
  const start = (currentBlogPage.value - 1) * ITEMS_PER_PAGE;
  return filteredBlogPosts.value.slice(start, start + ITEMS_PER_PAGE);
});

const totalBlogPages = computed(() => Math.ceil(filteredBlogPosts.value.length / ITEMS_PER_PAGE));

// --- Watchers ---
watch(orderSearch, () => { currentOrderPage.value = 1; });
watch(orderStatusFilter, () => { currentOrderPage.value = 1; });
watch(userSearch, () => { currentPage.value = 1; });
watch(productSearch, () => { currentProductPage.value = 1; });
watch(blogSearch, () => { currentBlogPage.value = 1; });
watch(productCategoryFilter, () => { currentProductPage.value = 1; });
watch(productStockFilter, () => { currentProductPage.value = 1; });
watch(userRoleFilter, () => { currentPage.value = 1; });
watch(userActiveFilter, () => { currentPage.value = 1; });
watch(userOrderFilter, () => { currentPage.value = 1; });
watch(blogPublishedFilter, () => { currentBlogPage.value = 1; });
watch(blogTagFilter, () => { currentBlogPage.value = 1; });
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
const currentMonth = new Date().getMonth() + 1;

const initCharts = () => {
  nextTick(() => {
    if (salesChart.value && !salesChartInstance) {
      salesChartInstance = new Chart(salesChart.value, {
        type: 'line',
        data: {
          labels: MONTHS.slice(0, currentMonth),
          datasets: [{
            label: 'Értékesítés (Ft)',
            data: analyticsData.value.monthlySales.slice(0, currentMonth),
            borderColor: '#f97316',
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
    const foKats = analyticsData.value.categories;
    const FO_HUES = foKats.map((_, i) => 
      Math.round((i / foKats.length) * 360)
    );


    // Főkategória színek: telített, közepes világosság
    const foBg = foKats.map((_, i) => {
      const hue = FO_HUES[i % FO_HUES.length];
      return `hsl(${hue}, 62%, 52%)`;
    });

    // Alkategória színek: ugyanaz a hue, halvány + kissé eltolva
    const alBg = foKats.flatMap((k, i) => {
      const hue = FO_HUES[i % FO_HUES.length];
      return (k.alkategoriak ?? []).map((_, j) => {
        const lightness = 72 + (j * 4);
        return `hsl(${hue}, 48%, ${Math.min(lightness, 87)}%)`;
      });
    });

    const foLabels = foKats.map(k => k.nev);
    const foData   = foKats.map(k => k.db);

    const alLabels = foKats.flatMap(k =>
      (k.alkategoriak ?? []).map(a => a.nev)
    );
    const alData = foKats.flatMap(k =>
      (k.alkategoriak ?? []).map(a => a.db)
    );

    // Szülő neve minden alkategóriához → tooltip-hez
    const alParent = foKats.flatMap(k =>
      (k.alkategoriak ?? []).map(() => k.nev)
    );

    const grandTotal = [...foData, ...alData].reduce((s, v) => s + v, 0);

    categoryChartInstance = new Chart(categoryChart.value, {
      type: 'doughnut',
      data: {
        labels: [...foLabels, ...alLabels],
        datasets: [
          {
            label: 'Főkategóriák',
            data: foData,
            backgroundColor: foBg,
            borderWidth: 3,
            borderColor: '#ffffff',
            hoverOffset: 8,
          },
          {
            label: 'Alkategóriák',
            data: alData,
            backgroundColor: alBg,
            borderWidth: 2,
            borderColor: '#ffffff',
            hoverOffset: 5,
          },
        ]
      },
      options: {
        responsive: true,
          maintainAspectRatio: true,
          aspectRatio: 1.8, 
        cutout: '40%',   // kétszintes gyűrű jól látható marad
        plugins: {
          legend: {
            position: 'bottom',
            labels: {
              boxWidth: 12,
              boxHeight: 12,
              borderRadius: 3,
              useBorderRadius: true,
              padding: 12,
              font: { size: 12 },
              // Csak a 6 főkategória jelenik meg a legendában
              filter: (item) => item.datasetIndex === 0,
            }
          },
          tooltip: {
            callbacks: {
              title: (items) => {
                const item = items[0];
                if (item.datasetIndex === 1) {
                  // "Kiegészítők › Ollók"
                  return `${alParent[item.dataIndex]} › ${item.label}`;
                }
                return item.label;
              },
              label: (ctx) => {
                const db  = ctx.parsed;
                const pct = grandTotal > 0
                  ? ((db / grandTotal) * 100).toFixed(1)
                  : '0.0';
                const type = ctx.datasetIndex === 0 ? 'Főkategória' : 'Alkategória';
                return ` ${type}: ${db} db  (${pct}%)`;
              }
            }
          }
        }
      }
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
  const { data } = await axios.get('/api/admin/user/id');
  currentUserId.value = data.id;

  await Promise.all([
      fetchStats(), 
      fetchOrders(), 
      fetchAnalytics(), 
      fetchProducts(),
      fetchUsers(),
      fetchBlogPosts(),
      fetchTagsFromDatabase(),
      fetchProductCategories(),
      fetchColors(),
  ]);
  initCharts();
});

watch(currentView, async (newView, oldView) => {
  if (newView === 'blog' && tagOptions.value.length === 0) {
    await fetchTagsFromDatabase();
  }
  if (oldView === 'dashboard') destroyDashboardCharts();
  if (oldView === 'analytics') destroyAnalyticsCharts();
  initCharts();
});
</script>

<style scoped>
.dashboard-wrapper {
  display: flex;
  min-height: calc(100vh - 160px);
  background: #fcfaf8;
  margin-top: 10px;
}

/* Sidebar */
.sidebar {
  width: 260px;
  background: #7a402d;
  color: white;
  padding: 0;
  overflow-y: auto;
  box-shadow: 0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1);
}

.sidebar-header {
  padding: 24px 20px;
  border-bottom: 1px solid #a73f17;
}

.sidebar-header h1 {
  font-size: 22px;
  font-weight: 700;
  color: white;
  margin-bottom: 4px;
}

.sidebar-header p {
  font-size: 13px;
  color: #b8a394;
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
  color: #e1d7cb;
  text-decoration: none;
  border-radius: 8px;
  transition: all 0.2s;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
}

.nav-link:hover {
  background: #a63e1e;
  color: white;
}

.nav-link.active {
  background: #ff8a65;
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
  min-width: 0;
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
  color: #3b281e;
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
  border: 1px solid #f0e9e2;
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
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 20px;
  margin-bottom: 32px;
}

.chart-card {
  background: white;
  padding: 24px;
  border-radius: 12px;
  box-shadow: 0 1px 3px 0 rgb(0 0 0 / 0.1), 0 1px 2px -1px rgb(0 0 0 / 0.1);
  border: 1px solid #e2e8f0;
  overflow: hidden;
  min-width: 0;
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
  overflow: auto;
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
  width: 220px;
  transition: border-color 0.2s;
}

.search-input:focus {
  outline: none;
  border-color: #f97316;
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
  background: #f97316;
  color: white;
}

.btn-primary:hover {
  background: #ea6c0a;
}

.btn-secondary {
    background: #e2e8f0;
    color: #1e293b;
}

.btn-secondary:hover {
    background: #cbd5e1;
}

.btn-warning {
  background: #d6bf3c;
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
  margin-top: 100px;
  margin-bottom: 20px;
}

.blog-modal-large {
    max-width: 1000px;
    height: 90vh;
}

.new-tag-row {
  display: flex;
  gap: 10px;
  align-items: center;
  margin-top: 8px;
  margin-bottom: 24px;
}

.add-tag-btn {
  white-space: nowrap;
  flex-shrink: 0;
  background-color: #9e6c2b;
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
  border-color: #f97316;
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
  background: #fff7ed;
  color: #9a3412;
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

/* ── Filters row ── */
.filters-row {
  display: flex;
  gap: 10px;
  align-items: center;
  flex-wrap: wrap;
}

/* ── Pagination ── */
.pagination {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 8px;
  padding: 16px;
  border-top: 1px solid #e2e8f0;
  flex-wrap: wrap;
}

.pagination-info {
  color: #64748b;
  font-size: 13px;
  margin-left: 8px;
}

@media (max-width: 1024px) {
  .sidebar {
    position: fixed;
    top: 0; left: 0;
    height: 100vh;
    z-index: 200;
    transform: translateX(-100%);
    transition: transform 0.3s ease;
    width: 260px;
  }
  .sidebar.sidebar-open { transform: translateX(0); }
  .sidebar-overlay {
    position: fixed;
    inset: 0;
    background: rgba(0,0,0,0.4);
    z-index: 199;
  }
  .sidebar-toggle {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 40px; height: 40px;
    background: #7a402d;
    color: white;
    border: none;
    border-radius: 8px;
    font-size: 20px;
    cursor: pointer;
    margin-bottom: 20px;
  }
  .main-content { padding: 16px; width: 100%; }

  .main-content {
    padding: 16px;
    width: 100%;
  }

  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
    gap: 12px;
  }

  .table-container {
    overflow-x: auto;
  }

  .table-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
  }

  .search-input {
    width: 100%;
  }

  .search-box {
    width: 100%;
  }

  td, th {
    padding: 10px 12px;
  }

  .header {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
  }

  /* Filters */
  .filters-row {
    width: 100%;
    flex-direction: column;
    align-items: stretch;
  }

  .filters-row select,
  .filters-row input {
    width: 100% !important;
    min-width: unset !important;
    max-width: unset !important;
    box-sizing: border-box;
  }

  /* Modals — full screen on mobile */
  .modal-overlay {
    padding: 0;
    align-items: flex-end;
  }

  .modal,
  .blog-modal-large {
    max-width: 100%;
    width: 100%;
    max-height: 95vh;
    border-radius: 16px 16px 0 0;
  }

  .modal {
    margin-top: 80px;
  }

  /* Tables */
  td {
    font-size: 13px;
    padding: 12px 10px;
  }

  th {
    font-size: 11px;
    padding: 8px 10px;
  }

  /* Pagination — hide page number buttons, show only prev/next */
  .pagination .page-btn {
    display: none;
  }

  .pagination-info {
    margin-left: 0;
    width: 100%;
    text-align: center;
  }

  /* Action buttons in table rows */
  .action-buttons {
    flex-direction: column;
    gap: 4px;
  }

  .chart-card canvas {
    width: 100% !important;
    max-width: 100% !important;
    max-height: 260px !important;
  }
}

/* ── Mobile (max 480px) ── */
@media (max-width: 480px) {
  /* Main padding */
  .main-content {
    padding: 12px;
  }

  /* Header */
  .header h2 {
    font-size: 22px;
  }

  .header-actions .btn {
    font-size: 13px;
    padding: 8px 14px;
  }

  /* Stat cards */
  .stat-card {
    padding: 16px;
  }

  .stats-grid {
    grid-template-columns: 1fr;
  }

  .stat-value {
    font-size: 24px;
  }

  .stat-value {
    font-size: 22px;
  }

  .stat-change {
    font-size: 11px;
  }

  /* Chart cards */
  .chart-card {
    padding: 16px;
  }

  .chart-title {
    font-size: 15px;
  }

  /* Table header */
  .table-header {
    padding: 14px 16px;
  }

  .table-title {
    font-size: 15px;
  }

  /* Modal */
  .modal-header,
  .modal-footer {
    padding: 16px;
  }

  .modal-body,
  .modal-body-scrollable {
    padding: 16px;
  }

  .modal-title {
    font-size: 16px;
  }

  .chart-card {
    padding: 12px;
  }

  .chart-card canvas {
    width: 100% !important;
    max-width: 100% !important;
    max-height: 200px !important;
  }
}

@media (min-width: 1025px) {
  .sidebar-toggle { display: none; }
  .sidebar-overlay { display: none; }
}

@media (max-width: 1024px) {
  .charts-grid {
    grid-template-columns: 1fr;
  }

  .search-input {
    width: 180px;
  }
}

.inline-create-box {
  display: flex;
  gap: 8px;
  align-items: center;
  flex-wrap: wrap;
  margin-top: 10px;
  padding: 12px 16px;
  background: #f8fafc;
  border: 1.5px dashed #cbd5e1;
  border-radius: 10px;
  animation: fadeIn 0.15s ease;
}
 
.inline-create-box .form-input,
.inline-create-box .form-select {
  padding: 8px 12px;
  font-size: 13px;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  background: white;
}
 
/* ── Főkép kijelölés ── */
.image-preview {
  position: relative;
  border-radius: 10px;
  overflow: visible; /* badge kilóghat */
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
  cursor: pointer;
  border: 2.5px solid transparent;
  transition: border-color 0.18s, box-shadow 0.18s, transform 0.15s;
}
 
.image-preview:hover {
  border-color: #f97316;
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(249,115,22,0.18);
}
 
.image-preview-main {
  border-color: #f97316 !important;
  box-shadow: 0 0 0 3px rgba(249,115,22,0.25), 0 4px 16px rgba(249,115,22,0.2) !important;
}
 
.main-image-badge {
  position: absolute;
  top: -10px;
  left: 50%;
  transform: translateX(-50%);
  background: #f97316;
  color: white;
  font-size: 10px;
  font-weight: 700;
  padding: 2px 8px;
  border-radius: 20px;
  white-space: nowrap;
  z-index: 5;
  box-shadow: 0 2px 6px rgba(249,115,22,0.4);
}
 
/* ── PrimeVue Dropdown stílusozás ── */
:deep(.p-dropdown) {
  border: 2px solid #e2e8f0;
  border-radius: 10px;
  transition: all 0.3s ease;
  width: 100%;
}
 
:deep(.p-dropdown:not(.p-disabled):hover) {
  border-color: #cbd5e0;
}
 
:deep(.p-dropdown:not(.p-disabled).p-focus) {
  border-color: #4d8af0;
  box-shadow: 0 0 0 3px rgba(77, 138, 240, 0.1);
}
 
:deep(.p-dropdown-panel) {
  border-radius: 10px;
  border: 1px solid #e2e8f0;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
}
 
:deep(.p-dropdown-item) {
  font-size: 14px;
  padding: 10px 16px;
}
 
/* ── Mobil reszponzív: inline-create-box ── */
@media (max-width: 600px) {
  .inline-create-box {
    flex-direction: column;
    align-items: stretch;
  }
  .inline-create-box .form-input,
  .inline-create-box .form-select,
  .inline-create-box .btn {
    width: 100% !important;
    max-width: unset !important;
  }
}

.confirm-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.45);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 10000;
  padding: 16px;
}

.confirm-modal {
  background: #fff;
  border-radius: 14px;
  padding: 28px 24px 20px;
  box-shadow: 0 20px 40px rgba(0,0,0,0.2);
  width: 100%;
  max-width: 360px;
}

.confirm-message {
  font-size: 16px;
  color: #1e293b;
  margin: 0 0 24px;
  line-height: 1.5;
  text-align: center;
}

.confirm-actions {
  display: flex;
  gap: 10px;
  justify-content: flex-end;
}

.confirm-btn {
  padding: 8px 20px;
  border: none;
  border-radius: 8px;
  font-weight: 600;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.2s;
}

.confirm-btn.cancel { background: #e5e7eb; color: #374151; }
.confirm-btn.cancel:hover { background: #d1d5db; }
.confirm-btn.danger { background: #dc2626; color: white; }
.confirm-btn.danger:hover { background: #b91c1c; }
</style>