<script setup>
import { ref, onMounted, nextTick, reactive } from "vue"
import { useRouter } from "vue-router"

const resz = ref(1)
const elsoLepes = ref(null)
const masodikLepes = ref(null)
const file = ref(null)
const showPixelation = ref(false) // Controls which view to show

const tipusok = ["Horgolás", "Kötés", "Hímzés"]
const fonalak = [" 'A' fonal csoport", " 'B' fonal csoport", " 'C' fonal csoport", " 'D' fonal csoport", " 'E' fonal csoport"]

const router = useRouter()

// Creator functions
function kovetkezoResz() {
  // ha a hímzés van kiválasztva átugorja a fonalválasztást
  if (resz.value === 1 && elsoLepes.value === "Hímzés") {
    masodikLepes.value = "A fonal csoport"
    resz.value = 3
    return
  }

  resz.value++
}

function modositas(target) {
  // ha hímzés van kiválasztva ne lehessen módosítani a fonaltípust
  resz.value = target
}

const imageUrl = ref(null)

function kepfeltoltes(event) {
  const selectedFile = event.target.files[0]
  if (selectedFile) {
    file.value = selectedFile
    imageUrl.value = URL.createObjectURL(selectedFile)
  }
}

function toMintavaltoztato() {
 if (file.value) {
    const url = URL.createObjectURL(file.value)
    imageUrl.value = url
    showPixelation.value = true
    
    // Initialize the pixelation tool after the DOM is updated
    nextTick(() => {
      initializePixelation()
    })
  }
}

// Pixelation functions
const eredetiKep = ref(null)
const pixelMeret = ref(10)
const szinezes = ref("eredeti")
const szinekSzama = ref(20)
const szinPaletta = ref([])
const valasztottSzin = ref(null)
const ctx = ref(null)
const jelenlegiKep = ref(null)
const canvas = ref(null)

// New variables for checkbox functionality
const pixelRows = ref([])
const checkedRows = reactive({})
const gridOpacity = ref(20)
const useCanvasView = ref(true) // Toggle between canvas and pixel grid view

function initializePixelation() {
  if (!imageUrl.value) return
  
  eredetiKep.value = new Image()
  eredetiKep.value.onload = () => {
    vaszonLetrehozasa()
    kepFrissites()
  }
  eredetiKep.value.crossOrigin = "anonymous"  //más domain-ről is be tud tölteni a kép
  eredetiKep.value.src = imageUrl.value
}

function vaszonLetrehozasa() {
  if (!canvas.value) return
  
  ctx.value = canvas.value.getContext("2d")
  canvas.value.width = eredetiKep.value.width
  canvas.value.height = eredetiKep.value.height
}

function kepFrissites() {
  if (!eredetiKep.value || !canvas.value) return
  
  vaszonFeldolgozas(eredetiKep.value)
  kinyertSzinPaletta()
  
  // Update pixel rows for checkbox view
  if (!useCanvasView.value) {
    updatePixelRows()
  }
}

function vaszonFeldolgozas(img) {
  const pixelMeretValue = parseInt(pixelMeret.value)
  const canvasEl = canvas.value
  const ctxValue = ctx.value
  
  if (!canvasEl || !ctxValue) return
  
  const szelesseg = img.width
  const magassag = img.height
  
  canvasEl.width = szelesseg
  canvasEl.height = magassag

  ctxValue.drawImage(img, 0, 0, szelesseg, magassag)

  const imageData = ctxValue.getImageData(0, 0, szelesseg, magassag)
  const data = imageData.data
  
  jelenlegiKep.value = { data, width: szelesseg, height: magassag }

  if (szinezes.value === 'eredeti') {
    kepElkeszites(data, szelesseg, magassag, pixelMeretValue)
  }
  else if (szinezes.value === 'kevesebbSzin') {
    kepElkeszitesKevesebbSzin(data, szelesseg, magassag, pixelMeretValue)
  }

  ctxValue.putImageData(imageData, 0, 0)
}

