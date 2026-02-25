<script setup>
import { ref, reactive, onMounted, onUnmounted, nextTick, computed, watch } from "vue"
import axios from 'axios';
import { useCartStore } from "@/stores/cartStore";
import api from '@/services/api.js'
import Stepper from "primevue/stepper";
import StepperPanel from "primevue/stepperpanel";

// #region Adat változók
const resz = ref(1)
const elsoLepes = ref(null)
const masodikLepes = ref(null)
const file = ref(null)
const pixelesKep = ref(false)
const kepUrl = ref(null)
const aktualisKep = ref(null)
const betoltottKep = ref(false)
const fonalTermek = ref(null)
const szuksegesGombolyagok = ref(0)
const kosarModal = ref(false)
const kosarHozzaadva = ref(false)
const kosarBetoltes = ref(false)

const tipusok = ["Horgolás", "Kötés", "Hímzés"]
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
//#endregion

async function fonalTermekBetoltese() {
    if (!masodikLepes.value || !masodikLepes.value.fonalTipus) return
    
    kosarBetoltes.value = true
    colorMatchLoading.value = true
    
    try {
        const fonalTipusEncoded = encodeURIComponent(masodikLepes.value.fonalTipus)
        
        const response = await axios.get(`http://localhost:8000/api/termekek/fonal-csoport/${fonalTipusEncoded}`, {
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'X-Requested-With': 'XMLHttpRequest'
            },
            withCredentials: true
        })
        
        const data = response.data
        
        if (data.length > 0) {
            fonalTermek.value = data[0]
            
            // Extract yarn colors from the product
            if (fonalTermek.value.TermekSzinek && fonalTermek.value.TermekSzinek.length > 0) {
                yarnColors.value = fonalTermek.value.TermekSzinek.map(szin => ({
                    hex: szin.hex_kod,
                    name: szin.szin_nev || szin.nev || 'Névtelen'
                }))
            } else if (fonalTermek.value.available_colors) {
                yarnColors.value = fonalTermek.value.available_colors
            } else {
                yarnColors.value = []
            }
            
            // Calculate necessary gombolyagok
            if (fonalTermek.value && fonalTermek.value.meter && fonalHossz.value > 0) {
                const fonalMeterben = fonalHossz.value / 100
                szuksegesGombolyagok.value = Math.ceil(fonalMeterben / fonalTermek.value.meter)
            }
            
            // Check color matching
            if (szinPaletta.value && szinPaletta.value.length > 0) {
                checkColorMatching()
            }
        } else {
            fonalTermek.value = null
            szuksegesGombolyagok.value = 0
            yarnColors.value = []
            colorMatchResult.value = null
        }
    } catch (error) {
        console.error('Fonal termék betöltése sikertelen:', error)
        fonalTermek.value = null
        szuksegesGombolyagok.value = 0
        yarnColors.value = []
        colorMatchResult.value = null
    } finally {
        kosarBetoltes.value = false
        colorMatchLoading.value = false
    }
}

//#region Adatok feldolgozása
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
//#endregion

//#region Pixelesítés változók
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
//#endregion

//#region Színkiválasztás
function automatikusSzinCsoportositas(pixelAdatok = null) {
  if (pixelSorok.value.length === 0) return
  
  const szinGyakorisag = {}
  
  pixelSorok.value.forEach(row => {
    row.pixels.forEach(pixel => {
      const color = pixel.color
      szinGyakorisag[color] = (szinGyakorisag[color] || 0) + 1
    })
  })
  
  const leggyakoribbSzinek = Object.entries(szinGyakorisag)
    .sort(([,a], [,b]) => b - a)
    .slice(0, szinSzam.value)
    .map(([color]) => color)
  
  szinPaletta.value = leggyakoribbSzinek.map((color, index) => ({
    id: index,
    eredeti: color,
    jelenlegi: color,
    hasznalva: true
  }))
  
  pixelSorok.value.forEach(row => {
    row.pixels.forEach(pixel => {
      pixel.color = legkozelebbiSzinKereses(pixel.color, szinPaletta.value)
    })
  })
}

function canvasFeldolgozas(img) {
  if (!canvas.value || !canvas.value.getContext) {
    setTimeout(() => {
      if (canvas.value && aktualisKep.value) {
        canvasFeldolgozas(aktualisKep.value)
      }
    }, 100)
    return
  }

  processImageWithColors(img)
}

