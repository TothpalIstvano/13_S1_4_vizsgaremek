<script setup>
import { ref, reactive, onMounted, nextTick } from "vue"

// Multi-step form variables
const resz = ref(1)
const elsoLepes = ref(null)
const masodikLepes = ref(null)
const file = ref(null)
const showPixelation = ref(false)
const imageUrl = ref(null)

const tipusok = ["Horgolás", "Kötés", "Hímzés"]
const fonalak = [" 'A' fonal csoport", " 'B' fonal csoport", " 'C' fonal csoport", " 'D' fonal csoport", " 'E' fonal csoport"]

// Pixelation variables from tapestry.vue
const pixelSize = ref(15)
const gridOpacity = ref(20)
const canvas = ref(null)
const pixelRows = ref([])
const checkedRows = reactive({})
const currentImage = ref(null)
const imageLoaded = ref(false)

// Multi-step form functions
function kovetkezoResz() {
  if (resz.value === 1 && elsoLepes.value === "Hímzés") {
    masodikLepes.value = "A fonal csoport"
    resz.value = 3
    return
  }
  resz.value++
}

function modositas(target) {
  resz.value = target
}

function kepfeltoltes(event) {
  const selectedFile = event.target.files[0]
  if (selectedFile) {
    file.value = selectedFile
    const reader = new FileReader()
    reader.onload = (e) => {
      imageUrl.value = e.target.result
      
      const img = new Image()
      img.onload = () => {
        currentImage.value = img
        imageLoaded.value = true
        // Process immediately when image loads
        if (showPixelation.value) {
          nextTick(() => {
            processCanvas(img)
          })
        }
        saveToLocalStorage(imageUrl.value)
      }
      img.src = imageUrl.value
    }
    reader.readAsDataURL(selectedFile)
  }
}

function toMintavaltoztato() {
  if (file.value) {
    showPixelation.value = true
    // Wait for the view to render and then process the image
    nextTick(() => {
      if (currentImage.value && imageLoaded.value) {
        processCanvas(currentImage.value)
      } else {
        checkForSavedImage()
      }
    })
  }
}

// Pixelation functions from tapestry.vue (fixed version)
function processCanvas(img) {
  const pxSize = parseInt(pixelSize.value)
  
  if (!canvas.value) {
    console.error('Canvas not found')
    return
  }
  
  // Use original image dimensions
  const targetWidth = img.width
  const targetHeight = img.height
  
  canvas.value.width = targetWidth
  canvas.value.height = targetHeight

  const ctx = canvas.value.getContext('2d')
  ctx.drawImage(img, 0, 0, targetWidth, targetHeight)

  const imageData = ctx.getImageData(0, 0, targetWidth, targetHeight)
  const data = imageData.data

  const cols = Math.ceil(targetWidth / pxSize)
  const rows = Math.ceil(targetHeight / pxSize)
  
  console.log(`Processing: ${cols}x${rows} pixels, image: ${targetWidth}x${targetHeight}`)
  
  pixelRows.value = []

  // Initialize checked rows
  for (let i = 0; i < rows; i++) {
    if (checkedRows[i] === undefined) {
      checkedRows[i] = false
    }
  }

  // Create pixel rows without cropping
  for (let y = 0; y < rows; y++) {
    const pixels = []
    for (let x = 0; x < cols; x++) {
      const avg = getAverageColor(data, targetWidth, targetHeight, x * pxSize, y * pxSize, pxSize)
      pixels.push({
        color: `rgba(${avg.r}, ${avg.g}, ${avg.b}, ${avg.a})`
      })
    }
    pixelRows.value.push({
      pixels,
      rowOpacity: checkedRows[y] ? 0.5 : 1
    })
  }
}

