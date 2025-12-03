<script setup>
import { ref, reactive, onMounted, nextTick, computed } from "vue"

// Adat bekérés változók
const resz = ref(1)
const elsoLepes = ref(null)
const masodikLepes = ref(null)
const file = ref(null)
const pixelesKep = ref(false)
const kepUrl = ref(null)
const aktualisKep = ref(null)
const betoltottKep = ref(false)

const tipusok = ["Horgolás", "Kötés", "Hímzés"]
//const fonalak = [" 'A' fonal csoport", " 'B' fonal csoport", " 'C' fonal csoport", " 'D' fonal csoport", " 'E' fonal csoport"]
const fonalak = [
  {
    fonalTipus: "A fonal csoport",
    meromintaSor: 33,
    meromintaOszlop: 40
  },
  {
    fonalTipus: "B fonal csoport",
    meromintaSor: 27,
    meromintaOszlop: 32
  },
  {
    fonalTipus: "C fonal csoport",
    meromintaSor: 23,
    meromintaOszlop: 26
  },
  {
    fonalTipus: "D fonal csoport",
    meromintaSor: 21,
    meromintaOszlop: 24
  },
  {
    fonalTipus: "E fonal csoport",
    meromintaSor: 12,
    meromintaOszlop: 15
  }
]

// Adatok feldolgozása
function kovetkezoResz() {
  if (resz.value === 1 && elsoLepes.value === "Hímzés") {
    masodikLepes.value = fonalak.find(f => f.fonalTipus === "A fonal csoport")
    resz.value = 3
    betoltesKorabbrol()
    return
  }
  resz.value++
  betoltesKorabbrol()
}

function modositas(target) {
  resz.value = target
  betoltesKorabbrol()
}

function kepfeltoltes(event) {
  const feltoltottFajl = event.target.files[0]
  if (feltoltottFajl) {
    file.value = feltoltottFajl
    const reader = new FileReader()
    reader.onload = (e) => {
      kepUrl.value = e.target.result
      
      const img = new Image()
      img.onload = () => {
        aktualisKep.value = img
        betoltottKep.value = true
        // Process immediately when image loads
        if (pixelesKep.value) {
          nextTick(() => {
            canvasFeldolgozas(img)
          })
        }
        localStorageMentes(kepUrl.value)
      }
      img.src = kepUrl.value
    }
    reader.readAsDataURL(feltoltottFajl)
  }
}

function toMintavaltoztato() {
 if (file.value) {
    pixelesKep.value = true
    betoltesKorabbrol()
    // Wait for the view to render and then process the image
    // Wait for DOM update and ensure canvas is ready
    nextTick(() => {
      setTimeout(() => {
        if (aktualisKep.value && betoltottKep.value && canvas.value) {
          canvasFeldolgozas(aktualisKep.value)
        } else {
          elozoKep()
        }
      }, 100)
    })
  }
}

// Pixelesítés változók
const pixelMeret = ref(15)
const racsLathatosag = ref(20)
const szinSzam = ref(5)
const canvas = ref(null)
const pixelSorok = ref([])
const pipaltSorok = reactive({})
const szinPaletta = ref([])
const kivalasztottSzinIndex = ref(null)
const szinValtoztatasModal = ref(false)
const ujSzin = ref('#000000')


function automatikusSzinCsoportositas(pixelAdatok = null) {
  if (pixelSorok.value.length === 0) return
  
  const szinGyakorisag = {}
  
  // Count color frequency from current pixel data
  pixelSorok.value.forEach(row => {
    row.pixels.forEach(pixel => {
      const color = pixel.color
      szinGyakorisag[color] = (szinGyakorisag[color] || 0) + 1
    })
  })
  
  // Sort colors by frequency and take the most frequent ones
  const leggyakoribbSzinek = Object.entries(szinGyakorisag)
    .sort(([,a], [,b]) => b - a)
    .slice(0, szinSzam.value)
    .map(([color]) => color)
  
  // Update palette with most frequent colors
  szinPaletta.value = leggyakoribbSzinek.map((color, index) => ({
    id: index,
    eredeti: color,
    jelenlegi: color,
    hasznalva: true
  }))
  
  // Update all pixels to use the new limited palette
  pixelSorok.value.forEach(row => {
    row.pixels.forEach(pixel => {
      // Find the closest color in the new limited palette
      pixel.color = legkozelebbiSzinKereses(pixel.color, szinPaletta.value)
    })
  })
}

// Pixelation functions from tapestry.vue (fixed version)
function canvasFeldolgozas(img) {
  if (!canvas.value || !canvas.value.getContext) {
    setTimeout(() => {
      if (canvas.value && aktualisKep.value) {
        canvasFeldolgozas(aktualisKep.value)
      }
    }, 100)
    return
  }

  // Now we know canvas is ready, proceed with the actual processing
  processImageWithColors(img)
}

