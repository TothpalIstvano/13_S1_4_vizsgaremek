<script setup>
import axios from 'axios';
import { ref, reactive, onMounted, watch, onUnmounted, nextTick } from 'vue';
import { RouterLink } from 'vue-router';
import Dropdown from 'primevue/dropdown';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import { library } from '@fortawesome/fontawesome-svg-core'
import { faHeart as fasHeart } from '@fortawesome/free-solid-svg-icons'
import { faHeart as farHeart } from '@fortawesome/free-regular-svg-icons'

library.add(fasHeart, farHeart)

const userData = ref(null);
const baseUrl = `${import.meta.env.VITE_API_URL}/storage`;
const defaultAvatar = `${baseUrl}/profilKepek/default.jpg`;

const editForm = reactive({
  vezeteknev: '',
  keresztnev: '',
  telefonszam: '',
  utca: '',
  hazszam: '',
  emeletAjto: '',
  varos: '',
});

const saving = ref(false);
const cities = ref([]);
const loadingCities = ref(false);

const showCamera = ref(false);
const videoRef = ref(null);
const canvasRef = ref(null);
const capturedBlob = ref(null);
const objectUrl = ref(null);
const cameraStream = ref(null);
const uploading = ref(false);
const likedIds = ref(new Set())

const user = reactive({
  name: '',
  username: '',
  avatar: '',
  cover: '',
  stats: { posts: 0},
  joined: ''
});

const posts = ref([]);
const showLogout = ref(false);
const showSzerkesztes = ref(false);
const showKedvencekModal = ref(false);

// Fetch user data
async function fetchUserData() {
  try {
    const response = await axios.get('/api/user');
    return response.data;
  } catch (error) {
    console.error('Error fetching user data:', error);
    return null;
  }
}

async function fetchUserBlogPosts() {
  try {
    const response = await axios.get('/api/user/posts');
    return response.data;
  } catch (error) {
    console.error('Error fetching user blog posts:', error);
    return [];
  }
}

function truncateText(text, limit) {
  if (!text) return ''
  if (text.length <= limit) return text
  return text.substring(0, limit) + '…'
}

function setAvatarDefault(event) {
  event.target.src = defaultAvatar;
}

async function fetchCities() {
  loadingCities.value = true;
  try {
    const response = await axios.get('/api/varosok');
    cities.value = response.data;
  } catch (error) {
    console.error('Failed to load cities', error);
  } finally {
    loadingCities.value = false;
  }
}

function getCityName(id) {
  const city = cities.value.find(c => c.id === id);
  return city ? city.varos_nev : '';
}
function getCityPostal(id) {
  const city = cities.value.find(c => c.id === id);
  return city ? city.iranyitoszam : '';
}

function applyAvatar(profilKep) {
  if (profilKep?.url_Link) {
    const url = profilKep.url_Link;
    user.avatar = (url.startsWith('http') ? url : `${baseUrl}/${url}`) + '?t=' + Date.now();
  } else {
    user.avatar = defaultAvatar;
  }
}

onMounted(async () => {
  userData.value = await fetchUserData();
  await fetchCities();
  if (userData.value) {
    user.name = userData.value.felhasz_nev;
    user.username = userData.value.felhasz_nev;
    posts.value = await fetchUserBlogPosts();
    const hasProfileImage = userData.value.profilKep.id;
    if (hasProfileImage) {
        if (userData.value.profilKep?.url_Link) {
            const url = userData.value.profilKep.url_Link;
            applyAvatar(userData.value.profilKep);
        } else {
            user.avatar = `${baseUrl}/profilKepek/kep_${hasProfileImage}.jpg`;
        }
    } else {
        user.avatar = defaultAvatar;
    }

    user.cover = 'https://images.unsplash.com/photo-1503264116251-35a269479413?w=1600&h=400&fit=crop';
    user.stats = {
      posts: userData.value.posts_count || 12
    };
    user.joined = userData.value.letrehozas_Datuma || '2022-09-15';

    const adat = userData.value.adatok || {};
    editForm.vezeteknev = adat.vezeteknev || '';
    editForm.keresztnev = adat.keresztnev || '';
    editForm.telefonszam = adat.telefonszam || '';
    editForm.utca = adat.utca || '';
    editForm.hazszam = adat.hazszam || '';
    editForm.emeletAjto = adat.emeletAjto || '';
    editForm.varos = adat.varos || '';
    if (videoRef.value) {
    videoRef.value.addEventListener('loadedmetadata', () => {
      videoRef.value.play()
        .then(() => console.log('Video playing'))
        .catch(err => console.error('Video play failed:', err));
    });
    };
  };
});