function getAverageColor(data, width, height, startX, startY, blockSize) {
  let r = 0, g = 0, b = 0, a = 0, count = 0

  for (let y = startY; y < startY + blockSize && y < height; y++) {
    for (let x = startX; x < startX + blockSize && x < width; x++) {
      const i = (y * width + x) * 4
      if (i >= data.length - 3) continue

      r += data[i]
      g += data[i + 1]
      b += data[i + 2]
      a += data[i + 3]
      count++
    }
  }

  // Avoid division by zero
  if (count === 0) {
    return { r: 0, g: 0, b: 0, a: 0 }
  }

  return {
    r: Math.round(r / count),
    g: Math.round(g / count),
    b: Math.round(b / count),
    a: a / count / 255
  }
}

function toggleRowOpacity(rowIndex) {
  pixelRows.value[rowIndex].rowOpacity = checkedRows[rowIndex] ? 0.5 : 1
}

function updatePixelation() {
  if (currentImage.value) {
    processCanvas(currentImage.value)
    saveSettingsToLocalStorage()
  }
}

function saveToLocalStorage(imageData) {
  localStorage.setItem('pixelatedImage', imageData)
  saveSettingsToLocalStorage()
}

function saveSettingsToLocalStorage() {
  localStorage.setItem('pixelatorSettings', JSON.stringify({
    pixelSize: pixelSize.value,
    gridOpacity: gridOpacity.value
  }))
}

function checkForSavedImage() {
  const saved = localStorage.getItem('pixelatedImage')
  if (!saved) {
    // If no saved image but we have current image, process it
    if (currentImage.value) {
      processCanvas(currentImage.value)
    }
    return
  }

  const img = new Image()
  img.onload = () => {
    currentImage.value = img
    imageLoaded.value = true
    processCanvas(img)
  }
  img.src = saved

  const settings = localStorage.getItem('pixelatorSettings')
  if (settings) {
    const parsed = JSON.parse(settings)
    pixelSize.value = parseInt(parsed.pixelSize)
    gridOpacity.value = parseInt(parsed.gridOpacity)
  }
}

function clearImage() {
  pixelRows.value = []
  file.value = null
  imageUrl.value = null
  currentImage.value = null
  imageLoaded.value = false
  localStorage.removeItem('pixelatedImage')
  localStorage.removeItem('pixelatorSettings')
  
  // Reset file input
  const fileInput = document.getElementById('file-upload')
  if (fileInput) fileInput.value = ''
}

function backToForm() {
  showPixelation.value = false
}

function kepletoltes() {
  if (!canvas.value) return
  
  const link = document.createElement('a')
  link.download = 'minta.png'
  link.href = canvas.value.toDataURL()
  link.click()
}

function resetToOriginal() {
  if (currentImage.value) {
    processCanvas(currentImage.value)
    // Reset all checkboxes
    Object.keys(checkedRows).forEach(key => {
      checkedRows[key] = false
    })
    // Reset row opacities
    pixelRows.value.forEach((row, index) => {
      row.rowOpacity = 1
    })
  }
}

// Watch for when pixelation view becomes active and process image
import { watch } from 'vue'

watch(showPixelation, (newVal) => {
  if (newVal && currentImage.value && imageLoaded.value) {
    nextTick(() => {
      processCanvas(currentImage.value)
    })
  }
})

// Initialize when component mounts
onMounted(() => {
  // Check for saved image when component mounts
  checkForSavedImage()
})
</script>