function processImageWithColors(img) {
  const pxMeret = parseInt(pixelMeret.value)
  
  // Use original image dimensions
  const szelesseg = img.width
  const magassag = img.height
  
  canvas.value.width = szelesseg
  canvas.value.height = magassag

  const ctx = canvas.value.getContext('2d', { willReadFrequently: true })
  ctx.drawImage(img, 0, 0, szelesseg, magassag)

  const imageData = ctx.getImageData(0, 0, szelesseg, magassag)
  const data = imageData.data

  const cols = Math.ceil(szelesseg / pxMeret)
  const rows = Math.ceil(magassag / pxMeret)
  
  pixelSorok.value = []

  // Initialize checked rows
  for (let i = 0; i < rows; i++) {
    if (pipaltSorok[i] === undefined) {
      pipaltSorok[i] = false
    }
  }

  // First pass: collect all pixel colors
  const szinGyakorisag = {}
  const atmenetiPixelAdatok = []

  for (let y = 0; y < rows; y++) {
    const pixels = []
    for (let x = 0; x < cols; x++) {
      const avg = osszevontSzin(data, szelesseg, magassag, x * pxMeret, y * pxMeret, pxMeret)
      const color = `rgba(${avg.r}, ${avg.g}, ${avg.b}, ${avg.a})`
      szinGyakorisag[color] = (szinGyakorisag[color] || 0) + 1
      pixels.push({
        originalColor: color,
        color: color
      })
    }
    atmenetiPixelAdatok.push({ pixels })
  }

  // Create limited palette based on szinSzam
  const leggyakoribbSzinek = Object.entries(szinGyakorisag)
    .sort(([,a], [,b]) => b - a)
    .slice(0, szinSzam.value)
    .map(([color]) => color)
  
  // Update palette
  szinPaletta.value = leggyakoribbSzinek.map((color, index) => ({
    id: index,
    eredeti: color,
    jelenlegi: color,
    hasznalva: true
  }))

  // Second pass: apply color limitation using the palette
  for (let y = 0; y < rows; y++) {
    const pixels = []
    for (let x = 0; x < cols; x++) {
      const originalColor = atmenetiPixelAdatok[y].pixels[x].originalColor
      
      // Find the closest color in our limited palette
      const legkozelebbiSzin = legkozelebbiSzinKereses(originalColor, szinPaletta.value)
      
      pixels.push({
        color: legkozelebbiSzin
      })
    }
    pixelSorok.value.push({
      pixels,
      sorLathatosag: pipaltSorok[y] ? 0.5 : 1
    })
  }
}

// Add this function for finding closest color
function legkozelebbiSzinKereses(color, palette) {
    if (palette.length === 0) return color
  
  const [r1, g1, b1] = color.match(/\d+/g).map(Number)
  
  let legkozelebbiIndex = 0
  let legkisebbTavolsag = Infinity
  
  palette.forEach((szinObj, index) => {
    const [r2, g2, b2] = szinObj.jelenlegi.match(/\d+/g).map(Number)
    
    // Improved color distance calculation using Delta E (perceptual difference)
    const tavolsag = szinTavolsag(r1, g1, b1, r2, g2, b2)
    
    if (tavolsag < legkisebbTavolsag) {
      legkisebbTavolsag = tavolsag
      legkozelebbiIndex = index
    }
  })
  
  return palette[legkozelebbiIndex].jelenlegi
}

// Improved color distance calculation
function szinTavolsag(r1, g1, b1, r2, g2, b2) {
  // Convert RGB to Lab for better perceptual difference
  const lab1 = rgbToLab(r1, g1, b1)
  const lab2 = rgbToLab(r2, g2, b2)
  
  // Delta E 2000 formula (complex but very accurate)
  return deltaE00(lab1, lab2)
  
  // Simpler alternative: weighted Euclidean distance
  // return Math.sqrt(
  //   Math.pow((r1 - r2) * 0.3, 2) +
  //   Math.pow((g1 - g2) * 0.59, 2) + 
  //   Math.pow((b1 - b2) * 0.11, 2)
  // )
}

// RGB to Lab conversion helpers
function rgbToLab(r, g, b) {
  // First convert RGB to XYZ
  let rn = r / 255
  let gn = g / 255
  let bn = b / 255
  
  rn = rn > 0.04045 ? Math.pow((rn + 0.055) / 1.055, 2.4) : rn / 12.92
  gn = gn > 0.04045 ? Math.pow((gn + 0.055) / 1.055, 2.4) : gn / 12.92
  bn = bn > 0.04045 ? Math.pow((bn + 0.055) / 1.055, 2.4) : bn / 12.92
  
  rn *= 100
  gn *= 100
  bn *= 100
  
  const x = rn * 0.4124 + gn * 0.3576 + bn * 0.1805
  const y = rn * 0.2126 + gn * 0.7152 + bn * 0.0722
  const z = rn * 0.0193 + gn * 0.1192 + bn * 0.9505
  
  // Then convert XYZ to Lab
  const xn = 95.047
  const yn = 100.0
  const zn = 108.883
  
  const xr = x / xn
  const yr = y / yn
  const zr = z / zn
  
  const fx = xr > 0.008856 ? Math.pow(xr, 1/3) : (7.787 * xr) + 16/116
  const fy = yr > 0.008856 ? Math.pow(yr, 1/3) : (7.787 * yr) + 16/116
  const fz = zr > 0.008856 ? Math.pow(zr, 1/3) : (7.787 * zr) + 16/116
  
  return {
    l: (116 * fy) - 16,
    a: 500 * (fx - fy),
    b: 200 * (fy - fz)
  }
}

// Delta E 2000 calculation
function deltaE00(lab1, lab2) {
  const L1 = lab1.l, a1 = lab1.a, b1 = lab1.b
  const L2 = lab2.l, a2 = lab2.a, b2 = lab2.b
  
  const kL = 1, kC = 1, kH = 1
  
  const C1 = Math.sqrt(a1 * a1 + b1 * b1)
  const C2 = Math.sqrt(a2 * a2 + b2 * b2)
  
  const aC = (C1 + C2) / 2
  const aC7 = Math.pow(aC, 7)
  const G = 0.5 * (1 - Math.sqrt(aC7 / (aC7 + 6103515625))) // 25^7
  
  const a1p = a1 * (1 + G)
  const a2p = a2 * (1 + G)
  
  const C1p = Math.sqrt(a1p * a1p + b1 * b1)
  const C2p = Math.sqrt(a2p * a2p + b2 * b2)
  
  const h1p = Math.atan2(b1, a1p) * 180 / Math.PI
  const h2p = Math.atan2(b2, a2p) * 180 / Math.PI
  
  const dLp = L2 - L1
  const dCp = C2p - C1p
  
  let dhp = h2p - h1p
  if (dhp > 180) dhp -= 360
  else if (dhp < -180) dhp += 360
  
  const dHp = 2 * Math.sqrt(C1p * C2p) * Math.sin(dhp * Math.PI / 360)
  
  const aL = (L1 + L2) / 2
  const aCp = (C1p + C2p) / 2
  
  let aHp = (h1p + h2p) / 2
  if (Math.abs(h1p - h2p) > 180) {
    aHp += 180
  }
  
  const T = 1 - 0.17 * Math.cos((aHp - 30) * Math.PI / 180) +
              0.24 * Math.cos(2 * aHp * Math.PI / 180) +
              0.32 * Math.cos((3 * aHp + 6) * Math.PI / 180) -
              0.20 * Math.cos((4 * aHp - 63) * Math.PI / 180)
  
  const dRo = 30 * Math.exp(-Math.pow((aHp - 275) / 25, 2))
  const RC = 2 * Math.sqrt(Math.pow(aCp, 7) / (Math.pow(aCp, 7) + 6103515625)) // 25^7
  const SL = 1 + (0.015 * Math.pow(aL - 50, 2)) / Math.sqrt(20 + Math.pow(aL - 50, 2))
  const SC = 1 + 0.045 * aCp
  const SH = 1 + 0.015 * aCp * T
  const RT = -Math.sin(2 * dRo * Math.PI / 180) * RC
  
  return Math.sqrt(
    Math.pow(dLp / (kL * SL), 2) +
    Math.pow(dCp / (kC * SC), 2) +
    Math.pow(dHp / (kH * SH), 2) +
    RT * (dCp / (kC * SC)) * (dHp / (kH * SH))
  )
}