onUnmounted(() => {
  if (cameraStream.value) {
    cameraStream.value.getTracks().forEach(track => track.stop());
  }
  if (objectUrl.value) {
    URL.revokeObjectURL(objectUrl.value);
  }
});

// Save profile
async function saveProfile() {
  saving.value = true;
  try {
    const response = await axios.put('/api/user/profile', editForm);
    userData.value = response.data.user;
    user.name = userData.value.felhasz_nev;
    user.username = userData.value.felhasz_nev;
    showSzerkesztes.value = false;
    alert('Profil sikeresen frissítve!');
  } catch (error) {
    console.error('Error saving profile:', error);
    if (error.response && error.response.status === 422) {
      alert('Hibás adatok: ' + JSON.stringify(error.response.data.errors));
    }
  } finally {
    saving.value = false;
  }
}

// Camera functions
async function startCamera() {
  try {
    console.log('Requesting camera access...');
    const stream = await navigator.mediaDevices.getUserMedia({ video: true });
    console.log('Stream obtained:', stream);
    console.log('Stream active:', stream.active);
    stream.getTracks().forEach(track => {
      console.log('Track kind:', track.kind, 'readyState:', track.readyState);
    });

    cameraStream.value = stream;
    showCamera.value = true;

    await nextTick();
    console.log('After nextTick, videoRef.value:', videoRef.value);

    if (videoRef.value) {
      videoRef.value.srcObject = stream;
      console.log('srcObject assigned to video element');

      await new Promise((resolve) => {
        videoRef.value.onloadedmetadata = () => {
          console.log('loadedmetadata fired');
          console.log('Video dimensions:', videoRef.value.videoWidth, 'x', videoRef.value.videoHeight);
          videoRef.value.play()
            .then(() => {
              console.log('Video play succeeded');
              resolve();
            })
            .catch(err => {
              console.error('Play failed:', err);
              resolve();
            });
        };
      });

      console.log('Camera started successfully');
    } else {
      console.error('videoRef is still null after nextTick');
    }
  } catch (err) {
    console.error('Camera access denied', err);
    alert('Nem sikerült elérni a kamerát.');
  }
}

function stopCamera() {
  if (cameraStream.value) {
    cameraStream.value.getTracks().forEach(track => track.stop());
    cameraStream.value = null;
  }
  showCamera.value = false;
  capturedBlob.value = null;
}

function capturePhoto() {
  const video = videoRef.value;
  const canvas = canvasRef.value;
  if (!video || !canvas) {
    console.warn('Video or canvas not ready');
    return;
  }
  if (video.readyState < 2) {
    console.warn('Video not ready yet');
    return;
  }
  const context = canvas.getContext('2d');
  canvas.width = video.videoWidth;
  canvas.height = video.videoHeight;
  context.drawImage(video, 0, 0, canvas.width, canvas.height);
  console.log('Captured dimensions:', canvas.width, canvas.height);

  canvas.toBlob((blob) => {
    if (blob) {
      capturedBlob.value = blob;
      console.log('Blob created, size:', blob.size);
    } else {
      console.error('Failed to create blob');
    }
  }, 'image/jpeg', 0.9);
}

watch(capturedBlob, (newBlob) => {
  if (objectUrl.value) {
    URL.revokeObjectURL(objectUrl.value);
  }
  objectUrl.value = newBlob ? URL.createObjectURL(newBlob) : null;
}, { immediate: true });

async function uploadProfilePhoto() {
  if (!capturedBlob.value) return;

  uploading.value = true;
  const file = new File([capturedBlob.value], 'profile-photo.jpg', { type: 'image/jpeg' });
  const formData = new FormData();
  formData.append('image', file);

  try {
    const uploadRes = await axios.post('/api/upload-profile-picture', formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    });
    const imageId = uploadRes.data.image.id;

    await axios.put('/api/user/profile-picture', { profilKep_id: imageId });

    userData.value = await fetchUserData();
    applyAvatar(userData.value.profilKep);
    stopCamera();
  } catch (error) {
    console.error('Upload failed', error);
    alert('Kép feltöltés sikertelen.');
  } finally {
    uploading.value = false;
  }
}