<template>
  <main>
    <h1 class="title">Mintakészítő</h1>
      
    <div id="bemutato">
      <h2 class="cim">Mi is ez az oldal?</h2>
      <div class="ket_oszlop">
        <div class="harom_oszlop">
          <div class="kartya">
            <h3>Horgolás</h3>
            <p>Készítsd el saját horgolt mintádat kedvenc képeidből. Az alkalmazás pixelizálja a képet, hogy könnyen követhető mintaformátumban kapd meg.
              <ul>
                <li>Pixel alapú minták</li>
                <li>Színpaletta testreszabás</li>
                <li>Sortörések kezelése</li>
              </ul>
            </p>
          </div>
          <div class="kartya">
            <h3>Kötés</h3>
    <p>Alakítsd át a fotóidat kötött mintává. A pixelizálás segít a színek és minták pontos reprodukálásában.
              <ul>
                <li>Pontos színátalakítás</li>
                <li>Reszponzív mintaméret</li>
                <li>Könnyű nyomkövetés</li>
              </ul>
            </p>
          </div>
          <div class="kartya">
            <h3>Hímzés</h3>
            <p>Hímzéshez optimalizált mintákat készíthetsz. A részletes pixelrács segít a pontos varratmegtervezésben.
              <ul>
                <li>Részletes rácsnézet</li>
                <li>Sortükrözés lehetősége</li>
                <li>Exportálás nyomtatható formátumban</li>
              </ul>
            </p>
          </div>
        </div>
        <div class="blog_info">
          <h3>Használati útmutató</h3>
          <ol>
            <li>Válaszd ki a kívánt technikát</li>
            <li>Add meg a használni kívánt fonal típusát</li>
            <li>Tölts fel egy képet</li>
            <li>Állítsd be a pixel méretet és átlátszóságot</li>
            <li>Jelöld meg a kívánt sorokat</li>
            <li>Töltsd le a mintát</li>
          </ol>
        </div>
      </div>
    </div>

    <!-- Creator View -->
    <div v-if="!showPixelation">
      <div id="adatok">
        <div class="progress-container">
          <div class="progress-bar">
            <div 
              class="progress-step" 
              :class="{ active: resz >= 1, clickable: resz !== 1 }" 
              @click="resz !== 1 && (resz = 1)"
            >1</div>
            <div 
              class="progress-step" 
              :class="{ active: resz >= 2, clickable: resz !== 1 && resz !== 2 }"
              @click="resz !== 1 && resz !== 2 && (resz = 2)"
            >2</div>
            <div class="progress-step" :class="{ active: resz >= 3 }">3</div>
          </div>
          <div class="progress-labels">
            <div class="progress-label">Típus</div>
            <div class="progress-label">Fonal</div>
            <div class="progress-label">Fájl</div>
          </div>
        </div>
        
        <!-- 1. rész -->
        <div v-show="resz === 1" id="elsoResz" class="radioStilus">
          <p class="cimek">Válassz típust a projektedhez:</p>
          <div class="radioBelso">
            <div v-for="option in tipusok" :key="option" class="radio-container">
              <input
                type="radio"
                :id="option"
                name="elsoLepes"
                :value="option"
                v-model="elsoLepes"
              />
              <label :for="option">{{ option }}</label>
            </div>
          </div>
          
          <button
            :disabled="!elsoLepes"
            @click="kovetkezoResz"
            class="tovabbGomb"
          >
            Következő ⇒
          </button>
        </div>
        
        <!-- 2. rész -->
        <div v-show="resz === 2" id="masodikResz" class="radioStilus">
          <p class="vissza">
            A projekted: <strong>{{ elsoLepes }}</strong> 
            <button @click="modositas(1)" class="visszaGomb">Vissza</button>
          </p>

          <p class="cimek">Válassz fonaltípust:</p>
          <div class="radioBelso">
            <div v-for="option in fonalak" :key="option" class="radio-container">
              <input
                type="radio"
                :id="option"
                name="masodikLepes"
                :value="option"
                v-model="masodikLepes"
              />
              <label :for="option">{{ option }}</label>
            </div>
          </div>
          
          <button
            :disabled="!masodikLepes"
            @click="kovetkezoResz"
            class="tovabbGomb"
          >
            Következő ⇒
          </button>
        </div>
        
        <!-- 3. rész -->
        <div v-show="resz === 3" id="harmadikResz">
          <p class="vissza">
            A projekted: <strong>{{ elsoLepes }}</strong> 
            <button @click="modositas(1)" class="visszaGomb">Vissza</button>
          </p>
          <p class="vissza">
            A fonaltípusod: <strong>{{ masodikLepes }}</strong> 
            <button @click="modositas(2)" class="visszaGomb">Vissza</button>
          </p>

          <p class="cimek">Fájl feltöltése:</p>
          <label for="file-upload" class="file-upload-label">
            Kép kiválasztása
          </label>
          <input id="file-upload" type="file" @change="kepfeltoltes" accept="image/*" />
          
          <div v-if="file" class="file-preview-container">
            <img :src="imageUrl" alt="Preview" class="file-preview" />
            <p>{{ file.name }}</p>
          </div>

          <button
            :disabled="!file"
            @click="toMintavaltoztato" 
            class="tovabbGomb">
            Minta készítése ⇒
          </button>
        </div>
      </div>
    </div>

    <!-- Pixelation View -->
    <div v-else >
      <div class="pixelesContainer oszlop">
        <h1>Minta Változtató</h1>
        
        <div v-if="!currentImage" class="feltoltes">
          <p>Nincs kép betöltve. Kérjük, menj vissza és tölts fel egy képet.</p>
          <button @click="backToForm" class="visszaGomb">Vissza a feltöltéshez</button>
        </div>

        <div v-else class="modositoContainer">
          <div class="modositas">
            <div class="valtoztatok">
              <p>Pixel Méret: {{ pixelSize }}px</p>
              <input 
                type="range" 
                min="5" 
                max="40" 
                v-model="pixelSize" 
                class="csuszka"
                @input="updatePixelation"
              />
            </div>

            <div class="valtoztatok">
              <p>Rács Átlátszóság: {{ gridOpacity }}%</p>
              <input 
                type="range" 
                min="0" 
                max="60" 
                v-model="gridOpacity" 
                class="csuszka"
                @input="updatePixelation"
              />
            </div>
          </div>

          <!-- Hidden canvas for processing -->
          <canvas ref="canvas" style="display: none;"></canvas>

          <!-- Pixel Grid Display -->
          <div class="pixel-grid-container">
            <div class="pixel-info">
              <p>Kép mérete: {{ currentImage.width }}×{{ currentImage.height }} px | 
                Pixel rács: {{ pixelRows.length }}×{{ pixelRows[0]?.pixels.length || 0 }}</p>
            </div>
            <div class="pixel-container" v-if="pixelRows.length > 0">
              <div
                v-for="(row, rowIndex) in pixelRows"
                :key="rowIndex"
                class="pixel-row"
                :style="{ opacity: row.rowOpacity }"
              >
                <div class="pixel-row-content">
                  <div
                    v-for="(pixel, pixelIndex) in row.pixels"
                    :key="pixelIndex"
                    class="pixel"
                    :style="{
                      width: pixelSize + 'px',
                      height: pixelSize + 'px',
                      backgroundColor: pixel.color,
                      borderColor: `rgba(0, 0, 0, ${gridOpacity / 100})`,
                    }"
                  ></div>
                </div>

                <div class="checkbox-container">
                  <input
                    type="checkbox"
                    :id="`row-${rowIndex}`"
                    v-model="checkedRows[rowIndex]"
                    @change="toggleRowOpacity(rowIndex)"
                  />
                  <label :for="`row-${rowIndex}`">{{ rowIndex + 1 }}</label>
                </div>
              </div>
            </div>
            <div v-else>
              <p>Kép feldolgozása folyamatban van</p>
            </div>
          </div>

          <div class="gombok">
            <button @click="backToForm" class="gomb">Vissza a feltöltéshez</button>
            <button @click="resetToOriginal" class="gomb">Eredeti állapot</button>
            <button @click="kepletoltes" class="gomb letolt">Letöltés</button>
            <button @click="clearImage" class="gomb">Új kép</button>
          </div>
        </div>
      </div>
      


      <div class="oldalsav oszlop">
          <div class="oldalKartya">
            <h3>Projekt adatai</h3>
            <p><strong>Technika:</strong> {{ elsoLepes }}</p>
            <p><strong>Fonal típus:</strong> {{ masodikLepes }}</p>
            <p><strong>Pixel méret:</strong> {{ pixelSize }}px</p>
            <p><strong>Kiválasztott sorok:</strong> {{ Object.values(checkedRows).filter(Boolean).length }}</p>
          </div>
          <div class="oldalKartya">
            <h3>Tippek</h3>
            <ul>
              <li>Jelöld meg azokat a sorokat, amelyeket külön szeretnél kezelni</li>
              <li>Kisebb pixel méret részletesebb mintát ad</li>
              <li>A rács átlátszósága segít a minta követésében</li>
            </ul>
          </div>
        </div>

    </div>
  </main>
