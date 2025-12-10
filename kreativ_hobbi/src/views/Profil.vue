<script setup>
import axios from 'axios';
import { ref, reactive} from 'vue';
import { RouterLink } from 'vue-router';


const user = reactive({
  name: 'Eszter Tóth',
  username: 'eszter.t',
  bio: 'Kézműves, mintatervező és hobbikészítő. Szeretem a kötést, horgolást és a semmittevést közben.',
  avatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&h=400&fit=crop',
  cover: 'https://images.unsplash.com/photo-1503264116251-35a269479413?w=1600&h=400&fit=crop',
  stats: {
    posts: 12,
    followers: 842,
    following: 134
  },
  joined: '2022-09-15'
});

const posts = ref([
  {
    id: 1,
    title: 'Személyre szabott minta ötletek',
    date: '2025-08-04',
    excerpt: 'Tippek és trükkök hogyan készíts egyedi mintákat fotóid alapján.',
    cover: 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=1200&h=700&fit=crop',
    tags: ['mintakészítés', 'kötés']
  },
  {
    id: 2,
    title: 'Kötés kezdőknek — az első pulóver',
    date: '2024-11-12',
    excerpt: 'Egyszerű lépések, amikkel az első pulóvered elkészülhet.',
    cover: 'https://images.unsplash.com/photo-1520975681918-6c94d0b7b5f2?w=1200&h=700&fit=crop',
    tags: ['kötés', 'oktató']
  },
  {
    id: 3,
    title: 'Horgolt táskák szezonja',
    date: '2025-03-20',
    excerpt: 'Formák, fonalak és praktikus zsebek — a legjobb táskaötletek.',
    cover: 'https://images.unsplash.com/photo-1496307042754-b4aa456c4a2d?w=1200&h=700&fit=crop',
    tags: ['horgolás', 'inspiráció']
  }
]);

const showLogout = ref(false);


function formatDate(d) {
  return new Date(d).toLocaleDateString();
}
function kijelentkezes() {
  showLogout.value = ref(true);
}
function confirmLogout() {
  showLogout.value = false;
  try {
    // if you have a backend logout route, call it (uncomment)
    // await axios.post('/logout');
  } catch (e) {
    // ignore API errors for now
  } finally {
    axios.post('/logout', {}, { withCredentials: true });
    localStorage.removeItem('user');
    showLogout.value = false;
    window.location.href = '/belepes'; // or router.push('/belepes')
  }
}
function cancelLogout() {
  showLogout.value = ref(false);
}
</script>

<template>
  <main class="profile-page">
    <section class="cover" :style="{ backgroundImage: 'url(' + user.cover + ')' }">
      <div class="cover-overlay"></div>
      <div class="cover-inner">
        <div class="profile-card">
          <img class="avatar" :src="user.avatar" alt="avatar" />
          <div class="profile-info">
            <h2 class="name">{{ user.name }}</h2>
            <p class="username">@{{ user.username }}</p>
            <p class="bio">{{ user.bio }}</p>
            <div class="meta">
              <span>{{ user.stats.posts }} bejegyzés</span>
              <span>{{ user.stats.followers }} követő</span>
              <span>{{ user.stats.following }} követés</span>
            </div>
          </div>
          <div class="profile-actions">
            <button class="btn edit"><RouterLink to="/profil/szerkesztes">Szerkesztés</RouterLink></button>
            <button type="button" class="btn logout" @click="kijelentkezes">Kijelentkezés</button>
            <div v-if="showLogout" class="modal-backdrop" @click.self="cancelLogout">
              <div class="modal">
                <h3>Kijelentkezés</h3>
                <p>Biztos ki szeretnél jelentkezni?</p>
                <div class="modal-actions">
                  <button class="btn confirm" @click="confirmLogout">Igen, kijelentkezés</button>
                  <button class="btn cancel" @click="cancelLogout">Mégse</button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <section class="content">
      <div class="content-grid">
        <aside class="left-col">
          <div class="about-card">
            <h3>Rólam</h3>
            <p><strong>Csatlakozott:</strong> {{ formatDate(user.joined) }}</p>
            <p><strong>Hobbi:</strong> Kötés, horgolás, hímzés, mintatervezés</p>
            <hr />
            <h4>Gyors stat</h4>
            <ul>
              <li><strong>{{ user.stats.posts }}</strong> bejegyzés</li>
              <li><strong>{{ user.stats.followers }}</strong> követő</li>
              <li><strong>{{ user.stats.following }}</strong> követés</li>
            </ul>
          </div>
        </aside>

        <section class="main-col">
          <header class="section-header">
            <h2>Legújabb cikkek</h2>
            <p class="sub">A profilhoz tartozó blogbejegyzések és minták</p>
          </header>

          <div class="posts">
            <article v-for="p in posts" :key="p.id" class="post-card">
              <div class="post-cover" :style="{ backgroundImage: 'url(' + p.cover + ')' }"></div>
              <div class="post-body">
                <h3 class="post-title">{{ p.title }}</h3>
                <div class="post-meta">
                  <span>{{ formatDate(p.date) }}</span>
                  <span class="tags">
                    <small v-for="t in p.tags" :key="t" class="tag">#{{ t }}</small>
                  </span>
                </div>
                <p class="post-excerpt">{{ p.excerpt }}</p>
                <div class="post-actions">
                  <RouterLink :to="`/blog/${p.id}`" class="read">Olvasás</RouterLink>
                </div>
              </div>
            </article>
          </div>
        </section>
      </div>
    </section>
  </main>