const handleFileUpload = async (event) => {
  const file = event.target.files[0];
  if (!file) return;
  console.log('File selected:', file.name, file.size);
  capturedBlob.value = file;
  console.log('capturedBlob set, now uploading...');
  await uploadProfilePhoto();
  event.target.value = ''; 
};

const showKedvencek = ref(false)
const kedvencTermekek = ref([])

async function loadKedvencek() {
  showKedvencekModal.value = true;
  showKedvencek.value = true;

  try {
    const res = await axios.get('/api/user/kedvencek/termekek');
    kedvencTermekek.value = res.data;
    likedIds.value = new Set(kedvencTermekek.value.map(p => p.id));
  } catch (error) {
    console.error('Hiba a kedvencek betöltésekor:', error);
  }
}

async function toggleLike(item, event) {
  event.stopPropagation();
  try {
    const res = await axios.post(`/api/termekek/${item.id}/kedvenc`);
    if (res.data.liked) {
      likedIds.value.add(item.id);
    } else {
      likedIds.value.delete(item.id);
      kedvencTermekek.value = kedvencTermekek.value.filter(p => p.id !== item.id);
    }
  } catch (error) {
    console.error('Toggle like failed', error);
  }
}

function cancelKedvencek() {
  showKedvencekModal.value = false;
  showKedvencek.value = false;
}

function kijelentkezes() { showLogout.value = true; }
function szerkesztes() { showSzerkesztes.value = true; }
function cancelSzerkesztes() { showSzerkesztes.value = false; }
async function confirmLogout() {
  showLogout.value = false;
  try {
    await axios.post('/logout', { withCredentials: true });
  } catch (e) {
    console.error('Error during logout:', e);
  } finally {
    showLogout.value = false;
    setTimeout(() => window.location.href = '/belepes', 10); // or router.push('/belepes')
  }
}

function cancelLogout() { showLogout.value = false; }
function formatDate(d) { return new Date(d).toLocaleDateString(); }
</script>