</template>

<style scoped>
body {
  font-family: 'Poppins', sans-serif;
  color: var(--mk-text-dark);
  background-color: rgb(255, 211, 144);
}

main {
  margin: 0 auto;
  height: auto;
  text-align: center;
  overflow-x: hidden;
  padding: 20px;
}

.title {
  display: inline-block;
  font-weight: 700;
  font-size: 45px;
  color: var(--mk-text-dark);
  background-image: linear-gradient(90deg, #b4a2ee, #3a11c0);
  background-repeat: no-repeat;
  background-position: 0 100%;
  background-size: 100% 4px;
  padding-bottom: 6px;
}

.cim {
  font-size: 26px;
  margin-bottom: 30px;
}

/*#region felső szövegdobozok*/
#bemutato {
  margin: auto;
  text-align: justify;
  margin-bottom: 50px;
  border-radius: 10px;
}

.ket_oszlop {
  display: grid;
  grid-template-columns: 3fr 2fr;
  gap: 35px;
  align-items: start;
  width: 100%;
  margin: 0 auto 3rem;
  padding: 1rem;
}

.harom_oszlop {
  display: grid;
  grid-template-columns: repeat(3, minmax(200px, 1fr));
  gap: 30px;
  margin: 0;
  padding: 0;
  width: 100%;
  box-sizing: border-box;
}