function osszevontSzin(data, width, height, startX, startY, blockSize) {
  let r = 0, g = 0, b = 0, a = 0, count = 0
  
  // Different sampling strategies for better accuracy
  const pixels = []
  
  for (let y = startY; y < startY + blockSize && y < height; y++) {
    for (let x = startX; x < startX + blockSize && x < width; x++) {
      const i = (y * width + x) * 4
      if (i >= data.length - 3) continue

      const pixelR = data[i]
      const pixelG = data[i + 1]
      const pixelB = data[i + 2]
      const pixelA = data[i + 3]
      
      pixels.push({ r: pixelR, g: pixelG, b: pixelB, a: pixelA })
      
      r += pixelR
      g += pixelG
      b += pixelB
      a += pixelA
      count++
    }
  }

  if (count === 0) {
    return { r: 0, g: 0, b: 0, a: 0 }
  }

  // Strategy 1: Simple average (current method)
  const averageColor = {
    r: Math.round(r / count),
    g: Math.round(g / count),
    b: Math.round(b / count),
    a: a / count / 255
  }

  // Strategy 2: Median color (reduces outlier influence)
  const medianColor = getMedianColor(pixels)
  
  // Strategy 3: Dominant color (most frequent color in the block)
  const dominantColor = getDominantColor(pixels)
  
  // Strategy 4: Weighted average based on luminance (human perception)
  const perceptualColor = getPerceptualColor(pixels)
  
  // You can choose which strategy to use:
  // return averageColor; // Simple but fast
  // return medianColor; // Better for images with noise
  return dominantColor; // Best for preserving important colors
  // return perceptualColor; // Most accurate for human vision
}

// Helper function to get median color (reduces outlier influence)
function getMedianColor(pixels) {
  if (pixels.length === 0) return { r: 0, g: 0, b: 0, a: 1 }
  
  const rValues = pixels.map(p => p.r).sort((a, b) => a - b)
  const gValues = pixels.map(p => p.g).sort((a, b) => a - b)
  const bValues = pixels.map(p => p.b).sort((a, b) => a - b)
  
  const mid = Math.floor(pixels.length / 2)
  
  return {
    r: pixels.length % 2 === 0 ? Math.round((rValues[mid - 1] + rValues[mid]) / 2) : rValues[mid],
    g: pixels.length % 2 === 0 ? Math.round((gValues[mid - 1] + gValues[mid]) / 2) : gValues[mid],
    b: pixels.length % 2 === 0 ? Math.round((bValues[mid - 1] + bValues[mid]) / 2) : bValues[mid],
    a: 1
  }
}

// Helper function to get dominant color (most frequent)
function getDominantColor(pixels) {
  if (pixels.length === 0) return { r: 0, g: 0, b: 0, a: 1 }
  
  const colorMap = new Map()
  const tolerance = 10 // Color grouping tolerance
  
  pixels.forEach(pixel => {
    // Quantize colors to reduce noise
    const quantizedR = Math.round(pixel.r / tolerance) * tolerance
    const quantizedG = Math.round(pixel.g / tolerance) * tolerance
    const quantizedB = Math.round(pixel.b / tolerance) * tolerance
    const key = `${quantizedR},${quantizedG},${quantizedB}`
    
    colorMap.set(key, (colorMap.get(key) || 0) + 1)
  })
  
  // Find the most frequent color
  let maxCount = 0
  let dominantKey = ''
  
  colorMap.forEach((count, key) => {
    if (count > maxCount) {
      maxCount = count
      dominantKey = key
    }
  })
  
  const [r, g, b] = dominantKey.split(',').map(Number)
  
  return { r, g, b, a: 1 }
}

// Helper function for perceptual color (weighted by luminance)
function getPerceptualColor(pixels) {
  if (pixels.length === 0) return { r: 0, g: 0, b: 0, a: 1 }
  
  let r = 0, g = 0, b = 0, totalWeight = 0
  
  pixels.forEach(pixel => {
    // Calculate luminance (human perception weights)
    const luminance = 0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b
    const weight = luminance / 255 // Normalize weight
    
    r += pixel.r * weight
    g += pixel.g * weight
    b += pixel.b * weight
    totalWeight += weight
  })
  
  return {
    r: Math.round(r / totalWeight),
    g: Math.round(g / totalWeight),
    b: Math.round(b / totalWeight),
    a: 1
  }
}

function sorLathatosagValtas(rowIndex) {
  pixelSorok.value[rowIndex].sorLathatosag = pipaltSorok[rowIndex] ? 0.5 : 1
}

function szinValasztas(index) {
  kivalasztottSzinIndex.value = index
  ujSzin.value = rgbToHex(szinPaletta.value[index].jelenlegi)
  szinValtoztatasModal.value = true
}