<template>
  <main class="profile-page">
    <section class="cover" :style="{ backgroundImage: 'url(' + user.cover + ')' }">
      <div class="cover-overlay"></div>
      <div class="cover-inner">
        <div class="profile-card">
          <img class="avatar" :src="user.avatar" @error="setAvatarDefault" alt="avatar" />
          <div class="profile-info">
            <h2 class="name">{{ user.name }}</h2>
            <p class="username">@{{ user.username }}</p>
            <p class="bio">Kreatív hobbi rajongó</p> <!--{{ user.bio }}-->
            <div class="meta">
              <span>{{ user.stats.posts }} bejegyzés</span>
            </div>
          </div>
          <div class="profile-actions">
            <button class="btn edit" @click="szerkesztes">Szerkesztés</button>
            <button type="button" class="btn logout" @click="kijelentkezes">Kijelentkezés</button>
          </div>
        </div>
      </div>
    </section>
    <div class="profile-actions">
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
      <div v-else-if="showSzerkesztes" class="szerk-modal-backdrop" @click.self="cancelSzerkesztes">
        <div class="szerk-modal">
          <div class="szerk-modal-header">
            <h3>Profil szerkesztése</h3>
            <button class="close-btn" @click="cancelSzerkesztes">✕</button>
          </div>
          <form @submit.prevent="saveProfile">
            <!-- Személyes adatok -->
            <div class="form-section">
              <h4>Személyes adatok</h4>
              <div class="form-row">
                <div class="form-group">
                  <label for="vezeteknev">Vezetéknév</label>
                  <input type="text" id="vezeteknev" v-model="editForm.vezeteknev" placeholder="Pl. Nagy" />
                </div>
                <div class="form-group">
                  <label for="keresztnev">Keresztnév</label>
                  <input type="text" id="keresztnev" v-model="editForm.keresztnev" placeholder="Pl. Anna" />
                </div>
              </div>
              <div class="form-group">
                <label for="telefon">Telefonszám</label>
                <input type="tel" pattern="(06|+36)\d{9}" id="telefon" v-model="editForm.telefonszam" placeholder="+36 20 123 4567" />
              </div>
            </div>

            <!-- Cím adatok -->
            <div class="form-section">
              <h4>Lakcím</h4>
              <div class="form-group">
                <label for="utca">Utca</label>
                <input type="text" id="utca" v-model="editForm.utca" placeholder="Kossuth Lajos utca" />
              </div>
              <div class="form-row">
                <div class="form-group">
                  <label for="hazszam">Házszám</label>
                  <input type="number" id="hazszam" v-model="editForm.hazszam" placeholder="12" />
                </div>
                <div class="form-group">
                  <label for="emeletAjto">Emelet/Ajtó</label>
                  <input type="text" id="emeletAjto" v-model="editForm.emeletAjto" placeholder="2/5" />
                </div>
              </div>
              <div class="form-group">
                <label for="varos">Város</label>
                <Dropdown
                  id="varos"
                  v-model="editForm.varos"
                  :options="cities"
                  optionLabel="varos_nev"
                  optionValue="id"
                  placeholder="Válassz vagy írj be egy várost"
                  :filter="true"
                  filterBy="varos_nev,iranyitoszam"
                  :showClear="true"
                  :loading="loadingCities"
                  class="w-full"
                >
                  <template #value="slotProps">
                    <div v-if="slotProps.value">
                      {{ getCityName(slotProps.value) }} ({{ getCityPostal(slotProps.value) }})
                    </div>
                    <span v-else>{{ slotProps.placeholder }}</span>
                  </template>
                  <template #option="slotProps">
                    <div>{{ slotProps.option.varos_nev }} ({{ slotProps.option.iranyitoszam }})</div>
                  </template>
                </Dropdown>
              </div>
            </div>

            <!-- Profilkép -->
            <div class="form-section">
              <h4>Profilkép</h4>
              <div class="form-group">
                <label for="avatar">Feltöltés számítógépről</label>
                <input type="file" id="avatar" accept="image/*" @change="handleFileUpload" />
              </div>
              <div v-if="!showCamera" class="camera-toggle">
                <button type="button" class="btn camera-btn" @click="startCamera">📷 Kamera használata</button>
              </div>
              <div v-if="showCamera" class="camera-preview">
                <video ref="videoRef" autoplay playsinline></video>
                <canvas ref="canvasRef" style="display: none;"></canvas>
                <div class="camera-controls">
                  <button type="button" class="btn capture" @click="capturePhoto">Fotózás</button>
                  <button type="button" class="btn cancel" @click="stopCamera">Mégse</button>
                </div>
                <div v-if="capturedBlob" class="captured-preview">
                  <p>Előkép:</p>
                  <img :src="objectUrl" alt="preview" />
                  <button type="button" class="btn upload" @click="uploadProfilePhoto" :disabled="uploading">
                    {{ uploading ? 'Feltöltés...' : 'Profilkép beállítása' }}
                  </button>
                </div>
              </div>
            </div>

            <!-- Mentés/Mégse gombok -->
            <div class="form-actions">
              <button type="button" class="btn cancel" @click="cancelSzerkesztes">Mégse</button>
              <button type="submit" class="btn save" :disabled="saving">
                {{ saving ? 'Mentés...' : 'Mentés' }}
              </button>
            </div>
          </form>
        </div>
      </div>
      <div v-else-if="showKedvencekModal" class="kedvencek-modal-backdrop" @click.self="cancelKedvencek">
        <div class="kedvencek-modal">
          <div class="kedvencek-modal-header">
            <h3>Kedvenc termékek</h3>
            <button class="close-btn" @click="cancelKedvencek">✕</button>
          </div>
          <div v-if="showKedvencek" class="kedvenc-lista">
            <div v-if="kedvencTermekek.length === 0" class="kedvenc-ures">
              Még nincs kedvenc termék.
            </div>
            <div
              v-for="t in kedvencTermekek"
              :key="t.id"
              class="kedvenc-card"
              @click="$router.push(`/aruhaz/${t.id}`)"
            >
              <div class="heart-wrapper">
                <button class="heart-btn" @click="toggleLike(t, $event)" :class="{ liked: likedIds.has(t.id) }">
                  <FontAwesomeIcon :icon="likedIds.has(t.id) ? ['fas', 'heart'] : ['far', 'heart']" />
                </button>
              </div>
              <img :src="t.termek_fo_kep.url_Link" :alt="t.termek_fo_kep.alt_szoveg" class="kedvenc-img" />
              <div class="kedvenc-body">
                <h3 class="kedvenc-title">{{ t.nev }}</h3>
                <p class="kedvenc-price">{{ t.ar }} Ft</p>
                <p class="kedvenc-desc">{{ t.leiras }}</p>
                <div class="kedvenc-tags">
                  <span
                    v-for="kat in t.termek_kategoriak"
                    :key="kat.id"
                    class="kedvenc-tag"
                    :class="{ 'main-category': kat.fo_kategoria_id === null }"
                  >{{ kat.nev }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    <section class="content">
      <div class="content-grid">
        <aside class="left-col">
          <div class="about-card">
            <h3>Rólam</h3>
            <p><strong>Csatlakozott:</strong> {{ formatDate(user.joined) }}</p>
            <p><strong>Hobbi:</strong> Kötés, horgolás, hímzés, mintatervezés</p>
            <hr />
            <h4>Információk</h4>
            <ul>
              <li><strong>{{ user.stats.posts }}</strong> bejegyzés</li>
            </ul>
          </div>
          <button class="btn kedvencek" style="margin-top:12px; width:100%" @click="loadKedvencek">
            <font-awesome-icon icon="fa-solid fa-heart" style="color: red;"/> Kedvenc termékek
          </button>
        </aside>

        <section class="main-col">
          <header class="section-header">
            <h2>A profilhoz tartozó cikkek</h2>

            <RouterLink to="/newpost" class="btn create-post">
              + Új bejegyzés
            </RouterLink>
          </header>

          <div v-if="posts.length === 0" class="empty-posts">
            <h3>Még nincs egyetlen bejegyzésed sem</h3>
            <p>
              Itt fognak megjelenni a saját cikkeid.  
              Kezdd el az első bejegyzésed létrehozásával.
            </p>

            <RouterLink to="/newpost" class="btn create-post">
              + Új bejegyzés létrehozása
            </RouterLink>
          </div>


          <div class="posts">
            <article v-for="p in posts" :key="p.id" class="post-card">
              <div class="post-cover">
                <img :src="p.fo_kep.url_Link" :alt="p.fo_kep.alt_szoveg" />
              </div>
              <div class="post-body">
                <div class="post-meta">
                  <span>{{ formatDate(p.letrehozas_datuma) }}</span>
                  <span class="tags">
                    <small v-for="cimke in p.cimkek" :key="cimke.id" class="tag">#{{ cimke.nev }}</small>
                  </span>
                  <span v-if="p.statusz === 'piszkozat'" class="draft-badge">Piszkozat</span>
                </div>
                <h3 class="post-title">{{ p.cim }}</h3>
                <p class="post-excerpt">{{ truncateText(p.kivonat || 'Nincs leírás...', 60) }}</p>
                <div class="post-actions">
                  <RouterLink :to="`/blog/${p.id}`" class="read">Olvasás</RouterLink>
                  <RouterLink v-if="p.sajat" :to="`/editpost/${p.id}`" class="modify">Szerkesztés</RouterLink>
                  <RouterLink v-else :to="`/editpost/${p.id}`" class="modify">Szerkesztés</RouterLink>
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
.draft-badge {
  background: #fbbf24;
  color: #000;
  font-size: 14px;
  padding: 2px 8px;
  border-radius: 999px;
  margin-left: 8px;
}
.edit {
  background: #ffece3;
  color: #380c02;
  padding: 8px 12px;
  border-radius: 10px;
  text-decoration: none;
  font-weight: 600;
}

/*#region Szerkesztés Modal */
.szerk-modal-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 100;
}