function processImageWithColors(img) {
  const pxMeret = parseInt(pixelMeret.value)
  
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

  for (let i = 0; i < rows; i++) {
    if (pipaltSorok[i] === undefined) {
      pipaltSorok[i] = false
    }
  }

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

  const leggyakoribbSzinek = Object.entries(szinGyakorisag)
    .sort(([,a], [,b]) => b - a)
    .slice(0, szinSzam.value)
    .map(([color]) => color)
  
  szinPaletta.value = leggyakoribbSzinek.map((color, index) => ({
    id: index,
    eredeti: color,
    jelenlegi: color,
    hasznalva: true
  }))

  for (let y = 0; y < rows; y++) {
    const pixels = []
    for (let x = 0; x < cols; x++) {
      const originalColor = atmenetiPixelAdatok[y].pixels[x].originalColor
      
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

function legkozelebbiSzinKereses(color, palette) {
    if (palette.length === 0) return color
  
  const [r1, g1, b1] = color.match(/\d+/g).map(Number)
  
  let legkozelebbiIndex = 0
  let legkisebbTavolsag = Infinity
  
  palette.forEach((szinObj, index) => {
    const [r2, g2, b2] = szinObj.jelenlegi.match(/\d+/g).map(Number)
    
    const tavolsag = szinTavolsag(r1, g1, b1, r2, g2, b2)
    
    if (tavolsag < legkisebbTavolsag) {
      legkisebbTavolsag = tavolsag
      legkozelebbiIndex = index
    }
  })
  
  return palette[legkozelebbiIndex].jelenlegi
}

function szinTavolsag(r1, g1, b1, r2, g2, b2) {
  const lab1 = rgbToLab(r1, g1, b1)
  const lab2 = rgbToLab(r2, g2, b2)
  
  return deltaE00(lab1, lab2)

}

function rgbToLab(r, g, b) {
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

function deltaE00(lab1, lab2) {
  const L1 = lab1.l, a1 = lab1.a, b1 = lab1.b
  const L2 = lab2.l, a2 = lab2.a, b2 = lab2.b
  
  const kL = 1, kC = 1, kH = 1
  
  const C1 = Math.sqrt(a1 * a1 + b1 * b1)
  const C2 = Math.sqrt(a2 * a2 + b2 * b2)
  
  const aC = (C1 + C2) / 2
  const aC7 = Math.pow(aC, 7)
  const G = 0.5 * (1 - Math.sqrt(aC7 / (aC7 + 6103515625)))
  
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

  const dominantColor = getDominantColor(pixels)

  return dominantColor;
}

function getDominantColor(pixels) {
  if (pixels.length === 0) return { r: 0, g: 0, b: 0, a: 1 }
  
  const colorMap = new Map()
  const tolerance = 10 
  
  pixels.forEach(pixel => {
    const quantizedR = Math.round(pixel.r / tolerance) * tolerance
    const quantizedG = Math.round(pixel.g / tolerance) * tolerance
    const quantizedB = Math.round(pixel.b / tolerance) * tolerance
    const key = `${quantizedR},${quantizedG},${quantizedB}`
    
    colorMap.set(key, (colorMap.get(key) || 0) + 1)
  })
  
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
//#endregion

//#region Színmatch
const colorMatchResult = ref(null)
const colorMatchLoading = ref(false)
const yarnColors = ref([])

function hexToRgbObject(hex) {
    const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex)
    if (!result) return { r: 0, g: 0, b: 0 }
    return {
        r: parseInt(result[1], 16),
        g: parseInt(result[2], 16),
        b: parseInt(result[3], 16)
    }
}

function rgbaToRgbObject(rgba) {
    const match = rgba.match(/rgba?\((\d+),\s*(\d+),\s*(\d+)/)
    if (!match) return { r: 0, g: 0, b: 0 }
    return {
        r: parseInt(match[1]),
        g: parseInt(match[2]),
        b: parseInt(match[3])
    }
}

function calculateColorDistance(rgb1, rgb2) {
    // Calculate Euclidean distance between colors
    const dr = rgb1.r - rgb2.r
    const dg = rgb1.g - rgb2.g
    const db = rgb1.b - rgb2.b
    return Math.sqrt(dr * dr + dg * dg + db * db)
}

function findNearestYarnColor(imageColor) {
    if (!yarnColors.value || yarnColors.value.length === 0) return null
    
    const imageRgb = rgbaToRgbObject(imageColor)
    let nearestColor = null
    let minDistance = Infinity
    
    yarnColors.value.forEach(yarnColor => {
        const yarnRgb = hexToRgbObject(yarnColor.hex)
        const distance = calculateColorDistance(imageRgb, yarnRgb)
        
        if (distance < minDistance) {
            minDistance = distance
            nearestColor = yarnColor
        }
    })
    
    // Check if the distance is within an acceptable threshold (you can adjust this)
    return minDistance <= 100 ? nearestColor : null // Threshold of 100
}

async function checkColorMatching() {
    if (!fonalTermek.value || !szinPaletta.value || szinPaletta.value.length === 0) return
    
    colorMatchLoading.value = true
    
    try {
        // Get yarn colors from the product
        if (fonalTermek.value.TermekSzinek && fonalTermek.value.TermekSzinek.length > 0) {
            yarnColors.value = fonalTermek.value.TermekSzinek.map(szin => ({
                hex: szin.hex_kod,
                name: szin.szin_nev || szin.nev || 'Névtelen'
            }))
        } else if (fonalTermek.value.available_colors) {
            yarnColors.value = fonalTermek.value.available_colors
        } else {
            // If no colors available, set empty array
            yarnColors.value = []
        }
        
        // Extract unique colors from the image
        const imageColors = [...new Set(szinPaletta.value.map(szin => szin.jelenlegi))]
        
        // Check for matches
        const matches = []
        const noMatches = []
        
        imageColors.forEach(imageColor => {
            const yarnColor = findNearestYarnColor(imageColor)
            if (yarnColor) {
                matches.push({
                    imageColor: imageColor,
                    yarnColor: yarnColor,
                    hexColor: rgbToHex(imageColor)
                })
            } else {
                noMatches.push({
                    imageColor: imageColor,
                    hexColor: rgbToHex(imageColor)
                })
            }
        })
        
        colorMatchResult.value = {
            matches: matches,
            noMatches: noMatches,
            hasYarnColors: yarnColors.value.length > 0,
            allYarnColors: yarnColors.value
        }
        
    } catch (error) {
        console.error('Szín egyeztetés sikertelen:', error)
        colorMatchResult.value = null
    } finally {
        colorMatchLoading.value = false
    }
}

// Watch for changes in the fonalTermek and trigger color matching
watch(fonalTermek, (newVal) => {
    if (newVal && szinPaletta.value && szinPaletta.value.length > 0) {
        checkColorMatching()
    }
})

// Also trigger when palette changes
watch(szinPaletta, () => {
    if (fonalTermek.value && szinPaletta.value && szinPaletta.value.length > 0) {
        checkColorMatching()
    }
}, { deep: true })
//#endregion

//#region Változtatható inputok
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
    
    szinPaletta.value[kivalasztottSzinIndex.value].jelenlegi = ujSzinRgb
    
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

function rgbToHex(rgb) {
    const match = rgb.match(/rgba?\((\d+),\s*(\d+),\s*(\d+)(?:,\s*([\d.]+))?\)/)
    if (!match) return '#000000'
    
    const r = parseInt(match[1])
    const g = parseInt(match[2])
    const b = parseInt(match[3])
    
    const toHex = (num) => {
        const hex = num.toString(16)
        return hex.length === 1 ? '0' + hex : hex
    }
    
    return "#" + toHex(r) + toHex(g) + toHex(b)
}

function hexToRgb(hex) {
    const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex)
    if (!result) return 'rgba(0, 0, 0, 1)'
    
    return `rgba(${parseInt(result[1], 16)}, ${parseInt(result[2], 16)}, ${parseInt(result[3], 16)}, 1)`
}
//#endregion

//#region Optimalizálás
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

watch(szinSzam, (newVal) => {
if (aktualisKep.value && pixelSorok.value.length > 0) {
    nextTick(() => {
      automatikusSzinCsoportositas()
    })
  }
})
//#endregion

//#region Mentés & törlés
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
  
  const fileInput = document.getElementById('file-upload')
  if (fileInput) fileInput.value = ''
}

function adatokVissza() {
  pixelesKep.value = false
  betoltesKorabbrol()
}

function kepletoltes(canvas, filename = 'modified-image.png') {
  if (!canvas.value) return
  canvas.toBlob((blob) => {
    const link = document.createElement('a');
    link.download = filename;
    link.href = URL.createObjectURL(blob);
    
    link.click();
  })
}

function visszaallitas() {
if (aktualisKep.value) {
        canvasFeldolgozas(aktualisKep.value)
        Object.keys(pipaltSorok).forEach(key => {
            pipaltSorok[key] = false
        })
        pixelSorok.value.forEach((row, index) => {
            row.sorLathatosag = 1
        })
    }
}

watch(pixelesKep, (newVal) => {
  if (newVal && aktualisKep.value && betoltottKep.value) {
    nextTick(() => {
      setTimeout(() => {
        if (canvas.value) {
          canvasFeldolgozas(aktualisKep.value)
        }
      }, 50)
    })
  }
})

onMounted(() => {
  formBetoltes()
  elozoKep()
})
//#endregion

//#region Áruház számítások
const fonalHossz = computed(() => {
    const pixelRacsSor = pixelSorok.value.length
    const pixelRacsOszlop = pixelSorok.value[0]?.pixels.length || 0
    
    if (pixelRacsSor === 0 || pixelRacsOszlop === 0 || !masodikLepes.value) return 0
    
    const hossz = ((pixelRacsSor * pixelRacsOszlop) / 
                  (masodikLepes.value.meromintaSor * masodikLepes.value.meromintaOszlop)) * 100
    
    const result = isNaN(hossz) ? 0 : Number(hossz.toFixed(1))
    
    if (result > 0 && fonalTermek.value) {
        nextTick(() => {
            const fonalMeterben = result / 100
            szuksegesGombolyagok.value = Math.ceil(fonalMeterben / fonalTermek.value.meter)
        })
    }
    
    return result
})

async function fonalHozzaadasKosarhoz() {
    if (!fonalTermek.value || szuksegesGombolyagok.value <= 0) {
        alert('Kérjük, először válassz fonaltípust!')
        return
    }
    
    kosarBetoltes.value = true
    try {
        // First validate with API
        const response = await axios.post('/api/kosar/hozzaad', {
            termek_id: fonalTermek.value.id,
            mennyiseg: szuksegesGombolyagok.value
        }, {
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'X-Requested-With': 'XMLHttpRequest'
            },
            withCredentials: true
        })
        
        // If API validation passes, add to client-side cart store
        const cartStore = useCartStore()
        const result = cartStore.addToCart(fonalTermek.value, szuksegesGombolyagok.value)
        
        if (result.success) {
            kosarHozzaadva.value = true
            kosarModal.value = true
            
            setTimeout(() => {
                kosarModal.value = false
            }, 5000)
        } else {
            alert('Hiba: ' + result.message)
        }
        
    } catch (error) {
        console.error('Kosárhoz adás sikertelen:', error)
        alert('Hiba történt a kosárhoz adás során: ' + (error.response?.data?.error || error.message))
    } finally {
        kosarBetoltes.value = false
    }
}

watch(masodikLepes, (newVal) => {
    if (newVal && newVal.fonalTipus) {
        fonalTermekBetoltese()
    }
}, { immediate: true })

watch([pixelMeret, pixelSorok], () => {
}, { deep: true })
//#endregion

//#region Már meglévő beállítás & képszélesség
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

const showAlert = ref(false);
const isMobile = ref(false);

function checkScreenWidth() {
  isMobile.value = window.innerWidth < 440;
  if (isMobile.value) {
    showSuccessAlert();
  }
}

function showSuccessAlert() {
  showAlert.value = true;
}

onMounted(() => {
  checkScreenWidth();
  window.addEventListener('resize', checkScreenWidth);
});

onUnmounted(() => {
  window.removeEventListener('resize', checkScreenWidth);
});
//#endregion

</script>

<template>
  <main>
    <h1 class="title">Mintakészítő</h1>
    
    <!--#region Felső sávos szövegbobozok-->
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
    <!--#endregion-->


    <!--#region Adatok bekérése -->
     <!-- ide ilyet: https://v3.primevue.org/stepper/-->
    <div v-if="!pixelesKep">

      <!--
      <Stepper>
        <StepperPanel header="Típus">
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
        </StepperPanel>
        <StepperPanel header="Fonal">
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
        </StepperPanel>
        <StepperPanel header="Fájl">
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
        </StepperPanel>
    </Stepper>-->

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
    <!--#endregion-->

    <!--#region Elkészült minta -->
    <div v-else class="pixelation-main-container">
      <div class="pixelesContainer">
        <h1>Minta változtató</h1>
        
        <div v-if="!aktualisKep" class="feltoltes">
          <p>Nincs kép betöltve. Kérjük, menj vissza és tölts fel egy képet.</p>
          <button @click="adatokVissza" class="visszaGomb">Vissza a feltöltéshez</button>
        </div>
        <!--#region Módosítások-->
        <div v-else class="modositoContainer">
          <div class="modositas">
              <div class="valtoztatok">
                <p>Minta részletessége (pixel mérete): {{ pixelMeret }}px</p>
                <div class="valtoztatok-input custom-slider-wrapper">
                  <label class="custom-slider">
                    <input 
                      type="range" 
                      id="pixelMeretSlider"
                      min="5" 
                      max="40" 
                      step="1" 
                      :value="pixelMeret"
                      :style="`--value: ${(pixelMeret - 5) / (40 - 5) * 100}%`"
                      @input="pixelMeret = $event.target.value; mintaFrissites()"
                    >
                  </label>
                  <input 
                    type="number" 
                    min="5" 
                    max="40" 
                    v-model.number="pixelMeret"
                    class="szam-input"
                    @input="mintaFrussites"
                  />
                </div>
              </div>

              <div class="valtoztatok">
                <p>Rács vastagsága: {{ racsLathatosag }}%</p>
                <div class="valtoztatok-input custom-slider-wrapper">
                  <label class="custom-slider">
                    <input 
                      type="range" 
                      id="racsLathatosagSlider"
                      min="0" 
                      max="60" 
                      step="1" 
                      :value="racsLathatosag"
                      :style="`--value: ${racsLathatosag / 60 * 100}%`"
                      @input="racsLathatosag = $event.target.value; mintaFrissites()"
                    >
                  </label>
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
                <div class="valtoztatok-input custom-slider-wrapper">
                  <label class="custom-slider">
                    <input 
                      type="range" 
                      id="szinSzamSlider"
                      min="2" 
                      max="20" 
                      step="1" 
                      :value="szinSzam"
                      :style="`--value: ${(szinSzam - 2) / (20 - 2) * 100}%`"
                      @input="szinSzam = $event.target.value; mintaFrissites()"
                    >
                  </label>
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

          <!--#region Pixeles kép konténere -->
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
              <!--<img src="../assets/public/loading.gif" alt="Kép betöltése folyamatban">-->
              <p>Kép betöltése folyamatban</p>
            </div>
          </div>
          <!--#endregion-->

          <!--#region Mintaváltoztató gombok -->
          <div class="gombok">
            <button @click="adatokVissza" class="gomb">↩ &nbsp Vissza a feltöltéshez</button>
            <button @click="visszaallitas" class="gomb">Eredeti állapot</button>
            <button @click="kepletoltes(canvas)" class="gomb letolt">Letöltés</button>
            <button @click="kepTorles" class="gomb">Új kép</button>
          </div>
          <!--#endregion-->
        </div>
        <!--#endregion-->
      </div>
      

      <!--#region Oldalsáv -->
      <div class="oldalsav">
        <div class="oldal-kartya">
          <h3>Projekt adatai</h3>
          <p><strong>Technika:</strong> {{ elsoLepes }}</p>
          <p><strong>Fonal vastagsága:</strong> {{ masodikLepes.fonalTipus }}</p>
          <p><strong>Minta mérete:</strong> {{ pixelSorok.length }}×{{ pixelSorok[0]?.pixels.length || 0 }}</p>
          <p><strong>Szükséges fonalhossz:</strong> {{ fonalHossz }} cm</p>
          <p><strong>Befejezett sorok:</strong> {{ Object.values(pipaltSorok).filter(Boolean).length }}</p>
        </div>

        <div class="oldal-kartya" v-if="fonalTermek && szinPaletta && szinPaletta.length > 0">
          <h3>Szín egyeztetés</h3>
          
          <div v-if="colorMatchLoading" class="color-match-loading">
              <p>Színek egyeztetése...</p>
              <div class="loading-spinner-small"></div>
          </div>
          
          <div v-else-if="colorMatchResult">
              <div v-if="colorMatchResult.matches.length > 0">
                  <div class="color-match-success">
                      <p class="match-title">✓ Egyező színek találhatók</p>
                      <div v-for="(match, index) in colorMatchResult.matches" :key="index" class="color-match-item">
                          <div class="color-comparison">
                              <span class="color-sample" :style="{ backgroundColor: match.imageColor }" 
                                    :title="'Kép színe: ' + match.hexColor"></span>
                              <span style="margin: 0 8px; color: var(--mk-text-light);">→</span>
                              <span class="color-sample" :style="{ backgroundColor: match.yarnColor.hex }" 
                                    :title="'Fonal színe: ' + match.yarnColor.name"></span>
                          </div>
                          <div class="color-names">
                              <span class="color-name">{{ match.yarnColor.name }}</span>
                          </div>
                      </div>
                  </div>
                  
                  <div v-if="colorMatchResult.noMatches.length > 0" class="color-no-match">
                      <p class="no-match-title">⚠ Nem található pontosan egyező szín</p>
                      <p class="no-match-subtitle">Az alábbi kép színekhöz nincs pontosan megegyező fonal szín:</p>
                      <div class="unmatched-colors">
                          <div v-for="(noMatch, index) in colorMatchResult.noMatches" :key="index" class="unmatched-color">
                              <span class="color-sample" :style="{ backgroundColor: noMatch.imageColor }"
                                    :title="'Kép színe: ' + noMatch.hexColor"></span>
                          </div>
                      </div>
                  </div>
              </div>
              
              <div v-else class="color-no-match-all">
                  <p class="no-match-title">⚠ Nincs egyező szín</p>
                  <p class="no-match-subtitle">A képen használt színekhez nem található egyező fonal szín.</p>
                  
                  <div v-if="colorMatchResult.hasYarnColors" class="available-yarn-colors">
                      <p class="available-title">Elérhető színek ehhez a fonaltípushoz:</p>
                      <div class="yarn-colors-grid">
                          <div v-for="(yarnColor, index) in colorMatchResult.allYarnColors" 
                              :key="index" class="yarn-color-item">
                              <span class="color-sample" :style="{ backgroundColor: yarnColor.hex }"
                                    :title="yarnColor.name"></span>
                              <span class="yarn-color-name">{{ yarnColor.name }}</span>
                          </div>
                      </div>
                  </div>
                  
                  <div v-else class="no-colors-info">
                      <p>Ehhez a fonaltípushoz nincsenek elérhető színek az adatbázisban.</p>
                  </div>
              </div>
          </div>
          
          <div v-else class="color-match-empty">
              <p>Válassz fonaltípust és hozz létre egy mintát a szín egyeztetéshez.</p>
          </div>
        </div>

        <div class="oldal-kartya">
          <div v-if="fonalTermek && szuksegesGombolyagok > 0" class="fonal-info">
            <div class="fonal-header">
              <h4>Szükséges anyag:</h4>
              <div v-if="kosarBetoltes" class="loading-spinner"></div>
            </div>
            
            <div class="fonal-details">
              <div class="fonal-kep">
                <img v-if="fonalTermek.termek_fo_kep?.url_Link" 
                      :src="fonalTermek.termek_fo_kep.url_Link" 
                      :alt="fonalTermek.nev"
                      class="fonal-kep-img">
              </div>
              <div class="fonal-adatok">
                <p class="fonal-nev">{{ fonalTermek.nev }}</p>
                <p class="fonal-ar">{{ fonalTermek.ar.toLocaleString('hu-HU') }} Ft/gombolyag</p>
                <p class="fonal-mennyiseg">
                  <strong>{{ szuksegesGombolyagok }} gombolyag</strong> 
                  ({{ fonalTermek.meter }} m/gombolyag)
                </p>
                <p class="fonal-osszeg">
                  Összesen: <strong>{{ (fonalTermek.ar * szuksegesGombolyagok).toLocaleString('hu-HU') }} Ft</strong>
                </p>
              </div>
            </div>
            
            <button 
              @click="fonalHozzaadasKosarhoz" 
              :disabled="kosarBetoltes || kosarHozzaadva"
              class="kosar-gomb"
              :class="{ 'hozzaadva': kosarHozzaadva }">
              {{ kosarHozzaadva ? '✓ Hozzáadva' : (kosarBetoltes ? 'Feldolgozás...' : 'Kosárhoz adás &nbsp ↪') }}
            </button>
          </div>
          
          <div v-else-if="kosarBetoltes" class="fonal-betoltes">
            <p>Fonal információk betöltése...</p>
          </div>
          <div v-else class="fonal-nincs">
            <p>Válassz fonaltípust a fonal számításához</p>
          </div>
        </div>
      </div>
      <!--#endregion-->

      <!--#region Kosár -->
      <div v-if="kosarModal" class="modal-overlay" @click="kosarModal = false">
        <div class="modal-content kosar-modal" @click.stop>
          <button class="modal-close" @click="kosarModal = false">×</button>
          <div class="modal-success">
            <div class="success-icon">✓</div>
            <h3>Sikeresen hozzáadva a kosárhoz!</h3>
            
            <div class="kosar-termek-info">
              <img v-if="fonalTermek?.termek_fo_kep?.url_Link" 
                    :src="fonalTermek.termek_fo_kep.url_Link" 
                    :alt="fonalTermek.nev"
                    class="modal-termek-kep">
              
              <div class="modal-termek-details">
                <p class="modal-termek-nev">{{ fonalTermek?.nev }}</p>
                <p class="modal-termek-mennyiseg">
                  {{ szuksegesGombolyagok }} gombolyag × 
                  {{ fonalTermek?.ar?.toLocaleString('hu-HU') }} Ft
                </p>
                <p class="modal-termek-osszeg">
                  Összesen: <strong>{{ (fonalTermek?.ar * szuksegesGombolyagok).toLocaleString('hu-HU') }} Ft</strong>
                </p>
              </div>
            </div>
            
            <div class="modal-gombok">
              <button @click="kosarModal = false" class="modal-gomb folytatas">
                Folytatás
              </button>
              <router-link to="/kosar" class="modal-gomb kosar">
                Kosár megtekintése
              </router-link>
            </div>
          </div>
        </div>
      </div>
      <!--#endregion-->

      <!--#region Színváltoztatás-->
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
      <!--#endregion-->

    </div>
    <!--#region Alert -->
    <div class="alert-overlay" :class="{ active: showAlert }">
      <div class="alert success">
        <span class="closebtn" @click="showAlert = false">&times;</span>  
        <strong>A jobb láthatóság érdekében fordítsa el az eszközét.</strong> 
      </div>
    </div>
    <!--#endregion-->
    <!--#endregion-->
  </main>
</template>

<style scoped>
*, *::before, *::after {
  box-sizing: border-box;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
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

/*#region felső szövegdobozok*/
#bemutato {
  text-align: justify;
  background: linear-gradient(145deg, #fcebeb, #fff8f3);
  border-radius: 20px;
  padding: 40px;
  box-shadow: 
    0 10px 40px rgba(139, 67, 64, 0.1),
    inset 0 1px 0 rgba(255, 255, 255, 0.8);
  margin-bottom: 60px;
  border: 1px solid rgba(139, 67, 64, 0.1);
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
  background: linear-gradient(145deg, #ffffff, #fff8f3);
  border-radius: 16px;
  padding: 0;
  overflow: hidden;
  box-shadow: 0 10px 30px rgba(139, 67, 64, 0.1);
  transition: all 0.4s ease;
  position: relative;
  border: 1px solid rgba(139, 67, 64, 0.08);
}

.kartya::before {
  opacity: 0.3;
  mix-blend-mode: multiply;
}

.kartya:hover {
  transform: translateY(-10px);
  box-shadow: 0 6px 20px var(--mk-arnyekszin);
}

.szoveg {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  padding: 30px 25px;
  height: 100%;
  position: relative;
  z-index: 2;
}

.kartya h3 {
  color: #8B4340;
  font-size: 22px;
  font-weight: 700;
  margin-bottom: 20px;
  position: relative;
  padding-bottom: 12px;
}

.kartya p {
  color: #5a4e42;
  line-height: 1.7;
  font-size: 15px;
  margin-bottom: 15px;
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
  height: 240px;
  transition: height 0.6s ease;
}

.blog-info:hover {
  height: 100%;
  align-content: space-evenly;
}

.blog-info ol {
  text-align: left;
  padding-left: 20px;
}

.blog-info li {
  margin-bottom: 10px;
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
  object-fit: cover;
}

.blog-info-kontener:hover img {
  transform: scale(1.05);
}

.felso-linkek {
  color: #C86C68;
  font-weight: 600;
  text-decoration: none;
  position: relative;
  padding-bottom: 2px;
}

.felso-linkek::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 0;
  width: 0;
  height: 2px;
  background: #C86C68;
  transition: width 0.3s ease;
}

.felso-linkek:hover::after {
  width: 100%;
}

/*#endregion*/

/*#region adatbekérés*/
#adatok {
  background-color: var(--mk-hatterszin);
  border-radius: 8px;
  box-shadow: 0 2px 15px var(--mk-arnyekszin);
  border-radius: 20px;
  padding: 40px;
  box-shadow: 
    0 15px 40px rgba(139, 67, 64, 0.1),
    inset 0 1px 0 rgba(255, 255, 255, 0.8);
  border: 1px solid rgba(139, 67, 64, 0.08);
  width: 70%;
  margin: 0 auto;
  
}

.radioStilus {
  padding: 24px;
  transition: opacity 0.3s ease;
}

.cimek {
  color: #8B4340;
  font-size: 28px;
  font-weight: 700;
  margin-bottom: 30px;
  text-align: center;
  position: relative;
}

.radioBelso {
  background-color: var(--mk-radioszin);
  border-radius: 5px;
  padding: 25px;
  box-shadow: 0 4px 5px var(--mk-arnyekszin);
  max-width: 990px;
  margin: 0 auto;
}

.radio-container {
  display: flex;
  align-items: center;
  padding: 15px 20px;
  margin-bottom: 10px;
  background: white;
  border-radius: 10px;
  box-shadow: 0 4px 15px rgba(139, 67, 64, 0.05);
  transition: all 0.3s ease;
  max-width: 600px;
  margin: 0 auto 10px auto;
}

input[type="radio"] {
  appearance: none;
  width: 22px;
  height: 22px;
  border: 2px solid rgb(202, 200, 200);
  border-radius: 25%;
  margin-right: 12px;
  position: relative;
  transition: all 0.2s ease;
  background-color: transparent;
}

input[type="radio"]:checked {
  border-color: #8B4340;
  animation: radioPulse 0.6s ease;
}

@keyframes radioPulse {
  0% { transform: scale(1); }
  50% { transform: scale(1.2); }
  100% { transform: scale(1); }
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
  color: #5a4e42;
  font-size: 18px;
  font-weight: 500;
  cursor: pointer;
  flex: 1;
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
  background: rgba(139, 67, 64, 0.05);
  border-radius: 12px;
  padding: 25px;
  margin-bottom: 40px;
}

.progress-bar {
  position: relative;
  height: 6px;
  background: rgba(139, 67, 64, 0.1);
  border-radius: 3px;
  margin: 30px 20px;
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
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
}

.progress-step.active {
  background: linear-gradient(135deg, #8B4340, #C86C68);
  border-color: transparent;
  color: white;
  transform: translateY(-50%) scale(1.1);
  box-shadow: 0 6px 20px rgba(139, 67, 64, 0.3);
}

.progress-step.clickable {
  cursor: pointer;
}

.progress-step.clickable:hover {
  background-color: rgb(110, 29, 29);
}

.progress-step:nth-child(1) { left: 0; }
.progress-step:nth-child(2) { left: 50%; transform: translate(-50%, -50%); }
.progress-step:nth-child(3) { left: 100%; transform: translate(-100%, -50%); }

.progress-labels {
  display: flex;
  justify-content: space-between;
}

.progress-label {
  color: #8B4340;
  font-weight: 600;
  font-size: 14px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
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
  flex: 1 1 auto;
  padding: 32px;
  background-color: var(--mk-hatterszin);
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
  font-size: 15px;
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
  background-color: #af683f;
}

.gomb.letolt:hover {
  background-color: #9e4e1f;
}
/*#endregion*/

/*#region Rangerek*/
.custom-slider-wrapper {
  display: flex;
  align-items: center;
  gap: 12px;
  width: 100%;
}

.custom-slider {
  position: relative; 
  font-size: 18px;
  flex: 1;
  min-width: 200px;
}

.custom-slider input {
  width: 100%;
  height: 6px;
  appearance: none;
  background: none;
  cursor: pointer;
  font-size: inherit;
  margin: 0;
  outline: none;
}

.custom-slider input[type="range"]::-webkit-slider-runnable-track {
  height: 6px;
  background: linear-gradient(to right, #c0895c 0%, #c0895c var(--value, 50%), #ddd var(--value, 50%), #ddd 100%);
  border-radius: 3px;
}

.custom-slider input[type="range"]::-webkit-slider-thumb {
  width: 20px;
  height: 20px;
  border-radius: 50%;
  border: 7px solid #c0895c;
  background: transparent;
  cursor: pointer;
  -webkit-appearance: none;
  appearance: none;
  margin-top: -7px;
  transition: all 0.3s ease;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.custom-slider input[type="range"]:hover::-webkit-slider-thumb {
  border-color: #a67c52;
  transform: scale(1.1);
}

.custom-slider input[type="range"]:active::-webkit-slider-thumb {
  background: #8b6239;
  border-color: #8b6239;
  transform: scale(1.05);
  box-shadow: 0 0 8px rgba(139, 98, 57, 0.4);
}

.custom-slider input[type="range"]:focus::-webkit-slider-thumb {
  outline: none;
  box-shadow: 0 0 0 3px rgba(192, 137, 92, 0.3);
}
/*#endregion*/

/*#region Színválasztás*/
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

/*#region Színmatch */
.color-match-loading {
    text-align: center;
    padding: 20px;
    color: var(--mk-text-light);
}

.loading-spinner-small {
    width: 30px;
    height: 30px;
    border: 3px solid rgba(255, 255, 255, 0.3);
    border-top-color: var(--mk-text-light);
    border-radius: 50%;
    animation: spin 1s linear infinite;
    margin: 10px auto;
}

.color-match-success {
    margin-bottom: 20px;
}

.match-title {
    color: #4CAF50;
    font-weight: 600;
    margin-bottom: 15px;
    font-size: 16px;
}

.color-match-item {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 8px 0;
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.color-match-item:last-child {
    border-bottom: none;
}

.color-comparison {
    display: flex;
    align-items: center;
}

.color-comparison .color-sample {
    width: 30px;
    height: 30px;
    border: 2px solid rgba(255, 255, 255, 0.3);
    border-radius: 4px;
}

.color-names {
    text-align: right;
    flex: 1;
    margin-left: 15px;
}

.color-name {
    font-size: 14px;
    color: var(--mk-text-light);
    opacity: 0.9;
}

.color-no-match, .color-no-match-all {
    background: rgba(255, 193, 7, 0.1);
    border-left: 4px solid #FFC107;
    padding: 15px;
    border-radius: 4px;
    margin-top: 15px;
}

.no-match-title {
    color: #FFC107;
    font-weight: 600;
    margin-bottom: 8px;
    font-size: 16px;
}

.no-match-subtitle {
    color: rgba(255, 255, 255, 0.8);
    font-size: 14px;
    margin-bottom: 12px;
}

.unmatched-colors {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    margin-top: 10px;
}

.unmatched-color .color-sample {
    width: 25px;
    height: 25px;
    border: 2px solid rgba(255, 255, 255, 0.3);
    border-radius: 4px;
}

.available-yarn-colors {
    margin-top: 15px;
}

.available-title {
    color: rgba(255, 255, 255, 0.9);
    font-size: 14px;
    margin-bottom: 12px;
    font-weight: 500;
}

.yarn-colors-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 10px;
    max-height: 200px;
    overflow-y: auto;
    padding: 10px;
    background: rgba(0, 0, 0, 0.2);
    border-radius: 4px;
}

.yarn-color-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    text-align: center;
}

.yarn-color-item .color-sample {
    width: 30px;
    height: 30px;
    border: 2px solid rgba(255, 255, 255, 0.3);
    border-radius: 4px;
    margin-bottom: 5px;
}

.yarn-color-name {
    font-size: 11px;
    color: rgba(255, 255, 255, 0.8);
    word-break: break-word;
    line-height: 1.2;
}

.no-colors-info {
    background: rgba(255, 87, 87, 0.1);
    border-left: 4px solid #FF5757;
    padding: 15px;
    border-radius: 4px;
    margin-top: 15px;
    text-align: center;
}

.no-colors-info p {
    color: rgba(255, 255, 255, 0.8);
    font-size: 14px;
    margin: 0;
}

.color-match-empty {
    text-align: center;
    padding: 20px;
    color: rgba(255, 255, 255, 0.7);
    font-style: italic;
}
/*#endregion*/

/*#region Fonal számítás*/
.fonal-info {
  padding: 10px;
}

.fonal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.fonal-header h4 {
  margin: 0;
  color: var(--mk-text-light);
}

.loading-spinner {
  width: 20px;
  height: 20px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top-color: var(--mk-text-light);
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.fonal-details {
  display: flex;
  gap: 15px;
  margin-bottom: 15px;
}

.fonal-kep {
  flex-shrink: 0;
}

.fonal-kep-img {
  width: 60px;
  height: 60px;
  object-fit: cover;
  border-radius: 4px;
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.fonal-adatok {
  flex: 1;
  text-align: left;
}

.fonal-nev {
  font-weight: 600;
  margin: 0 0 5px 0;
  color: var(--mk-text-light);
}

.fonal-ar,
.fonal-mennyiseg,
.fonal-osszeg {
  margin: 3px 0;
  color: rgba(255, 255, 255, 0.8);
}

.fonal-osszeg {
  margin-top: 8px;
  padding-top: 8px;
  border-top: 1px solid rgba(255, 255, 255, 0.2);
}

.kosar-gomb {
  width: 100%;
  padding: 12px;
  background: #f8e4e4;
  color: black;
  border: none;
  border-radius: 6px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.kosar-gomb:hover:not(:disabled) {
  background: #cc7973;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(175, 76, 76, 0.3);
}

.kosar-gomb:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.kosar-gomb.hozzaadva {
  background: #91744e;
}

.fonal-betoltes,
.fonal-nincs {
  padding: 20px;
  text-align: center;
  color: rgba(255, 255, 255, 0.7);
  font-style: italic;
}

.kosar-modal {
  max-width: 400px;
}

.modal-success {
  text-align: center;
}

.success-icon {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  background:#4CAF50;
  color: white;
  font-size: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 20px;
  font-weight: bold;
}

.modal-success h3 {
  margin: 0 0 20px 0;
  color: var(--mk-text-dark);
}

.kosar-termek-info {
  display: flex;
  gap: 15px;
  padding: 15px;
  background: #f5f5f5;
  border-radius: 8px;
  margin-bottom: 20px;
}

.modal-termek-kep {
  width: 80px;
  height: 80px;
  object-fit: cover;
  border-radius: 4px;
}

.modal-termek-details {
  flex: 1;
  text-align: left;
}

.modal-termek-nev {
  font-weight: 600;
  margin: 0 0 5px 0;
  color: #333;
}

.modal-termek-mennyiseg,
.modal-termek-osszeg {
  margin: 5px 0;
  color: #666;
  font-size: 14px;
}

.modal-termek-osszeg {
  font-size: 16px;
  margin-top: 8px;
  padding-top: 8px;
  border-top: 1px solid #ddd;
}

.modal-gombok {
  display: flex;
  gap: 10px;
  margin-top: 20px;
}

.modal-gomb {
  flex: 1;
  padding: 12px;
  border: none;
  border-radius: 6px;
  font-weight: 600;
  cursor: pointer;
  text-decoration: none;
  text-align: center;
  font-size: 14px;
  transition: all 0.3s ease;
}

.modal-gomb.folytatas {
  background: #f0f0f0;
  color: #333;
}

.modal-gomb.folytatas:hover {
  background: #e0e0e0;
}

.modal-gomb.kosar {
  background: #7649b1;
  color: white;
}

.modal-gomb.kosar:hover {
  background: #9946c0;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(175, 115, 194, 0.3);
}

.modal-close {
  position: absolute;
  top: 15px;
  right: 15px;
  background: none;
  border: none;
  font-size: 24px;
  color: #666;
  cursor: pointer;
  padding: 0;
  width: 30px;
  height: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  transition: all 0.3s ease;
}

.modal-close:hover {
  background: #f5f5f5;
  color: #333;
}

@media (max-width: 768px) {
  .fonal-details {
    flex-direction: column;
    text-align: center;
  }
  
  .fonal-adatok {
    text-align: center;
  }
  
  .modal-gombok {
    flex-direction: column;
  }
}
/*#endregion*/

/*#region Felugró ablak*/
.alert-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.7);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
  opacity: 0;
  visibility: hidden;
  transition: opacity 0.3s, visibility 0.3s;
}

.alert-overlay.active {
  opacity: 1;
  visibility: visible;
}

.alert {
  padding: 20px 30px;
  background-color: #b35e25;
  color: white;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  transform: translateY(-20px);
  transition: transform 0.3s, opacity 0.6s;
  max-width: 500px;
  width: 90%;
  position: relative;
}

.alert-overlay.active .alert {
  transform: translateY(0);
}

.closebtn {
  margin-left: 15px;
  color: white;
  font-weight: bold;
  float: right;
  font-size: 22px;
  line-height: 20px;
  cursor: pointer;
  transition: 0.3s;
}

.closebtn:hover {
  color: black;
}
/*#endregion*/

/*#region Reszponzivitás*/
@media (max-width: 1250px) {
  .ket-oszlop {
    grid-template-columns: 1fr;
  }

  .harom-oszlop {
    grid-template-columns: repeat(2, minmax(180px, 1fr));
  }
  
  .pixelesContainer {
    grid-template-columns: 1fr;
    max-width: 100%;
  }
  
  .oldalsav {
    grid-column: 1;
    margin-top: 20px;
  }
}

@media (max-width: 1100px) {
  .pixelation-main-container {
    flex-direction: column;
  }
  
  .oldalsav {
    width: 100%;
    margin-top: 20px;
    flex: 100%;
  }
}

@media (max-width: 900px) {
  .progress-step:not(:last-child)::after {
    width: 400%;
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

  .yarn-colors-grid {
        grid-template-columns: repeat(2, 1fr);
    }
    
    .color-match-item {
        flex-direction: column;
        align-items: flex-start;
    }
    
    .color-names {
        margin-left: 0;
        margin-top: 8px;
        text-align: left;
    }
}
/*#endregion*/
</style>