function kepElkeszites(data, width, height, pixelSize) {
  const cols = Math.ceil(width / pixelSize)
  const rows = Math.ceil(height / pixelSize)

  for (let y = 0; y < rows; y++) {
    for (let x = 0; x < cols; x++) {
      const avg = szinekKinyeres(data, width, x * pixelSize, y * pixelSize, pixelSize)
      
      for (let Ytengely = y * pixelSize; Ytengely < (y + 1) * pixelSize && Ytengely < height; Ytengely++) {
        for (let Xtengely = x * pixelSize; Xtengely < (x + 1) * pixelSize && Xtengely < width; Xtengely++) {
          const i = (Ytengely * width + Xtengely) * 4
          data[i] = avg.r
          data[i + 1] = avg.g
          data[i + 2] = avg.b
        }
      }
    }
  }
}

function kepElkeszitesKevesebbSzin(data, width, height, pixelSize) {
  const cols = Math.ceil(width / pixelSize)
  const rows = Math.ceil(height / pixelSize)

  for (let y = 0; y < rows; y++) {
    for (let x = 0; x < cols; x++) {
      const avg = szinekKinyeres(data, width, x * pixelSize, y * pixelSize, pixelSize)
      
      const precision = Math.round(255 / szinekSzama.value)
      const limitedR = Math.round(avg.r / precision) * precision
      const limitedG = Math.round(avg.g / precision) * precision
      const limitedB = Math.round(avg.b / precision) * precision
      
      for (let Ytengely = y * pixelSize; Ytengely < (y + 1) * pixelSize && Ytengely < height; Ytengely++) {
        for (let Xtengely = x * pixelSize; Xtengely < (x + 1) * pixelSize && Xtengely < width; Xtengely++) {
          const i = (Ytengely * width + Xtengely) * 4
          data[i] = limitedR
          data[i + 1] = limitedG
          data[i + 2] = limitedB
        }
      }
    }
  }
}