.szerk-modal {
  background: #fff;
  border-radius: 20px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.2);
  width: 100%;
  max-width: 600px;
  max-height: 90vh;
  overflow-y: auto;
  animation: modalFadeIn 0.2s ease;
}

@keyframes modalFadeIn {
  from { opacity: 0; transform: scale(0.95); }
  to { opacity: 1; transform: scale(1); }
}

.szerk-modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 25px;
  border-bottom: 1px solid #e9ecef;
  background: #fafbfc;
  border-radius: 20px 20px 0 0;
}

.szerk-modal-header h3 {
  margin: 0;
  font-size: 24px;
  font-weight: 600;
  color: #1a1e24;
}

.close-btn {
  background: none;
  border: none;
  font-size: 24px;
  cursor: pointer;
  color: #6c757d;
  padding: 4px 8px;
  border-radius: 8px;
  transition: all 0.2s;
}

.close-btn:hover {
  background: #e9ecef;
  color: #212529;
}

/* Form szekciók */
.form-section {
  padding: 10px 20px;
  border-bottom: 1px solid #e9ecef;
}

.form-section h4 {
  margin: 0 0 20px 0;
  font-size: 16px;
  font-weight: 600;
  color: #2c3e50;
  letter-spacing: 0.3px;
}

.form-row {
  display: flex;
  gap: 10px;
  margin-bottom: 8px;
  flex-wrap: wrap;
}