function szinFrissites() {
   if (kivalasztottSzinIndex.value === null) return
    
    const regiSzin = szinPaletta.value[kivalasztottSzinIndex.value].jelenlegi
    const ujSzinErtek = ujSzin.value
    const ujSzinRgb = hexToRgb(ujSzinErtek)
    
    // Update the color in palette
    szinPaletta.value[kivalasztottSzinIndex.value].jelenlegi = ujSzinRgb
    
    // Update all pixels that exactly match the old palette color
    pixelSorok.value.forEach(row => {
        row.pixels.forEach(pixel => {
            if (pixel.color === regiSzin) {
                pixel.color = ujSzinRgb
            }
        })
    })
    
    szinValtoztatasModal.value = false
    kivalasztottSzinIndex.value = null
}

// Helper functions for color conversion
function rgbToHex(rgb) {
   // Convert rgba(r, g, b, a) to hex
    const match = rgb.match(/rgba?\((\d+),\s*(\d+),\s*(\d+)(?:,\s*([\d.]+))?\)/)
    if (!match) return '#000000'
    
    const r = parseInt(match[1])
    const g = parseInt(match[2])
    const b = parseInt(match[3])
    
    // Convert to hex and ensure 2 digits
    const toHex = (num) => {
        const hex = num.toString(16)
        return hex.length === 1 ? '0' + hex : hex
    }
    
    return "#" + toHex(r) + toHex(g) + toHex(b)
}

function hexToRgb(hex) {
  // Convert hex to rgba
    const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex)
    if (!result) return 'rgba(0, 0, 0, 1)'
    
    return `rgba(${parseInt(result[1], 16)}, ${parseInt(result[2], 16)}, ${parseInt(result[3], 16)}, 1)`
}

// new helper: return true when color is dark
function isDarkColor(rgba) {
  const m = rgba.match(/rgba?\((\d+),\s*(\d+),\s*(\d+)/i)
  if (!m) return false
  const r = Number(m[1]), g = Number(m[2]), b = Number(m[3])
  const srgb = [r, g, b].map(v => {
    v = v / 255
    return v <= 0.03928 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4)
  })
  const lum = 0.2126 * srgb[0] + 0.7152 * srgb[1] + 0.0722 * srgb[2]
  return lum < 0.5
}




function mintaFrissites() {
    if (aktualisKep.value) {
        canvasFeldolgozas(aktualisKep.value)
        adatokLocalStorage()
    }
}

// Watch for color number changes and update palette
watch(szinSzam, (newVal) => {
if (aktualisKep.value && pixelSorok.value.length > 0) {
    // Use the new function to update colors without reprocessing the entire image
    nextTick(() => {
      automatikusSzinCsoportositas()
    })
  }
})

function localStorageMentes(imageData) {
  localStorage.setItem('pixelesKep', imageData)
  adatokLocalStorage()
}

function adatokLocalStorage() {
    localStorage.setItem('pixelesValtoztatasok', JSON.stringify({
        pixelMeret: pixelMeret.value,
        racsLathatosag: racsLathatosag.value,
        szinSzam: szinSzam.value
    }))
}

function elozoKep() {
  const saved = localStorage.getItem('pixelesKep')
    if (!saved) {
        return
    }

    const img = new Image()
    img.onload = () => {
        aktualisKep.value = img
        betoltottKep.value = true
        // Wait for next tick to ensure canvas is mounted
        nextTick(() => {
            if (pixelesKep.value && canvas.value) {
                canvasFeldolgozas(img)
            }
        })
    }
    img.src = saved

    const settings = localStorage.getItem('pixelesValtoztatasok')
    if (settings) {
        const parsed = JSON.parse(settings)
        pixelMeret.value = parseInt(parsed.pixelMeret) || 15
        racsLathatosag.value = parseInt(parsed.racsLathatosag) || 20
        szinSzam.value = parseInt(parsed.szinSzam) || 5
    }
}

function kepTorles() {
  pixelSorok.value = []
  file.value = null
  kepUrl.value = null
  aktualisKep.value = null
  betoltottKep.value = false
  localStorage.removeItem('pixelesKep')
  localStorage.removeItem('pixelesValtoztatasok')
  localStorage.removeItem('mintakeszitoForm')
  
  // Reset file input
  const fileInput = document.getElementById('file-upload')
  if (fileInput) fileInput.value = ''
}

function adatokVissza() {
  pixelesKep.value = false
  betoltesKorabbrol()
}

function kepletoltes(canvas, filename = 'modified-image.png') {
  if (!canvas.value) return
  
  /*const link = document.createElement('a')
  link.download = 'minta.png'
  link.href = canvas.value.toDataURL()
  link.click()*/

    // Convert canvas to blob
  canvas.toBlob((blob) => {
    // Create a temporary download link
    const link = document.createElement('a');
    link.download = filename;
    link.href = URL.createObjectURL(blob);
    
    link.click();
  })
}

function visszaallitas() {
if (aktualisKep.value) {
        canvasFeldolgozas(aktualisKep.value)
        // Reset all checkboxes
        Object.keys(pipaltSorok).forEach(key => {
            pipaltSorok[key] = false
        })
        // Reset row opacities
        pixelSorok.value.forEach((row, index) => {
            row.sorLathatosag = 1
        })
    }
}

// Watch for when pixelation view becomes active and process image
import { watch } from 'vue'

watch(pixelesKep, (newVal) => {
  if (newVal && aktualisKep.value && betoltottKep.value) {
    nextTick(() => {
      // Add a small delay to ensure DOM is fully updated
      setTimeout(() => {
        if (canvas.value) {
          canvasFeldolgozas(aktualisKep.value)
        }
      }, 50)
    })
  }
})

// Initialize when component mounts
onMounted(() => {
  // Load form state first
  formBetoltes()
  // Then check for saved image when component mounts
  elozoKep()
})

// Add computed property for yarn length calculation
const fonalHossz = computed(() => {
  const pixelRacsSor = pixelSorok.value.length
  const pixelRacsOszlop = pixelSorok.value[0]?.pixels.length || 0
  
  const hossz = ((pixelRacsSor * pixelRacsOszlop) / 
                (masodikLepes.value.meromintaSor * masodikLepes.value.meromintaOszlop)) * 100
  
  
  return isNaN(hossz) ? 0 : Number(hossz.toFixed(1))
})