</template>

<style scoped> 

.profile-page {
  font-family: system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial;
  color: #222;
  min-height: 100vh;
}

/* cover */
.cover {
  height: 280px;
  background-size: cover;
  background-position: center;
  position: relative;
  display: flex;
  align-items: flex-end;
}
.cover-overlay {
  position: absolute;
  inset: 0;
  background: linear-gradient(180deg, rgba(0,0,0,0.15), rgba(0,0,0,0.35));
  pointer-events: none;
}
.cover-inner {
  width: 100%;
  max-width: 1100px;
  margin: 0 auto  -60px;
  padding: 0 20px;
  box-sizing: border-box;
}

/* profile card overlapping cover */
.profile-card {
  display: flex;
  gap: 18px;
  align-items: center;
  background: #fff;
  padding: 16px;
  border-radius: 14px;
  box-shadow: 0 8px 28px rgba(12,12,12,0.12);
  border: 1px solid rgba(0,0,0,0.06);
  transform: translateY(60px);
  overflow: hidden;
}
.avatar {
  width: 96px;
  height: 96px;
  border-radius: 14px;
  object-fit: cover;
  flex-shrink: 0;
  border: 3px solid #fff;
}
.profile-info {
  flex: 1;
}
.name {
  margin: 0;
  font-size: 1.25rem;
  font-weight: 700;
}
.username {
  margin: 4px 0;
  color: #666;
  font-size: 0.95rem;
}
.bio {
  margin: 8px 0;
  color: #444;
}
.meta {
  display: flex;
  gap: 12px;
  color: #71717a;
  font-size: 0.9rem;
}

/* actions */
.profile-actions {
  display: flex;
  flex-direction: column;
  gap: 8px;
}
.btn {
  border: none;
  padding: 8px 12px;
  border-radius: 10px;
  cursor: pointer;
  font-weight: 600;
  background: #edf2ff;
  color: #1e293b;
  text-decoration: none;
}
.btn.edit { background: #eef2ff; }
.btn.logout { background: #fee2e2; color: #991b1b; }
.btn.follow { background: #111827; color: #fff; }

/* content layout */
.content {
  max-width: 1100px;
  margin: 150px auto;
  padding: 0 20px;
  box-sizing: border-box;
}
.content-grid {
  display: grid;
  grid-template-columns: 280px 1fr;
  gap: 24px;
}

/* left column */
.about-card {
  background: #fff;
  padding: 18px;
  border-radius: 12px;
  box-shadow: 0 6px 20px rgba(12,12,12,0.06);
  border: 1px solid rgba(0,0,0,0.04);
}
.about-card h3 { margin: 0 0 8px 0; }
.about-card hr { border: none; border-top: 1px solid #efefef; margin: 12px 0; }
.about-card ul { list-style: none; padding: 0; margin: 0; color: #444; }

/* main column */
.section-header h2 { margin: 0; font-size: 1.25rem; }
.section-header .sub { margin: 6px 0 18px; color: #6b7280; }

.posts {
  display: grid;
  grid-template-columns: 1fr;
  gap: 18px;
}
.post-card {
  display: flex;
  gap: 16px;
  background: #fff;
  border-radius: 12px;
  overflow: hidden;
  border: 1px solid rgba(0,0,0,0.04);
  box-shadow: 0 6px 20px rgba(12,12,12,0.05);
}
.post-cover {
  width: 240px;
  min-width: 240px;
  height: 140px;
  background-size: cover;
  background-position: center;
  flex-shrink: 0;
}
.post-body {
  padding: 14px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}
.post-title { margin: 0 0 6px 0; font-size: 1.05rem; }
.post-meta { color: #6b7280; font-size: 0.85rem; display: flex; gap: 10px; align-items: center; }
.tag { margin-left: 6px; background: #f1f5f9; padding: 4px 8px; border-radius: 999px; font-size: 0.75rem; color: #374151; }
.post-excerpt { margin: 10px 0; color: #374151; }
.post-actions .read {
  background: #111827;
  color: #fff;
  padding: 8px 12px;
  border-radius: 10px;
  text-decoration: none;
  font-weight: 600;
}

/* responsive */
@media (max-width: 900px) {
  .content-grid { grid-template-columns: 1fr; }
  .post-cover { display: none; }
  .profile-card { flex-direction: column; align-items: flex-start; transform: translateY(40px); }
  .profile-actions { flex-direction: row; width: 100%; justify-content: space-between; }
}
</style>