function szinekKinyeres(data, width, startX, startY, blockSize) {
  let r = 0, g = 0, b = 0, a = 0, count = 0

  for (let y = startY; y < startY + blockSize && y < width; y++) {
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

  return {
    r: Math.round(r / count),
    g: Math.round(g / count),
    b: Math.round(b / count),
    a: a / count / 255
  }
}

function kinyertSzinPaletta() {
  if (!jelenlegiKep.value) return
  
  const { data, width, height } = jelenlegiKep.value
  const szinek = new Set()
  
  for (let i = 0; i < data.length; i += 80) {
    const r = data[i]
    const g = data[i + 1]
    const b = data[i + 2]
    const color = `rgb(${r}, ${g}, ${b})`
    szinek.add(color)
  }
  
  szinPaletta.value = Array.from(szinek).slice(0, szinekSzama.value)
}

function szinValaszto(color) {
  valasztottSzin.value = color
}

function frissítettSzin(index, newColor) {
  szinPaletta.value[index] = newColor
  // színcserélő (a képen frissüljön a szín)
}

function ujrakedzes() {
  kepFrissites()
}

function kepletoltes() {
  const canvasEl = canvas.value
  if (!canvasEl) return
  
  const link = document.createElement('a')
  link.download = 'minta.png'
  link.href = canvasEl.toDataURL()
  link.click()
}

function backToForm() {
  showPixelation.value = false
}

// New functions for checkbox functionality
function updatePixelRows() {
  if (!jelenlegiKep.value) return
  
  const { data, width, height } = jelenlegiKep.value
  const pixelSize = parseInt(pixelMeret.value)
  const cols = Math.ceil(width / pixelSize)
  const rows = Math.ceil(height / pixelSize)
  
  pixelRows.value = []
  
  // Initialize checked rows
  for (let i = 0; i < rows; i++) {
    if (checkedRows[i] === undefined) {
      checkedRows[i] = false
    }
  }
  
  // Create pixel rows
  for (let y = 0; y < rows; y++) {
    const pixels = []
    for (let x = 0; x < cols; x++) {
      const avg = szinekKinyeres(data, width, x * pixelSize, y * pixelSize, pixelSize)
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

function toggleRowOpacity(rowIndex) {
  // Toggle between full opacity (1) and lowered opacity (0.5)
  pixelRows.value[rowIndex].rowOpacity = checkedRows[rowIndex] ? 0.5 : 1
}

function toggleView() {
  useCanvasView.value = !useCanvasView.value
  console.log('Toggled view, useCanvasView:', useCanvasView.value)
  if (!useCanvasView.value) {
    updatePixelRows()
  }
}
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
              <p>Lorem ipsum dolor sit amet consectetur, adipisicing elit. Alias odio accusantium nihil impedit quam repellendus dolore, atque ducimus voluptates natus blanditiis, eaque, inventore quod! Exercitationem repellat repellendus esse corporis eaque.
                <ul>
                  <li>pontok</li>
                </ul>
              </p>
            </div>
            <div class="kartya">
              <h3>Kötés</h3>
              <p>Lorem ipsum dolor sit amet consectetur, adipisicing elit. Alias odio accusantium nihil impedit quam repellendus dolore, atque ducimus voluptates natus blanditiis, eaque, inventore quod! Exercitationem repellat repellendus esse corporis eaque.
                <ul>
                  <li>pontok</li>
                </ul>
              </p>
            </div>
            <div class="kartya">
              <h3>Hímzés</h3>
              <p>Lorem ipsum dolor sit amet consectetur, adipisicing elit. Alias odio accusantium nihil impedit quam repellendus dolore, atque ducimus voluptates natus blanditiis, eaque, inventore quod! Exercitationem repellat repellendus esse corporis eaque.
                <ul>
                  <li>pontok</li>
                </ul>
              </p>
            </div>
          </div>
          <div class="blog_info">
            <div>
              szöveg
            </div>
          </div>
        </div>
      </div>
    <!-- Creator View (shown when showPixelation is false) -->
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
          <input id="file-upload" type="file" @change="kepfeltoltes" />
          
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

    <!-- Pixelation View (shown when showPixelation is true) -->
    <div v-else>
      <div class="pixelesContainer oszlop">
        <h1>Minta Változtató</h1>
        
        <div v-if="!imageUrl" class="feltoltes">
          <p>Nincs kép betöltve. Kérjük, menj vissza és tölts fel egy képet.</p>
          <button @click="backToForm" class="visszaGomb">Vissza a feltöltéshez</button>
        </div>

        <div v-else class="modositoContainer">
          <div class="modositas">
            <div class="valtoztatok">
              <p>Pixel Méret: {{ pixelMeret }}px</p>
              <input 
                type="range" 
                min="5" 
                max="40" 
                v-model="pixelMeret" 
                class="csuszka"
                @input="kepFrissites"
              />
            </div>

            <div class="valtoztatok">
              <p>Szín Mód:</p>
              <select v-model="szinezes" class="lenyiloBox" @change="kepFrissites">
                <option value="eredeti">Eredeti színek</option>
                <option value="kevesebbSzin">Korlátozott színpaletta</option>
              </select>
            </div>

            <div class="valtoztatok" v-if="szinezes === 'kevesebbSzin'">
              <p>Színek száma: {{ szinekSzama }}</p>
              <input 
                type="range" 
                min="2" 
                max="20" 
                v-model="szinekSzama" 
                class="csuszka"
                @input="kepFrissites"
              />
            </div>

            <!-- New control for grid opacity -->
            <div class="valtoztatok">
              <p>Rács Átlátszóság: {{ gridOpacity }}%</p>
              <input 
                type="range" 
                min="0" 
                max="60" 
                v-model="gridOpacity" 
                class="csuszka"
                @input="kepFrissites"
              />
            </div>

            <!-- New toggle for view mode -->
            <div class="valtoztatok">
              <button @click="toggleView" class="view-toggle">
                {{ useCanvasView ? 'Sorok Kezelése' : 'Vászon Nézet' }}
              </button>
            </div>
          </div>

          <div v-if="szinPaletta.length > 0" class="szin-paletta">
            <h3>Színpaletta</h3>
            <div class="szinek">
              <div 
                v-for="(color, index) in szinPaletta" 
                :key="index" 
                class="szinek-class"
                :style="{ backgroundColor: color }"
                @click="szinValaszto(color)"
                :class="{ selected: valasztottSzin === color }"
              >
                <input 
                  type="color" 
                  :value="color" 
                  @input="frissítettSzin(index, $event.target.value)"
                  @click.stop
                />
              </div>
            </div>
          </div>

          <!-- Canvas View (original) -->
          <div v-if="useCanvasView" class="canvas-container">
            <canvas ref="canvas"></canvas>
          </div>

          <!-- Pixel Grid View (new) with checkboxes -->
          <div v-else class="pixel-grid-container">
            <div class="pixel-grid">
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
                      width: pixelMeret + 'px',
                      height: pixelMeret + 'px',
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
          </div>

          <div class="gombok">
            <button @click="backToForm" class="gombok">Vissza a módosításhoz</button>
            <button @click="ujrakedzes" class="gombok">Eredeti kép</button>
            <button @click="kepletoltes" class="gombok letolt">Letöltés</button>
            <button @click="backToForm" class="gombok">Új kép</button>
          </div>
        </div>
      </div>
      
      <div class="oldalsav oszlop">
        <div class="oldalKartya">
          <p>{{ fonalak.values }}</p>
        </div>
        <div class="oldalKartya">
          Adatok
        </div>
      </div>

    </div>

  </main>
</template>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap');

body {
  font-family: 'Poppins', sans-serif;
  color: var(--mk-text-dark);
  background-color: rgb(255, 211, 144);
}

main {
  margin: 0 auto;
  height: auto;
  text-align: center;
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

main {
  margin: 0 auto;
  padding: 20px;
  height: auto;
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
  padding: 10px 30px;
  box-shadow: 0 4px 15px var(--mk-arnyekszin);
  transition: transform 0.3s ease, box-shadow 0.3s ease;
  position: relative;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  justify-content: end;
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

.blog_info {
  width: 100%;
  box-sizing: border-box;
  align-self: start;
  background-color: var(--mk-szovegdoboz);
  border-radius: 8px;
  padding: 10px 30px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
  transition: transform 0.3s ease, box-shadow 0.3s ease;
  position: relative;
  overflow: hidden;
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
  margin-bottom: 5px;
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
  margin-bottom: 7px;
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
  margin-bottom: 5px;
}

label:hover {
  color: rgb(16, 1, 27);
  transform: scale(1.1);
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

/*#region oldalsáv*/
.oszlop {
  float: left;
}

.oldalsav {
  background-color: #3a11c0;
  margin-left: 10px;
  border: 4px solid hotpink;
}

.oldalKartya {
  background-color: #9b4be1;
  border: 2px solid black;
}

/*#endregion*/

/*#region mintaváltozásos box*/
.pixelesContainer {
  padding: 2rem;
  max-width: 1200px;
  margin: 0 auto;
  background-color: var(--mk-hatterszin);
  min-height: 100vh;
  border-radius: 10px;
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
}

.csuszka {
  width: 200px;
}

.lenyiloBox {
  padding: 5px;
  border-radius: 4px;
  border: 1px solid #ddd;
}

.view-toggle {
  padding: 8px 16px;
  background-color: #4CAF50;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.view-toggle:hover {
  background-color: #45a049;
}

.szin-paletta {
  margin: 2rem 0;
  padding: 1rem;
  background: var(--mk-radioszin);
  border-radius: 8px;
}

.szinek {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin-top: 1rem;
}

.szinek-class {
  position: relative;
  width: 50px;
  height: 50px;
  border: 2px solid transparent;
  border-radius: 4px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
}

.szinek-class input[type="color"] {
  opacity: 0;
  position: absolute;
  width: 100%;
  height: 100%;
  cursor: pointer;
}

.canvas-container {
  display: flex;
  justify-content: center;
  margin: 1rem 0;
}

canvas {
  max-width: 100%;
  box-shadow: var(--canvas-shadow);
  margin: 1rem 0;
}

.pixel-grid-container {
  margin-top: 20px;
  overflow: auto;
  max-height: 70vh;
  border: 1px solid #ddd;
  padding: 10px;
  background-color: #f9f9f9;
  display: flex;
  justify-content: center;
}

.pixel-grid {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.pixel-row {
  display: flex;
  align-items: center;
  gap: 10px;
}

.pixel-row-content {
  display: flex;
  flex-direction: row;
  flex-wrap: nowrap;
}

.pixel {
  border: 1px solid rgba(0, 0, 0, 0.1);
  box-sizing: border-box;
  flex-shrink: 0;
}

.checkbox-container {
  display: flex;
  align-items: center;
  min-width: 60px;
  justify-content: center;
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
}

.gombok {
  padding: 10px 20px;
  border: none;
  border-radius: 5px;
  cursor: pointer;
  font-weight: bold;
}

.gombok.letolt {
  background-color: #4CAF50;
  color: white;
}

/*#endregion*/

@media (max-width: 1100px) {
  .ket_oszlop {
    grid-template-columns: 1fr;
  }

  .harom_oszlop {
    grid-template-columns: repeat(2, minmax(180px, 1fr));
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
}
</style>