.form-row .form-group {
  flex: 1 1 200px;
}

.form-group {
  margin-bottom: 8px;
}

.form-group label {
  display: block;
  margin-bottom: 8px;
  font-weight: 500;
  font-size: 15px;
  color: #4a5568;
}

.form-group input[type="text"],
.form-group input[type="tel"],
.form-group input[type="number"],
.form-group input[type="file"] {
  width: 100%;
  padding: 8px 10px;
  border: 1.5px solid #e2e8f0;
  border-radius: 12px;
  font-size: 15px;
  transition: border-color 0.15s, box-shadow 0.15s;
  background: #fff;
}

.form-group input:focus {
  outline: none;
  border-color: #ad6801;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

/* Kamera rész */
.camera-toggle {
  margin-top: 8px;
}

.camera-btn {
  background: #f1f5f9;
  color: #1e293b;
  border: 1.5px dashed #94a3b8;
  width: 100%;
  padding: 12px;
  border-radius: 12px;
  font-weight: 600;
  transition: all 0.2s;
}

.camera-btn:hover {
  background: #e2e8f0;
  border-color: #64748b;
}

.camera-preview {
  margin-top: 16px;
  background: #f8fafc;
  border-radius: 16px;
  padding: 16px;
  border: 1.5px solid #e2e8f0;
}

.camera-preview video {
  width: 100%;
  max-width: 100%;
  border-radius: 12px;
  background: #0f172a;
  min-height: 240px;
  object-fit: cover;
}

.camera-controls {
  display: flex;
  gap: 12px;
  margin: 16px 0;
  justify-content: center;
}

.camera-controls .btn {
  flex: 1;
  padding: 10px;
  border-radius: 40px;
  font-weight: 600;
}

.btn.capture {
  background: #926129;
  color: white;
  border: none;
}

.btn.cancel {
  background: #e2e8f0;
  color: #334155;
  border: none;
}

.captured-preview {
  text-align: center;
  margin-top: 16px;
}

.captured-preview p {
  margin: 0 0 8px;
  font-weight: 500;
  color: #334155;
}

.captured-preview img {
  max-width: 200px;
  border-radius: 12px;
  border: 3px solid white;
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
  margin-bottom: 16px;
}

.btn.upload {
  background: #059669;
  color: white;
  border: none;
  padding: 10px 24px;
  border-radius: 40px;
  font-weight: 600;
}

.btn.upload:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}
/*#endregion */

/*#region Űrlap akciógombok */
.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 16px;
  padding: 15px 25px;
  background: #f8fafc;
  border-radius: 0 0 20px 20px;
}

.form-actions .btn {
  padding: 12px 24px;
  border-radius: 40px;
  font-weight: 600;
  font-size: 16px;
  transition: all 0.2s;
  border: none;
  cursor: pointer;
}

.form-actions .btn.save {
  background: #017e07;
  color: white;
}

.form-actions .btn.save:hover:not(:disabled) {
  background: #1e293b;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0,0,0,0.15);
}

.form-actions .btn.cancel {
  background: #e2e8f0;
  color: #101722;
}

.form-actions .btn.cancel:hover {
  background: #cbd5e1;
}

/* PrimeVue dropdown finomhangolás */
:deep(.p-dropdown) {
  width: 100%;
  border-radius: 12px;
  border: 1.5px solid #e2e8f0;
}

:deep(.p-dropdown:not(.p-disabled):hover) {
  border-color: #ad6801;
}

