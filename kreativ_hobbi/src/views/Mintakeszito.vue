<script setup>
import { ref, reactive, onMounted } from 'vue'

const pixelSize = ref(15)
const gridOpacity = ref(20)
const canvas = ref(null)
const imageInput = ref(null)

const pixelRows = ref([])
const checkedRows = reactive({})
const currentImage = ref(null)

onMounted(() => {
  checkForSavedImage()
})

function handleFile() {
  const file = imageInput.value.files[0]
  if (file) {
    const reader = new FileReader()
    reader.onload = (e) => {
      const img = new Image()
      img.onload = () => {
        currentImage.value = img
        processCanvas(img)
        saveToLocalStorage(e.target.result)
      }
      img.src = e.target.result
    }
    reader.readAsDataURL(file)
  }
}

/*function processImage() {
  if (imageInput.value.files.length === 0) {
    alert('Please select an image first')
    return
  }
  handleFile()
}*/

function updatePixelation() {
  if (currentImage.value) {
    processCanvas(currentImage.value)
    saveSettingsToLocalStorage()
  }
}

function processCanvas(img) {
  const pxSize = parseInt(pixelSize.value)
  const targetWidth = img.width * 2
  const targetHeight = img.height
  
  canvas.value.width = targetWidth
  canvas.value.height = targetHeight

  const ctx = canvas.value.getContext('2d')
  ctx.drawImage(img, 0, 0, targetWidth, targetHeight)

  const data = ctx.getImageData(0, 0, targetWidth, targetHeight).data

  const cols = Math.ceil(targetWidth / pxSize)
  const rows = Math.ceil(targetHeight / pxSize)
  pixelRows.value = []

  for (let i = 0; i < rows; i++) {
    checkedRows[i] = false
  }

  for (let y = 0; y < rows; y++) {
    const pixels = []
    for (let x = 0; x < cols; x++) {
      const avg = getAverageColor(data, targetWidth, x * pxSize, y * pxSize, pxSize)
      pixels.push({
        color: `rgba(${avg.r}, ${avg.g}, ${avg.b}, ${avg.a})`
      })
    }
    pixelRows.value.push({
      pixels,
      rowOpacity: 1
    })
  }
}

function toggleRowOpacity(rowIndex) {
  pixelRows.value[rowIndex].rowOpacity = checkedRows[rowIndex] ? 0.5 : 1
}