.kartya {
  background-color: var(--mk-szovegdoboz);
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 4px 15px var(--mk-arnyekszin);
  transition: transform 0.3s ease, box-shadow 0.3s ease;
  position: relative;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.kartya:hover {
  transform: translateY(-10px);
  box-shadow: 0 6px 20px var(--mk-arnyekszin);
}

.kartya h3 {
  color: var(--mk-text-dark);
  margin-bottom: 1rem;
  font-size: 1.5rem;
  font-weight: 600;
}

.kartya ul {
  text-align: left;
  margin-top: 10px;
}

.kartya li {
  margin-bottom: 5px;
}

.blog_info {
  width: 100%;
  box-sizing: border-box;
  align-self: start;
  background-color: var(--mk-szovegdoboz);
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
  position: relative;
  overflow: hidden;
}

.blog_info ol {
  text-align: left;
  padding-left: 20px;
}

.blog_info li {
  margin-bottom: 10px;
}
/*#endregion*/

/*#region adatbekérés*/
#adatok {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
  background-color: var(--mk-hatterszin);
  border-radius: 8px;
  box-shadow: 0 2px 15px var(--mk-arnyekszin);
}

.radioStilus {
  padding: 1.5rem;
  transition: opacity 0.3s ease;
}

.cimek {
  font-size: 1.5rem;
  font-weight: 600;
  color: var(--mk-text-dark);
  margin-bottom: 1.5rem;
  text-align: center;
}

.radioBelso {
  background-color: var(--mk-radioszin);
  border-radius: 5px;
  padding: 25px;
  margin-bottom: 20px;
  box-shadow: 0 4px 5px var(--mk-arnyekszin);
}

.radio-container {
  display: flex;
  align-items: center;
  margin-bottom: 15px;
}

input[type="radio"] {
  appearance: none;
  -webkit-appearance: none;
  width: 22px;
  height: 22px;
  border: 2px solid rgb(29, 3, 61);
  border-radius: 25%;
  margin-right: 12px;
  position: relative;
  transition: all 0.2s ease;
  background-color: transparent;
}

input[type="radio"]:checked::before {
  content: "";
  display: block;
  width: 14px;
  height: 14px;
  background-color: var(--mk-checkbox);
  border-radius: 20%;
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  animation: checkboxValaszt 0.6s;
}