:deep(.p-dropdown-panel) {
  border-radius: 12px;
  margin-top: 4px;
  box-shadow: 0 10px 25px -5px rgba(0,0,0,0.1);
}

/*#endregion*/

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
  font-size: 20px;
  font-weight: 700;
}
.username {
  margin: 4px 0;
  color: #666;
  font-size: 15px;
}
.bio {
  margin: 8px 0;
  color: #444;
}
.meta {
  display: flex;
  gap: 12px;
  color: #71717a;
  font-size: 15px;
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
  text-decoration: none;
}

.btn.logout { 
  background: #fee2e2; 
  color: #991b1b; 
}

.btn.follow { 
  background: #111827; 
  color: #fff; 
}

.btn.create-post {
  display: inline-block;
  background: #111827;
  color: #ffffff;
  padding: 10px 16px;
  border-radius: 12px;
  font-weight: 700;
  text-decoration: none;
}

.modal-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.4);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 10;
}
.modal {
  background: #fff;
  padding: 24px;
  border-radius: 12px;
  box-shadow: 0 8px 28px rgba(12,12,12,0.15);
  max-width: 400px;
  width: 100%;
}
.modal h3 { margin-top: 0; }

.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  margin-top: 18px;
}
.btn.confirm { 
  background: #dc2626; 
  color: #fff; 
}

.btn.cancel { 
  background: #e5e7eb; 
  color: #374151; 
}

/*#region Kedvencek modal*/
.kedvencek {
  padding: 18px 25px;
  background-color: #ffffff;
  border: 2px dashed rgb(110, 58, 13);
  box-shadow: 0 0 0 4px #dbdbdb26, 2px 2px 4px 2px rgba(167, 157, 157, 0.5);
  transition: .1s ease-in-out, .4s color;
}

.kedvencek:hover {
  background-color: #f9f9f9;
  transform: scale(1.05);
}

.kedvencek-modal-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 100;
}

.kedvencek-modal {
  background: #fff;
  border-radius: 20px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.2);
  width: 100%;
  max-width: 600px;
  max-height: 90vh;
  overflow-y: auto;
  animation: modalFadeIn 0.2s ease;
}

@keyframes modalFadeIn {
  from { opacity: 0; transform: scale(0.95); }
  to { opacity: 1; transform: scale(1); }
}

.kedvencek-modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 25px;
  border-bottom: 1px solid #e9ecef;
  background: #fafbfc;
  border-radius: 20px 20px 0 0;
}

.kedvencek-modal-header h3 {
  margin: 0;
  font-size: 24px;
  font-weight: 600;
  color: #1a1e24;
}

.kedvencek-modal {
  max-width: 650px;
}

.kedvencek-modal {
  max-width: 800px;
}

.kedvenc-lista {
  padding: 1.5rem;
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1.25rem;
}

.kedvenc-ures {
  grid-column: 1 / -1;
  color: #94a3b8;
  font-size: 1rem;
  text-align: center;
  padding: 2rem 0;
}

.kedvenc-card {
  background: white;
  border-radius: 18px;
  overflow: hidden;
  box-shadow: 0 6px 18px rgba(0,0,0,0.06);
  display: flex;
  flex-direction: column;
  cursor: pointer;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
  border: 1px solid rgba(0,0,0,0.04);
  height: 100%;
}

.kedvenc-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 28px rgba(0,0,0,0.12);
}

.kedvenc-img {
  width: 100%;
  height: 160px;
  object-fit: cover;
}

.kedvenc-body {
  padding: 1rem 1rem 1.25rem;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  flex: 1;
}

.kedvenc-title {
  font-size: 1rem;
  font-weight: 700;
  margin: 0;
  color: #1e293b;
  line-height: 1.4;
}

.kedvenc-price {
  font-weight: 700;
  color: #2e7d32;
  margin: 0;
  font-size: 1.1rem;
}

.kedvenc-desc {
  font-size: 0.8rem;
  color: #475569;
  line-height: 1.4;
  max-height: 2.8em;
  overflow: hidden;
  margin: 0.25rem 0 0;
}

.kedvenc-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 0.35rem;
  margin-top: 0.25rem;
}

.kedvenc-tag {
  background: #ffedd5;
  color: #9a3412;
  font-size: 0.7rem;
  padding: 0.2rem 0.6rem;
  border-radius: 9999px;
  font-weight: 500;
}