// Add watch to recalculate yarn length when pixel grid changes
watch([pixelMeret, pixelSorok], () => {
  // This will trigger the computed property to recalculate
}, { deep: true })

// Add these functions to save/restore form state
function betoltesKorabbrol() {
  const formState = {
    resz: resz.value,
    elsoLepes: elsoLepes.value,
    masodikLepes: masodikLepes.value,
    pixelesKep: pixelesKep.value
  }
  localStorage.setItem('mintakeszitoForm', JSON.stringify(formState))
}

function formBetoltes() {
  const saved = localStorage.getItem('mintakeszitoForm')
  if (saved) {
    const formState = JSON.parse(saved)
    resz.value = formState.resz || 1
    elsoLepes.value = formState.elsoLepes || null
    masodikLepes.value = formState.masodikLepes || null
    pixelesKep.value = formState.pixelesKep || false
  }
}
</script>

<template>
  <main>
    <h1 class="title">Mintakészítő</h1>
    
    <!-- Felső sávos szövegbobozok-->
    <div id="bemutato">
      <div class="ket-oszlop">
        <div class="blog-info-kontener">
          <img src="../assets/public/mk-kep.jpg" alt="">
          <div class="blog-info">
            <h3>Mi is ez pontosan?</h3>
            <p>Angol nevén <b>tapestry</b>, magyarul pedig a <b>gobelin/faliszőnyeg</b> szavakat használjuk rá, bár horgolós körökbe a 'tapestry' kifejezéssel élnek inkább. Ezzel a techinkával uyganis nem csak nagy, részletes képeket lehet alkotni, hanem kisebb, csupán képkeretnyi méretű alkotás is készíthető.</p>
            <p>További segítséget vagy inspirációkat a blogunkon találsz: <a href="" style="text-decoration: none; color: #fcd297;" target="_blank">Ez a link rögtön oda is visz</a></p>
          </div>
        </div>

        <div class="harom-oszlop">
          <div class="kartya">
            <div class="szoveg">
              <h3>Horgolás</h3>
              <p>A tapestry horgolásnál a legfontosabb megtanulni, hogyan kell több színnel dolgozni egy sorban. Minden sorban két vagy több színt fogsz használni, és az egyik sort a másik fölé fogod horgolni. A felső szín lesz az, amit látsz, a többit pedig mögötte fogod vinni. Szoros öltéseket kell készítened, hogy a hátsó második (vagy több) szín ne látszódjon át a felső színen.</p>                
              <p>Horgoláshoz útmutató: <a href="https://kossunklanyok.hu/ajanlo/tapestry-szovethetasu-horgolas" class="felso-linkek" target="_blank">Összegző leírás/tudnivalók</a></p>
            </div>
          </div>
          <div class="kartya">
            <div class="szoveg">
              <h3>Kötés</h3>
              <p>Kötéshez két módszer használható: az intarsia és a dupla oldalú kötés. Az intarsia esetén a különböző fonalaknál a színeket a hátsó oldalon vezetjük, így csak a minta eleje lesz szép. A dupla oldalú kötésnél ezzel szemben vezetjük a színeket, így a minta hátulja is ugyanolyan szépen fog kinézni mint az eleje, csak fordított színekkel.</p>
              <p>Kötéshez segítség: <a href="https://gombocska.hu/falikepek-fonalbol/" class="felso-linkek" target="_blank">Kifejezetten kötéshez plusz segítség</a></p>
            </div>
          </div>
          <div class="kartya">
            <div class="szoveg">
              <h3>Hímzés</h3>
              <p>A gobelin készítésekor nyitott rácson varrunk, és a varrásokból szövetet hozunk létre. Bár számtalan hímzővarrás közül választhatunk, a tapestry készítésekor általában egy vagy két öltéshez ragaszkodunk. A sima varrású hagyományos gobelin készítéséhez két alapvető varrásmódra van szükség: a sátorvarrás és a kosárfonás varrás.</p>
              <p>Hímzés elkezdéséhez alap: <a href="https://gombocska.hu/kezi-himzes-alapjai/" class="felso-linkek" target="_blank">Minden amit kezdés előtt tudni kell</a></p>
            </div>
          </div>
        </div>

      </div>
    </div>

    <!-- Adatok bekérése -->
    <div v-if="!pixelesKep">
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
            <div v-for="(option, index) in fonalak" :key="index" class="radio-container">
              <input
                type="radio"
                :id="option.fonalTipus"
                name="masodikLepes"
                :value="option"
                v-model="masodikLepes"
              />
              <label :for="option.fonalTipus">{{ option.fonalTipus }}</label>
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
            A fonaltípusod: <strong>{{masodikLepes?.fonalTipus || masodikLepes}}</strong> 
            <button @click="modositas(2)" class="visszaGomb">Vissza</button>
          </p>

          <p class="cimek">Fájl feltöltése:</p>
          <label for="file-upload" class="file-upload-label">
            Kép kiválasztása
          </label>
          <input id="file-upload" type="file" @change="kepfeltoltes" accept="image/*" />
          
          <div v-if="file" class="file-preview-container">
            <img :src="kepUrl" alt="Preview" class="file-preview" />
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

    <!-- Pixelesített kép -->
    <div v-else class="pixelation-main-container">
      <div class="pixelesContainer">
        <h1>Minta Változtató</h1>
        
        <div v-if="!aktualisKep" class="feltoltes">
          <p>Nincs kép betöltve. Kérjük, menj vissza és tölts fel egy képet.</p>
          <button @click="adatokVissza" class="visszaGomb">Vissza a feltöltéshez</button>
        </div>

        <div v-else class="modositoContainer">
          <div class="modositas">
            <div class="valtoztatok">
              <p>Pixel mérete: {{ pixelMeret }}px</p>
              <div class="valtoztatok-input">
                <input 
                  type="range" 
                  min="5" 
                  max="40" 
                  v-model.number="pixelMeret" 
                  class="csuszka"
                  @input="mintaFrissites"
                />
                <input 
                  type="number" 
                  min="5" 
                  max="40" 
                  v-model.number="pixelMeret"
                  class="szam-input"
                  @input="mintaFrissites"
                />
              </div>
            </div>

            <div class="valtoztatok">
              <p>Rács vastagsága: {{ racsLathatosag }}%</p>
              <div class="valtoztatok-input">
                <input 
                  type="range" 
                  min="0" 
                  max="60" 
                  v-model.number="racsLathatosag" 
                  class="csuszka"
                  @input="mintaFrissites"
                />
                <input 
                  type="number" 
                  min="0" 
                  max="60" 
                  v-model.number="racsLathatosag"
                  class="szam-input"
                  @input="mintaFrissites"
                />
              </div>
            </div>

            <div class="valtoztatok">
              <p>Színek száma: {{ szinSzam }}</p>
              <div class="valtoztatok-input">
                <input 
                  type="range" 
                  min="2" 
                  max="20" 
                  v-model.number="szinSzam" 
                  class="csuszka"
                  @input="mintaFrissites"
                />
                <input 
                  type="number" 
                  min="2" 
                  max="20"
                  v-model.number="szinSzam"
                  class="szam-input"
                  @input="mintaFrissites"
                />
              </div>
            </div>

            <div class="valtoztatok">
              <p>Színek változtatása: </p>
              <div class="szin-paletta">
                <div
                  v-for="(szin, index) in szinPaletta"
                  :key="szin.id"
                  class="szin-negyzet"
                  :style="{ backgroundColor: szin.jelenlegi }"
                  @click="szinValasztas(index)"
                  :title="'Kattints a szín módosításához'"
                >
                  <div class="szin-sorszam">{{ index + 1 }}</div>
                </div>
              </div>
            </div>

          </div>

          <!--Canvas -->
          <canvas ref="canvas" style="display: none;"></canvas>

          <!-- Pixeles kép konténere -->
          <div class="pixel-grid-container">
            <div class="pixel-info">
              <p>Kép mérete: {{ aktualisKep.width }}×{{ aktualisKep.height }} px | 
                Pixel rács: {{ pixelSorok.length }}×{{ pixelSorok[0]?.pixels.length || 0 }}</p>
            </div>
            <div class="pixel-container" v-if="pixelSorok.length > 0">
              <div
                v-for="(row, rowIndex) in pixelSorok"
                :key="rowIndex"
                class="pixel-row"
                :style="{ opacity: row.sorLathatosag }"
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
                      borderColor: isDarkColor(pixel.color)
                      ? 'rgba(255,255,255,0.6)'
                      : `rgba(0,0,0, ${racsLathatosag / 100})`,
                      color: isDarkColor(pixel.color) ? '#fff' : '#000'
                      }"
                  ></div>
                </div>

                <div class="checkbox-container">
                  <input
                    type="checkbox"
                    :id="`row-${rowIndex}`"
                    v-model="pipaltSorok[rowIndex]"
                    @change="sorLathatosagValtas(rowIndex)"
                  />
                  <label :for="`row-${rowIndex}`" class="pixeles-label">{{ rowIndex + 1 }}</label>
                </div>
              </div>
            </div>
            <div v-else>
              <img src="../assets/public/loading.gif" alt="Kép betöltése folyamatban">
            </div>
          </div>

          <!-- Mintaváltoztató gombok -->
          <div class="gombok">
            <button @click="adatokVissza" class="gomb">Vissza a feltöltéshez</button>
            <button @click="visszaallitas" class="gomb">Eredeti állapot</button>
            <button @click="kepletoltes(canvas)" class="gomb letolt">Letöltés</button>
            <button @click="kepTorles" class="gomb">Új kép</button>
          </div>
        </div>
      </div>
      

      <!-- Oldalsáv -->
      <div class="oldalsav">
          <div class="oldal-kartya">
            <h3>Projekt adatai</h3>
            <p><strong>Technika:</strong> {{ elsoLepes }}</p>
            <p><strong>Fonal vastagsága:</strong> {{ masodikLepes.fonalTipus }}</p>
            <p><strong>Minta mérete:</strong> {{ pixelSorok.length }}×{{ pixelSorok[0]?.pixels.length || 0 }}</p>
            <p><strong>Szükséges fonalhossz: ~</strong> {{ fonalHossz }} cm</p>
            <p><strong>Befejezett sorok:</strong> {{ Object.values(pipaltSorok).filter(Boolean).length }}</p>
          </div>
          <div class="oldal-kartya">
            <h3>Tippek</h3>
            <ul>
              <li>Jelöld meg azokat a sorokat, amelyeket külön szeretnél kezelni</li>
              <li>Kisebb pixel méret részletesebb mintát ad</li>
              <li>A rács átlátszósága segít a minta követésében</li>
            </ul>
          </div>
        </div>

        <div v-if="szinValtoztatasModal" class="modal-overlay" @click="szinValtoztatasModal = false">
          <div class="modal-content" @click.stop>
            <h3 style="color: var(--mk-text-light);">Szín módosítása</h3>
            <div class="szin-osszehasonlitas">
              <div class="szin-minta" :style="{ backgroundColor: szinPaletta[kivalasztottSzinIndex]?.eredeti }"></div>
              <span style="color: var(--mk-text-light);">→</span>
              <div class="szin-minta" :style="{ backgroundColor: ujSzin }"></div>
            </div>
            <input type="color" v-model="ujSzin" class="szin-valaszto" />
            <div class="modal-gombok">
              <button @click="szinValtoztatasModal = false" class="szinek-gomb-megse">Mégse</button>
              <button @click="szinFrissites" class="szinek-gomb-mentes">Mentés</button>
            </div>
          </div>
        </div>

    </div>
  </main>