function getAverageColor(data, width, startX, startY, blockSize) {
  let r = 0, g = 0, b = 0, a = 0, count = 0

  for (let y = startY; y < startY + blockSize; y++) {
    for (let x = startX; x < startX + blockSize; x++) {
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
  if (!saved) return

  const img = new Image()
  img.onload = () => {
    currentImage.value = img
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

function clearSaved() {
  pixelRows.value = []
  imageInput.value.value = ''
  currentImage.value = null
  localStorage.removeItem('pixelatedImage')
  localStorage.removeItem('pixelatorSettings')
}


/*az értékelésre valami confetti (csak jó értékelésnél) meg felugró üzenet */
</script>

<template>
  <main>

    <h1 class="title">Mintakészítő</h1>

    
    <div id="bemutato">
      <h2 class="title" style="color:black; border-bottom: none;">Mi is ez az oldal?</h2>
      <p>Lorem ipsum dolor sit amet consectetur adipisicing elit. Harum, consequuntur natus sed eius minima ipsa ipsum nesciunt perferendis iure repellat ducimus, nemo facilis doloremque consectetur accusantium nisi, vel quibusdam. Distinctio.</p>
      <ul>
        <li>Horgolás</li>
        <li>Kötés</li>
        <li>Hímzés</li>
      </ul>
      <p>Lorem ipsum dolor, sit amet consectetur adipisicing elit. Rerum quod, blanditiis nostrum deserunt quas possimus saepe tempora earum consequuntur doloribus debitis voluptatibus atque totam accusamus aut. Vero modi quod vitae!</p>
    </div>

    <div class="grid">
        <div class="kartya">
          <h3>Horgolás</h3>
          <p>Lorem ipsum, dolor sit amet consectetur adipisicing elit. Ut ipsum exercitationem fugit dolores facere totam? Ex sit deserunt laudantium ab quasi iure consequuntur, repellendus et dicta sapiente explicabo dolorum! Sunt.</p>
        </div>
        <div class="kartya">
          <h3>Kötés</h3>
          <p>Lorem ipsum dolor sit amet consectetur adipisicing elit. Suscipit asperiores minima perferendis officiis aliquam quis facilis fuga eum doloremque ipsam, nostrum, dolorem dicta quidem eaque veniam quisquam, a molestiae quibusdam!</p>
        </div>
        <div class="kartya">
          <h3>Hímzés</h3>
          <p>Lorem, ipsum dolor sit amet consectetur adipisicing elit. Soluta, aliquam dolores. Fugiat, dolorum! Earum sint quae laudantium ea consectetur ducimus placeat ab, ipsum incidunt veniam ullam soluta hic excepturi illum.</p>
        </div>
    </div>

    <div class="controlok"> <!--kicserélni szinte teljesen: a fájlfeltöltő marad, a többi teljesen jobb lesz-->
      <div class="fajlFeltolto">
        <div class="konténer">
          <div class="feltolto">
            <div class="elsoOldal">
              <div class="tip"></div>
              <div class="cover"></div>
            </div>
            <div class="hatsoOldal cover"></div>
          </div>

          <label class="custom-file-upload">
            <input type="file" ref="imageInput" @change="handleFile" accept="image/*" />
            Válassz képet
          </label>
        </div>
      </div>

      <!--Kontrolok-->
      <div class="sliders">
        <div class="slider-group">
          <label>Pixel Size:</label>
          <input type="range" min="5" max="40" v-model="pixelSize" @input="updatePixelation" id="pixel"/>
          <span>{{ pixelSize }}</span>
        </div>

        <div class="slider-group">
          <label>Grid Opacity:</label>
          <input type="range" min="0" max="60" v-model="gridOpacity" @input="updatePixelation" id="grid"/>
          <span>{{ gridOpacity }}%</span>
        </div>
      </div>

      <div class="buttons">
        <button @click="clearSaved">Clear Image</button>
      </div>
    </div>

    <canvas ref="canvas" style="display: none;"></canvas>

    <div class="pixel-grid-container">
      <div class="pixel-container">
        <div
          v-for="(row, rowIndex) in pixelRows"
          :key="rowIndex"
          class="pixel-row"
          :style="{ opacity: row.rowOpacity }">
          <div
            v-for="(pixel, pixelIndex) in row.pixels"
            :key="pixelIndex"
            class="pixel"
            :style="{
              width: pixelSize + 'px',
              height: pixelSize + 'px',
              backgroundColor: pixel.color,
              borderColor: `rgba(0, 0, 0, ${gridOpacity / 100})`,}">
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
    <!--Idáig cserélni-->
  

    <div class="ertekeles">
      <input type="radio" id="star-1" name="star-radio" value="star-1">
      <label for="star-1">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path pathLength="360" d="M12,17.27L18.18,21L16.54,13.97L22,9.24L14.81,8.62L12,2L9.19,8.62L2,9.24L7.45,13.97L5.82,21L12,17.27Z"></path></svg>
      </label>
      <input type="radio" id="star-2" name="star-radio" value="star-1">
      <label for="star-2">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path pathLength="360" d="M12,17.27L18.18,21L16.54,13.97L22,9.24L14.81,8.62L12,2L9.19,8.62L2,9.24L7.45,13.97L5.82,21L12,17.27Z"></path></svg>
      </label>
      <input type="radio" id="star-3" name="star-radio" value="star-1">
      <label for="star-3">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path pathLength="360" d="M12,17.27L18.18,21L16.54,13.97L22,9.24L14.81,8.62L12,2L9.19,8.62L2,9.24L7.45,13.97L5.82,21L12,17.27Z"></path></svg>
      </label>
      <input type="radio" id="star-4" name="star-radio" value="star-1">
      <label for="star-4">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path pathLength="360" d="M12,17.27L18.18,21L16.54,13.97L22,9.24L14.81,8.62L12,2L9.19,8.62L2,9.24L7.45,13.97L5.82,21L12,17.27Z"></path></svg>
      </label>
      <input type="radio" id="star-5" name="star-radio" value="star-1">
      <label for="star-5">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path pathLength="360" d="M12,17.27L18.18,21L16.54,13.97L22,9.24L14.81,8.62L12,2L9.19,8.62L2,9.24L7.45,13.97L5.82,21L12,17.27Z"></path></svg>
      </label>
    </div>
  </main>
</template>


<style scoped>
/* a színek placeholderesek*/
  main {
    margin: 87px auto 0 auto;
    background-color: rgb(241, 228, 212);
    padding: 20px;
    height: auto;
  }

  .title {
    text-align: center;
    margin-bottom: 30px;
  }

  #bemutato {
    background-color: #f3c78e;
    max-width: 1200px;
    margin: auto;
    padding: 10px 50px 10px 50px;
    text-align: justify;
    margin-bottom: 50px;
    border-radius: 10px;
    box-shadow: rgba(50, 50, 93, 0.25) 0px 2px 5px -1px, rgba(0, 0, 0, 0.3) 0px 1px 3px -1px;
  }

  /*3 oszlop - még nem reszponzív */
  .grid {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    gap: 50px;
    margin-bottom: 50px;
  }

  .grid {
    padding:1rem;
  }

  .kartya {
    background-color: rgb(243, 199, 142);
    text-align: justify;
    padding: 20px;
    border-radius: 10px;
    box-shadow: rgba(50, 50, 93, 0.25) 0px 2px 5px -1px, rgba(0, 0, 0, 0.3) 0px 1px 3px -1px;
    /* vagy innen valami: https://getcssscan.com/css-box-shadow-examples */
  }  

    .ertekeles {
    display: flex;
    flex-direction: row-reverse;
    gap: 0.3rem;
    --stroke: #666;
    --fill: #ffc73a;
    justify-content: center;
    margin-top: 50px;
  }

  .ertekeles input {
    appearance: unset;
  }

  .ertekeles label {
    cursor: pointer;
  }

  .ertekeles svg {
    width: 2rem;
    height: 2rem;
    overflow: visible;
    fill: transparent;
    stroke: var(--stroke);
    stroke-linejoin: bevel;
    stroke-dasharray: 12;
    animation: idle 4s linear infinite;
    transition: stroke 0.2s, fill 0.5s;
  }

  @keyframes idle {
    from {
      stroke-dashoffset: 24;
    }
  }

  .ertekeles label:hover svg {
    stroke: var(--fill);
  }

  .ertekeles input:checked ~ label svg {
    transition: 0s;
    animation: idle 4s linear infinite, yippee 0.75s backwards;
    fill: var(--fill);
    stroke: var(--fill);
    stroke-opacity: 0;
    stroke-dasharray: 0;
    stroke-linejoin: miter;
    stroke-width: 8px;
  }

  @keyframes yippee {
    0% {
      transform: scale(1);
      fill: var(--fill);
      fill-opacity: 0;
      stroke-opacity: 1;
      stroke: var(--stroke);
      stroke-dasharray: 10;
      stroke-width: 1px;
      stroke-linejoin: bevel;
    }

    30% {
      transform: scale(0);
      fill: var(--fill);
      fill-opacity: 0;
      stroke-opacity: 1;
      stroke: var(--stroke);
      stroke-dasharray: 10;
      stroke-width: 1px;
      stroke-linejoin: bevel;
    }

    30.1% {
      stroke: var(--fill);
      stroke-dasharray: 0;
      stroke-linejoin: miter;
      stroke-width: 8px;
    }

    60% {
      transform: scale(1.2);
      fill: var(--fill);
    }
  }



/*rendbe kéne tenni hogy pontosan mi micsoda */
.controlok {
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
  margin-bottom: 30px;
  align-items: center;
  justify-content: center;
}

.fajlFeltolto { /*a navbar fölé megy - meg kell oldani */
  display: flex;
  flex-direction: column;
  align-items: center;
}

.sliders {
  display: flex;
  flex-direction: column;
  gap: 15px;
  min-width: 250px;
}

.slider-group {
  display: flex;
  align-items: center;
  gap: 10px;
}

.slider-group label {
  min-width: 80px;
}

.buttons {
  display: flex;
  gap: 10px;
}

button {
  padding: 8px 16px;
  background-color: #b33626;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  transition: background-color 0.3s;
}

button:hover {
  background-color: #45a049;
}

.pixel-grid-container {
  margin-top: 20px;
  overflow: auto;
  max-height: 70vh;
  border: 1px solid #ddd;
  padding: 10px;
  background-color: #f9f9f9;
}

.pixel-container {
  display: flex;
  flex-direction: column;
  width: fit-content;
}

.pixel-row {
  display: flex;
  align-items: center;
  margin-bottom: 5px;
}

.pixel {
  border: 1px solid rgba(0, 0, 0, 0.1);
  box-sizing: border-box;
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

/* feltolto styling */
.konténer {
  --transition: 350ms;
  --feltolto-W: 120px;
  --feltolto-H: 80px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: flex-end;
  padding: 10px;
  background: linear-gradient(135deg, #fabbbb, #824242);
  border-radius: 15px;
  box-shadow: 0 15px 30px rgba(0, 0, 0, 0.2);
  height: calc(var(--feltolto-H) * 1.7);
  position: relative;
  width: 200px;
  margin-bottom: 20px;
}

.feltolto {
  position: absolute;
  top: 20px;
  left: calc(50% - 60px);
  animation: float 2.5s infinite ease-in-out;
  transition: transform var(--transition) ease;
}

.feltolto:hover {
  transform: scale(1.05);
}

.feltolto .elsoOldal,
.feltolto .hatsoOldal {
  position: absolute;
  transition: transform var(--transition);
  transform-origin: bottom center;
}

.feltolto .hatsoOldal::before,
.feltolto .hatsoOldal::after {
  content: "";
  display: block;
  background-color: white;
  opacity: 0.5;
  z-index: 0;
  width: var(--feltolto-W);
  height: var(--feltolto-H);
  position: absolute;
  transform-origin: bottom center;
  border-radius: 15px;
  transition: transform 350ms;
  z-index: 0;
}

.konténer:hover .hatsoOldal::before {
  transform: rotateX(-5deg) skewX(5deg);
}
.konténer:hover .hatsoOldal::after {
  transform: rotateX(-15deg) skewX(12deg);
}

.feltolto .elsoOldal {
  z-index: 1;
}

.konténer:hover .elsoOldal {
  transform: rotateX(-40deg) skewX(15deg);
}

.feltolto .tip {
  background: linear-gradient(135deg, #ff9a56, #ff6f56);
  width: 80px;
  height: 20px;
  border-radius: 12px 12px 0 0;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
  position: absolute;
  top: -10px;
  z-index: 2;
}

.feltolto .cover {
  background: linear-gradient(135deg, #ffe563, #ffc663);
  width: var(--feltolto-W);
  height: var(--feltolto-H);
  box-shadow: 0 15px 30px rgba(0, 0, 0, 0.3);
  border-radius: 10px;
}

.custom-file-upload {
  font-size: 1.1em;
  color: #ffffff;
  text-align: center;
  background: rgba(255, 255, 255, 0.2);
  border: none;
  border-radius: 10px;
  box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
  cursor: pointer;
  transition: background var(--transition) ease;
  display: inline-block;
  width: 60%;
  padding: 10px 35px;
  position: relative;
}

.custom-file-upload:hover {
  background: rgba(255, 255, 255, 0.4);
}

.custom-file-upload input[type="file"] {
  display: none;
}

/*idáig a mintakészítő eddigi css-e */
</style>