input[type="radio"]:hover {
  border-color: var(--mk-checkbox);
  transform: scale(1.1);
}

@keyframes checkboxValaszt {
  0% {
    transform: translate(-50%, -50%) scale(0.5);
    background-color: #9b4be1;
  }
  50% {
    transform: translate(-50%, -50%) scale(1.5);
    background-color: #43167f;
  }
  100% {
    transform: translate(-50%, -50%) scale(1);
    background-color: var(--mk-checkbox);
  }
}

label {
  color: var(--mk-text-dark);
  cursor: pointer;
  transition: color 0.2s ease;
  font-size: 18px;
}

label:hover {
  color: rgb(16, 1, 27);
  transform: scale(1.02);
}

.tovabbGomb {
  display: block;
  width: 200px;
  height: 50px;
  margin: 2rem auto 0;
  border: none;
  border-radius: 15px;
  background: linear-gradient(135deg, var(--mk-gomb-foszin), var(--mk-gomb-masodszin));
  color: var(--white);
  font-weight: 600;
  font-size: 1rem;
  letter-spacing: 1px;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 15px var(--mk-arnyekszin);
  overflow: hidden;
  position: relative;
}

.tovabbGomb::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
  transition: left 0.5s;
}

.tovabbGomb:hover::before {
  left: 100%;
}

.tovabbGomb:hover {
  transform: translateY(-3px);
  box-shadow: 0 6px 20px rgba(70, 6, 119, 0.473);
}

.visszaGomb {
  padding: 0.5rem 1rem;
  border: none;
  border-radius: 10px;
  background-color: var(--mk-visszagomb);
  color: var(--mk-text-light);
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  margin-left: 15px;
}

.visszaGomb:hover {
  background-color: var(--mk-gomb-masodszin);
  transform: translateY(-2px);
  color: var(--mk-text-dark);
}

.tovabbGomb:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.tovabbGomb:disabled:hover {
  background: linear-gradient(0deg, var(--mk-gomb-masodszin) 0%, var(--mk-gomb-foszin) 100%);
  color: rgb(24, 23, 23);
  box-shadow: inset 2px 2px 2px 0px var(--mk-arnyekszin),
              7px 7px 20px 0px rgba(0,0,0,.1),
              4px 4px 5px 0px rgba(0,0,0,.1);
  transform: none;
}

input[type="file"] {
  display: none;
}

.file-upload-label {
  display: inline-block;
  padding: 1rem 2rem;
  background-color: var(--mk-gomb-masodszin);
  color: var(--mk-text-dark);
  border-radius: 10px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
  margin-bottom: 1rem;
}

.file-upload-label:hover {
  background-color: var(--mk-gomb-foszin);
  transform: translateY(-3px);
}

.file-preview {
  max-width: 100%;
  max-height: 300px;
  margin: 1rem auto;
  border-radius: 10px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
}

.file-preview-container {
  margin: 20px 0;
}

.progress-container {
  margin-bottom: 2rem;
}

.progress-bar {
  display: flex;
  justify-content: space-between;
  margin-bottom: 0.5rem;
}

.progress-step {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background-color: var(--mk-arnyekszin);
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 600;
  color: #999;
  position: relative;
}

.progress-step.active {
  background-color: var(--mk-radioszin);
  color: white;
}

.progress-step.clickable {
  cursor: pointer;
}

.progress-step.clickable:hover {
  background-color: rgb(96, 65, 136);
}

.progress-step:not(:last-child)::after {
  content: '';
  position: absolute;
  top: 50%;
  left: 100%;
  width: 100%;
  height: 2px;
  background-color: var(--mk-secondary-light);
  z-index: -1;
}

.progress-step.active:not(:last-child)::after {
  background-color: rgb(248, 233, 24);
}

.progress-labels {
  display: flex;
  justify-content: space-between;
}

.progress-label {
  font-size: 0.9rem;
  color: var(--mk-text-dark);
}
/*#endregion*/