</template>

<style scoped>
*, *::before, *::after {
  box-sizing: border-box;
}

body {
  font-family: 'Poppins', sans-serif;
  color: var(--mk-text-dark);
  background-color: rgb(255, 211, 144);
  margin: 0;
  padding: 0;
}

main {
  margin: 0 auto;
  height: auto;
  text-align: center;
  padding: 20px;
}

.title {
  display: inline-block;
  font-weight: 700;
  font-size: 45px;
  color: var(--mk-text-dark);
  background-image: linear-gradient(90deg, #f08686, #5f0707);
  background-repeat: no-repeat;
  background-position: 0 100%;
  background-size: 100% 4px;
  padding-bottom: 6px;
}

/* Add these new styles for color palette */

.szin-paletta {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  justify-content: center;
}

.szin-negyzet {
  width: 40px;
  height: 40px;
  border: 1px solid #fff0de;
  border-radius: 4px;
  cursor: pointer;
  position: relative;
  box-shadow: 0 2px 4px rgba(0,0,0,0.2);
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.szin-negyzet:hover {
  transform: scale(1.1);
  box-shadow: 0 4px 8px rgba(0,0,0,0.3);
}

.szin-sorszam {
  position: absolute;
  top: -5px;
  right: -5px;
  background: rgba(0,0,0,0.7);
  color: white;
  border-radius: 50%;
  width: 18px;
  height: 18px;
  font-size: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
}

/* Modal styles */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0,0,0,0.5);
  display: flex;
  align-items: center;
  justify-content: center;
}

