<script setup>
import axios from 'axios';
import { ref, reactive, onMounted, watch, onUnmounted, nextTick } from 'vue';
import { RouterLink } from 'vue-router';
import Dropdown from 'primevue/dropdown';

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

function setAvatarDefault(event) {
  event.target.src = defaultAvatar;
}

async function fetchCities() {
  loadingCities.value = true;
  try {
    const response = await axios.get('/api/cities');
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

    const hasProfileImage = userData.value.profilKep_id;
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
      console.log('Video metadata loaded, ready to play');
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

watch(capturedBlob, (newBlob, oldBlob) => {
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
            <div class="szerk-modal-actions">
              <div class="szerkesztes">
                <h3>Profil szerkesztése</h3>
                <form @submit.prevent="saveProfile">
                  <label for="vezeteknev">Vezetéknév</label>
                  <input type="text" id="vezeteknev" v-model="editForm.vezeteknev">
                  <label for="keresztnev">Keresztnév</label>
                  <input type="text" id="keresztnev" v-model="editForm.keresztnev">
                  <label for="telefon">Telefonszám</label>
                  <input input type="text" pattern="/(06|+36)\d{9}/" id="telefon" v-model="editForm.telefonszam"> <!--nem működik a regex-->
                  <!--<label for="bio">Bio</label>
                  <textarea id="bio" v-model="editForm.bio"></textarea>-->
                  <label for="utca">Utca</label>
                  <input type="text" id="utca" v-model="editForm.utca">
                  <label for="hazszam">Házszám</label>
                  <input type="number" id="hazszam" v-model="editForm.hazszam">
                  <label for="emeletAjto">Emelet/Ajtó</label>
                  <input type="text" id="emeletAjto" v-model="editForm.emeletAjto">
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
                  <label for="avatar">Profilkép feltöltése:</label>
                  <input type="file" id="avatar" accept="image/*" @change="handleFileUpload">
                  <label for="profilkep">Kép kiválasztása/feltöltése</label>
                  <div v-if="showCamera" class="camera-preview">
                  <video ref="videoRef" autoplay playsinline></video>
                  <canvas ref="canvasRef" style="display: none;"></canvas>
                  <div class="camera-controls">
                    <button type="button" @click="capturePhoto">Fotózás</button>
                    <button type="button" @click="stopCamera">Mégse</button>
                  </div>
                  <div v-if="capturedBlob">
                    <p>Előkép:</p>
                    <img :src="objectUrl" alt="preview" style="max-width: 200px;">
                    <button type="button" @click="uploadProfilePhoto" :disabled="uploading">
                      {{ uploading ? 'Feltöltés...' : 'Profilkép beállítása' }}
                    </button>
                  </div>
                </div>
                <button type="button" v-if="!showCamera" @click="startCamera">Kamera használata</button>

                  <div class="szerk-gombok">
                    <button type="submit" class="btn mentes" :disabled="saving">Mentés</button>
                    <button type="button" class="btn megse" @click="cancelSzerkesztes">Mégse</button>
                  </div>
                </form>
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
                <p class="post-excerpt">{{ p.kivonat }}</p>
                <div class="post-actions">
                  <RouterLink :to="`/blog/${p.id}`" class="read">Olvasás</RouterLink>
                  <RouterLink :to="`/editpost/${p.id}`" class="edit">Szerkesztés</RouterLink>
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
  font-size: 0.7rem;
  padding: 2px 8px;
  border-radius: 999px;
  margin-left: 8px;
}
.edit {
  background: #e5e7eb;
  color: #111827;
  padding: 8px 12px;
  border-radius: 10px;
  text-decoration: none;
  font-weight: 600;
}

/*#region Szerkesztés*/
.szerkesztes {
  box-sizing: border-box;
}

.szerk-modal-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.4);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 10;
}

.szerk-modal {
  background: #fff;
  padding: 0px 24px 24px 24px;
  border-radius: 12px;
  box-shadow: 0 8px 28px rgba(12,12,12,0.15);
  max-width: 400px;
  width: 100%;
  max-height: 90vh;
  overflow-y: auto;
}

label {
  display: block;
}

.camera-preview {
  background-color: #f0f0f0;
  padding: 10px;
  margin: 10px 0;
}

.camera-preview video {
  width: 100%;
  max-width: 400px;
  min-height: 300px;
  border: 2px solid blue;
  object-fit: cover;
}

input[type=text], input[type=tel], textarea, input[type=file], input[type=number] {
  width: 100%;
  padding: 5px;
  margin: 6px 0;
  display: inline-block;
  border: 1px solid #ccc;
  border-radius: 4px;
}

input[type=text]:focus, input[type=tel]:focus, textarea:focus, input[type=number]:focus {
  background-color: #ddd;
}

.varos-adat {
  display: inline-block;
  margin: 0 auto;
  width: 380px;
}

.varos {
  float: left;
  width: auto;
}
.varos input[type=text] {
  width: 100%;
}

.iranyitoszam {
  float: right;
}

.iranyitoszam input[type=text] {
  width: 80%;
}

.szerk-gombok {
  width: 350px;
  display:inline-block;
  overflow: auto;
  white-space: nowrap;
  margin:0px auto;
}

.mentes {
  float: left;
  background-color: #317431;
  color: #f3f3e2;
}

.megse {
  float: right;
  background: #e5e7eb; 
  color: #374151; 
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
  text-decoration: none;
}
.btn.edit { background: #eef2ff; }
.btn.logout { background: #fee2e2; color: #991b1b; }
.btn.follow { background: #111827; color: #fff; }

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
.btn.confirm { background: #dc2626; color: #fff; }
.btn.cancel { background: #e5e7eb; color: #374151; }

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
  /*
  background-size: cover;
  background-position: center;
  flex-shrink: 0;
  */
}
.post-cover img {
  width: 100%;
  height: 100%;
  object-fit: cover;
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

@media (max-width: 390px) {
  .szerk-gombok {
    width: 270px;
  }
}

@media (max-width: 310px) {
  .szerk-gombok {
    width: 170px;
  }
}

@media (max-width: 210px) {
  .szerk-gombok {
    width: 80px;
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