/*#region mintaváltozásos box*/
.pixelesContainer {
  padding: 2rem;
  max-width: 1400px;
  margin: 0 auto;
  background-color: var(--mk-hatterszin);
  min-height: 100vh;
  border-radius: 10px;
  display: grid;
  grid-template-columns: 1fr 300px;
  gap: 20px;
}

.modositoContainer {
  grid-column: 1;
}

.feltoltes {
  text-align: center;
  padding: 2rem;
}

.modositas {
  display: flex;
  flex-wrap: wrap;
  gap: 2rem;
  margin-bottom: 2rem;
  padding: 1rem;
  background: var(--mk-radioszin);
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.valtoztatok {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  min-width: 200px;
}

.csuszka {
  width: 100%;
  accent-color: #6c5ce7;
}

.pixel-grid-container {
  margin-top: 20px;
  overflow: auto;
  max-height: 70vh;
  border: 1px solid #ddd;
  padding: 10px;
  background-color: #f9f9f9;
  border-radius: 8px;
}

.pixel-info {
  text-align: center;
  margin-bottom: 10px;
  font-size: 0.9em;
  color: #666;
}

.pixel-container {
  display: flex;
  flex-direction: column;
  width: fit-content;
  margin: 0 auto;
}

.pixel-row {
  display: flex;
  align-items: center;
  margin-bottom: 2px;
  transition: opacity 0.3s ease;
}

.pixel-row-content {
  display: flex;
}

.pixel {
  border: 1px solid rgba(0, 0, 0, 0.1);
  box-sizing: border-box;
  flex-shrink: 0;
}

.checkbox-container {
  display: flex;
  align-items: center;
  margin-left: 10px;
  min-width: 60px;
}

.checkbox-container label {
  margin-left: 5px;
  font-size: 0.9em;
}

.gombok {
  display: flex;
  justify-content: center;
  gap: 1rem;
  margin-top: 2rem;
  flex-wrap: wrap;
}

.gomb {
  padding: 10px 20px;
  border: none;
  border-radius: 5px;
  cursor: pointer;
  font-weight: bold;
  background-color: #6c5ce7;
  color: white;
  transition: background-color 0.3s;
  min-width: 120px;
}

.gomb:hover {
  background-color: #5649c0;
  transform: translateY(-2px);
}

.gomb.letolt {
  background-color: #4CAF50;
}

.gomb.letolt:hover {
  background-color: #45a049;
}
/*#endregion*/

/*#region Oldalsáv */
.oszlop {
  float: left;
}

.oldalsav {
  grid-column: 2;
  display: flex;
  flex-direction: column;
  gap: 20px;
  margin-left: 30px;
}

.oldalKartya {
  background-color: var(--mk-szovegdoboz);
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 4px 15px var(--mk-arnyekszin);
}

.oldalKartya h3 {
  color: var(--mk-text-dark);
  margin-bottom: 1rem;
  font-size: 1.2rem;
  font-weight: 600;
}

.oldalKartya ul {
  text-align: left;
  padding-left: 20px;
}

.oldalKartya li {
  margin-bottom: 8px;
  font-size: 0.9em;
}
/*#endregion*/

@media (max-width: 1100px) {
  .ket_oszlop {
    grid-template-columns: 1fr;
  }

  .harom_oszlop {
    grid-template-columns: repeat(2, minmax(180px, 1fr));
  }
  
  .pixelesContainer {
    grid-template-columns: 1fr;
  }
  
  .oldalsav {
    grid-column: 1;
    margin-top: 20px;
  }
}

@media (max-width: 768px) {
  .harom_oszlop {
    grid-template-columns: 1fr;
  }
  
  .title {
    font-size: 2rem;
  }
  
  #adatok {
    padding: 1.5rem;
  }
  
  input[type="radio"] {
    width: 18px;
    height: 18px;
  }
  
  label {
    font-size: 1rem;
  }
  
  .gombok {
    flex-direction: column;
    align-items: center;
  }
  
  .modositas {
    flex-direction: column;
    gap: 1rem;
  }
  
  .valtoztatok {
    min-width: auto;
  }
}
</style>