.modal-content {
  background: var(--mk-hatterszin);
  padding: 24px;
  border-radius: 8px;
  box-shadow: 0 4px 20px rgba(0,0,0,0.3);
  max-width: 400px;
  width: 90%;
}

.szin-osszehasonlitas {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 16px;
  margin: 20px 0;
}

.szin-minta {
  width: 60px;
  height: 60px;
  border: 2px solid #fff;
  border-radius: 4px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.2);
}

.szin-valaszto {
  width: 100%;
  height: 50px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  margin: 16px 0;
}

.szinek-gomb-megse, .szinek-gomb-mentes {
  padding: 10px 20px;
  border: none;
  border-radius: 5px;
  cursor: pointer;
  font-weight: bold;
  color: white;
  transition: background-color 0.3s;
  min-width: 120px;
}

.szinek-gomb-megse {
  background-color: #802929;
}

.szinek-gomb-mentes {
  background-color: #195c3d;
}

.szinek-gomb-megse:hover {
  background-color: #4b0d0d;
  transform: translateY(-2px);
}

.szinek-gomb-mentes:hover {
  background-color: #034110;
  transform: translateY(-2px);
}

.modal-gombok {
  display: flex;
  gap: 12px;
  justify-content: center;
}

/*#region felső szövegdobozok*/
#bemutato {
  margin: auto;
  text-align: justify;
  margin-bottom: 50px;
  border-radius: 8px;
}

.ket-oszlop {
  display: grid;
  grid-template-columns: 2fr 3fr;
  gap: 35px;
  align-items: start;
  width: 100%;
  margin: 0 auto 48px;
  padding: 16px;
}

.harom-oszlop {
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
  padding: 10px;
  box-shadow: 0 4px 15px var(--mk-arnyekszin);
  transition: transform 0.3s ease, box-shadow 0.3s ease;
  position: relative;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  color: var(--mk-text-dark);
}

.kartya:nth-child(1)::before {
  background-image: url('../assets/public/mk-horgolas.png');
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-size: cover;
  background-position: center;
  filter: blur(1px);
  opacity: 0.6;
}

.kartya:nth-child(2)::before {
  background-image: url('../assets/public/mk-kotes.jpg');
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-size: cover;
  background-position: center;
  filter: blur(2px);
  opacity: 0.7;
}

.kartya:nth-child(3)::before {
  background-image: url('../assets/public/mk-himzes.jpg');
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-size: cover;
  background-position: center;
  filter: blur(2px);
  opacity: 0.7;
}

.kartya:hover {
  transform: translateY(-10px);
  box-shadow: 0 6px 20px var(--mk-arnyekszin);
}

.szoveg {
  background-color: rgba(255, 235, 235, 0.925);
  border-radius: 6px;
  position: relative; /* Ensure text stays above background */
  padding: 20px;
}

.kartya h3 {
  margin-bottom: 16px;
  font-size: 24px;
  font-weight: 600;
  text-align: center;
}

.kartya ul {
  text-align: left;
  margin-top: 10px;
}

.kartya li {
  margin-bottom: 5px;
}

.blog-info {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  background-color: var(--mk-szovegdoboz-masod);
  color: white;
  padding: 30px 20px 20px;
  transition: all 0.3s ease;
}

.blog-info ol {
  text-align: left;
  padding-left: 20px;
}

.blog-info li {
  margin-bottom: 10px;
}

.blog-info:hover {
  transform: translateY(-30px);
  box-shadow: 0 6px 20px var(--mk-arnyekszin);
}

.blog-info-kontener {
  position: relative;
  width: 100%;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 4px 15px var(--mk-arnyekszin);
}

.blog-info-kontener img {
  width: 100%;
  height: auto;
  display: block;
  transition: transform 0.3s ease;
}

.blog-info-kontener:hover img {
  transform: scale(1.05);
}

.felso-linkek {
  text-decoration: none;
  color: #c56900;
}

/*#endregion*/

/*#region adatbekérés*/
#adatok {
  max-width: 900px;
  margin: 0 auto;
  padding: 32px;
  background-color: var(--mk-hatterszin);
  border-radius: 8px;
  box-shadow: 0 2px 15px var(--mk-arnyekszin);
}

.radioStilus {
  padding: 24px;
  transition: opacity 0.3s ease;
}

.cimek {
  font-size: 24px;
  font-weight: 600;
  color: var(--mk-text-dark);
  margin-bottom: 24px;
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
  border: 2px solid rgb(202, 200, 200);
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
    background-color: #ac8888;
  }
  50% {
    transform: translate(-50%, -50%) scale(1.5);
    background-color: #ac7e7e;
  }
  100% {
    transform: translate(-50%, -50%) scale(1);
    background-color: var(--mk-checkbox);
  }
}

label {
  color: var(--mk-text-light);
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
  margin: 32px auto 0;
  border: none;
  border-radius: 8px;
  background: linear-gradient(135deg, var(--mk-gomb-foszin), var(--mk-gomb-masodszin));
  color: var(--white);
  font-weight: 600;
  font-size: 16px;
  letter-spacing: 1px;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 15px var(--mk-arnyekszin);
  overflow: hidden;
  position: relative;
  color: var(--mk-text-light);
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
  box-shadow: 0 6px 20px rgba(119, 6, 6, 0.589);
}