.kedvenc-tag.main-category {
  background: #f97316;
  color: white;
}

.heart-wrapper {
  position: relative;
}

.heart-btn {
  position: absolute;
  top: 8px;
  right: 8px;
  background: rgba(255, 255, 255, 0.85);
  border: none;
  border-radius: 50%;
  width: 34px;
  height: 34px;
  font-size: 18px;
  cursor: pointer;
  color: #ccc;
  transition: color 0.2s, transform 0.15s;
  z-index: 1;
  display: flex;
  align-items: center;
  justify-content: center;
}

.heart-btn.liked {
  color: #e03e3e;
}

.heart-btn:hover {
  transform: scale(1.15);
}

/*#endregion*/

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
.about-card h3 { 
margin: 0 0 8px 0; 
}

.about-card hr { 
border: none; 
border-top: 1px solid #efefef; 
margin: 12px 0; 
}

.about-card ul { 
list-style: none; 
padding: 0; 
margin: 0; 
color: #444; 
}

/* main column */
.section-header h2 { 
margin: 0; 
font-size: 20px; 
}

.section-header .sub { 
margin: 6px 0 18px; 
color: #6b7280; 
}

.posts {
  display: grid;
  grid-template-columns: 1fr;
  gap: 18px;
}

.post-card {
  display: flex;
  gap: 10px;
  background: #fff;
  border-radius: 12px;
  overflow: hidden;
  border: 1px solid rgba(0,0,0,0.04);
  box-shadow: 0 6px 20px rgba(12,12,12,0.05);
}

.post-cover {
  width: 240px;
  min-width: 240px;
}

.post-cover img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  /*max-height: 160px;*/
}

.post-body {
  padding: 14px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.post-title {
  margin: 6px 0;
  padding-top: 10px; 
}

.post-meta { 
  color: #6b7280; 
  font-size: 12px; 
  display: flex; 
  gap: 10px; 
  align-items: center; 
}

.tag { 
  margin-left: 6px; 
  background: #f9f4f1; 
  padding: 4px 8px; 
  border-radius: 50px; 
  font-size: 12px; 
  color: #412d25; 
}

.post-excerpt {
  margin-top: 0px;
}

.post-actions {
  display: flex;
  gap: 8px;
}

.post-actions .read,
.post-actions .modify {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 5px 12px;
  border-radius: 20px;
  font-weight: 600;
  font-size: 0.8rem;
  text-decoration: none;
  transition: all 0.2s ease;
  box-shadow: 0 1px 3px rgba(0,0,0,0.06);
}

.post-actions .read {
  background: #ffece4;
  color: #422207;
}

.post-actions .read:hover {
  background: #ffddce;
  box-shadow: 0 3px 6px rgba(0,0,0,0.1);
  transform: translateY(-1px);
}

.post-actions .modify {
  background: #e2c1b3;
  color: #331903;
}

.post-actions .modify:hover {
  background: #cfa999;
  box-shadow: 0 3px 6px rgba(0,0,0,0.1);
  transform: translateY(-1px);
}

.post-actions .read::before {
  content: "←";
}

.post-actions .modify::before {
  content: "✎";
}

/* responsive */
@media (max-width: 900px) {
  .content-grid { 
    grid-template-columns: 1fr; 
  }

  .post-cover { 
    display: none; 
  }

  .profile-card { 
    flex-direction: column; 
    align-items: flex-start; 
    transform: translateY(40px); 
  }

  .profile-actions { 
    flex-direction: row; 
    width: 100%; 
    justify-content: space-between; 
  }
}

@media (max-width: 640px) {
  .kedvenc-lista {
    grid-template-columns: 1fr;
  }
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 14px;
}

.empty-posts {
  background: #ffffff;
  border: 2px dashed #c7d2fe;
  border-radius: 14px;
  padding: 40px 20px;
  text-align: center;
  margin-top: 20px;
  box-shadow: 0 6px 20px rgba(12,12,12,0.05);
}

.empty-posts h3 {
  margin: 0 0 8px 0;
  font-size: 1.15rem;
  font-weight: 700;
}

.empty-posts p {
  margin: 0 0 18px 0;
  color: #4b5563;
  max-width: 420px;
  margin-left: auto;
  margin-right: auto;
}

</style>