.visszaGomb {
  padding: 8px 16px;
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
  padding: 16px 32px;
  background-color: var(--mk-gomb-masodszin);
  color: var(--mk-text-dark);
  border-radius: 10px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
  margin-bottom: 16px;
}

.file-upload-label:hover {
  background-color: var(--mk-gomb-foszin);
  transform: translateY(-3px);
  color: var(--mk-text-light);
}

.file-preview {
  max-width: 100%;
  max-height: 300px;
  margin: 16px auto;
  border-radius: 10px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
}

.file-preview-container {
  margin: 20px 0;
}

.progress-container {
  margin-bottom: 32px;
}

.progress-bar {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
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
  background-color: rgb(110, 29, 29);
}

.progress-step:not(:last-child)::after {
  content: '';
  position: absolute;
  left: 100%;
  width: 900%;
  height: 8px;
  background-color: rgb(71, 60, 60);
  z-index: -1;
}

.progress-step.active:not(:last-child)::after {
  background-color: rgb(82, 3, 3);
}

.progress-labels {
  display: flex;
  justify-content: space-between;
}

.progress-label {
  font-size: 14px;
  color: var(--mk-text-dark);
}

@media (max-width: 900px) {
  .progress-step:not(:last-child)::after {
    width: 400%;
  }
}
/*#endregion*/

/*#region mintaváltozásos box*/
.pixelation-main-container {
  display: flex;
  gap: 20px;
  margin: 0 auto;
  padding: 32px;
  align-items: flex-start;
  flex-wrap: nowrap;
  max-width: 100%;
  box-sizing: border-box;
}

.pixelesContainer {
  flex: 1 1 auto; /* This makes it take all available space */
  padding: 32px;
  background-color: var(--mk-hatterszin);
  /*min-height: 100vh;*/
  border-radius: 10px;
  max-width: calc(100% - 320px);
  overflow: auto;
  box-sizing: border-box;
}

.modositoContainer {
  width: 100%;
}

.feltoltes {
  text-align: center;
  padding: 32px;
}

.modositas {
  display: flex;
  flex-wrap: wrap;
  gap: 32px;
  margin-bottom: 32px;
  padding: 16px;
  background-color: #704848e5;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  color: var(--mk-text-light);
}

.valtoztatok {
  display: flex;
  flex-direction: column;
  gap: 8px;
  min-width: 200px;
}

.slider-with-input {
  display: flex;
  flex-direction: column;
  gap: 8px;
  width: 100%;
}

.valtoztatok-input {
  display: flex;
  align-items: center;
  gap: 12px;
  width: 100%;
}

.csuszka {
  flex: 1;
  accent-color: #dad7d7;
}

.szam-input {
  width: 70px;
  padding: 6px 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
  background-color: white;
  color: var(--mk-text-dark);
  font-size: 14px;
  text-align: center;
}

.szam-input:focus {
  outline: none;
  border-color: var(--mk-gomb-foszin);
  box-shadow: 0 0 0 2px rgba(119, 6, 6, 0.1);
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

.pixeles-label {
  margin-left: 5px;
  font-size: 0.9em;
  color: var(--mk-text-dark);
}

.gombok {
  display: flex;
  justify-content: center;
  gap: 16px;
  margin-top: 32px;
  flex-wrap: wrap;
}

.gomb {
  padding: 10px 20px;
  border: none;
  border-radius: 5px;
  cursor: pointer;
  font-weight: bold;
  background-color: #853939d7;
  color: white;
  transition: background-color 0.3s;
  min-width: 120px;
}

.gomb:hover {
  background-color: #5c1919;
  transform: translateY(-2px);
}

.gomb.letolt {
  background-color: #4caf5c;
}

.gomb.letolt:hover {
  background-color: #45a049;
}
/*#endregion*/

/*#region Oldalsáv */
.oldalsav {
  flex: 0 0 320px;
  width: 320px;
  display: flex;
  flex-direction: column;
  gap: 20px;
  padding: 10px;
  background-color: rgb(255, 235, 235);
  border-radius: 8px;
  box-shadow: 0 4px 15px var(--mk-arnyekszin);
  align-self: flex-start;
  position: sticky;
  overflow: auto;
}

.oldal-kartya {
  background-color: var(--mk-oldaldoboz);
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 4px 15px var(--mk-arnyekszin);
  color: var(--mk-text-light);
}

.oldal-kartya h3 {
  color: var(--mk-text-light);
  margin-bottom: 16px;
  font-size: 20px;
  font-weight: 600;
}

.oldal-kartya ul {
  text-align: left;
  padding-left: 20px;
}

.oldal-kartya li {
  margin-bottom: 8px;
  font-size: 0.9em;
}
/*#endregion*/

@media (max-width: 1100px) {
  .ket-oszlop {
    grid-template-columns: 1fr;
  }

  .harom-oszlop {
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
  .harom-oszlop {
    grid-template-columns: 1fr;
  }
  
  .title {
    font-size: 32px;
  }
  
  #adatok {
    padding: 24px;
  }
  
  input[type="radio"] {
    width: 18px;
    height: 18px;
  }
  
  label {
    font-size: 16px;
  }
  
  .gombok {
    flex-direction: column;
    align-items: center;
  }
  
  .modositas {
    flex-direction: column;
    gap: 16px;
  }
  
  .valtoztatok {
    min-width: auto;
  }

    .valtoztatok-input {
    flex-direction: column;
    gap: 8px;
  }
  
  .szam-input {
    width: 100%;
  }
  
  .valtoztatok {
    min-width: auto;
  }

    .szin-paletta {
    gap: 6px;
  }
  
  .szin-negyzet {
    width: 35px;
    height: 35px;
  }
  
  .modal-content {
    padding: 16px;
  }
}

@media (max-width: 1100px) {
  .pixelation-main-container {
    flex-direction: column;
  }
  
  .oldalsav {
    width: 100%;
    margin-top: 20px;
  }
}
</style>