<template>
  <div class="pixelesContainer">
    <h1>Minta Változtató</h1>
    
    <div v-if="!imageUrl" class="feltoltes">
      <p>Nincs kép betöltve. Kérjük, menj vissza és tölts fel egy képet.</p>
      <button @click="$router.back()" class="visszaGomb">Vissza a feltöltéshez</button>
    </div>

    <div v-else class="modositoContainer">
      <div class="modositas">
        <div class="valtoztatok">
          <label>Pixel Méret: {{ pixelMeret }}px</label>
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
          <label>Szín Mód:</label>
          <select v-model="szinezes" class="lenyiloBox" @change="kepFrissites">
            <option value="eredeti">Eredeti színek</option>
            <option value="kevesebbSzin">Korlátozott színpaletta</option>
          </select>
        </div>

        <div class="valtoztatok" v-if="szinezes === 'kevesebbSzin'">
          <label>Színek száma: {{ szinekSzama }}</label>
          <input 
            type="range" 
            min="2" 
            max="20" 
            v-model="szinekSzama" 
            class="csuszka"
            @input="kepFrissites"
          />
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

      <canvas ref="canvas"></canvas>

      <div class="gombok">
        <button @click="ujrakedzes" class="gombok">Eredeti kép</button>
        <button @click="kepletoltes" class="gombok letolt">Letöltés</button>
        <button @click="$router.back()" class="gombok">Új kép</button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: "Mintavaltoztato",
  data() {
    return {
      imageUrl: null,
      eredetiKep: null,
      pixelMeret: 10,
      szinezes: "eredeti",
      szinekSzama: 20,
      szinPaletta: [],
      valasztottSzin: null,
      ctx: null,
      jelenlegiKep: null
    };
  },
  mounted() {
    this.imageUrl = this.$route.query.imageUrl; //url a route-ból mert másik oldalról jön
    if (this.imageUrl) {
      this.kepBetolt();
    }
  },
  methods: {
    kepBetolt() {
      this.eredetiKep = new Image();
      this.eredetiKep.onload = () => {
        this.vaszonLetrehozasa();
        this.kepFrissites();
      };
      this.eredetiKep.crossOrigin = "anonymous";  //más domain-ről is be tud tölteni a kép
      this.eredetiKep.src = this.imageUrl;
    },
    vaszonLetrehozasa() {
      const canvas = this.$refs.canvas;
      this.ctx = canvas.getContext("2d");
      canvas.width = this.eredetiKep.width;
      canvas.height = this.eredetiKep.height;
    },
    kepFrissites() {
      if (!this.eredetiKep) return;
      
      this.vaszonFeldolgozas(this.eredetiKep);
      this.kinyertSzinPaletta();
    },
    vaszonFeldolgozas(img) {
      const pixelMeret = parseInt(this.pixelMeret);
      const canvas = this.$refs.canvas;
      const ctx = this.ctx;
      
      const szelesseg = img.width;
      const magassag = img.height;
      
      canvas.width = szelesseg;
      canvas.height = magassag;

      ctx.drawImage(img, 0, 0, szelesseg, magassag);

      const imageData = ctx.getImageData(0, 0, szelesseg, magassag);
      const data = imageData.data;
      
      this.jelenlegiKep = { data, width: szelesseg, height: magassag };

      if (this.szinezes === 'eredeti') {
        this.kepElkeszites(data, szelesseg, magassag, pixelMeret);
      }
      else if (this.szinezes === 'kevesebbSzin') {
        this.kepElkeszitesKevesebbSzin(data, szelesseg, magassag, pixelMeret);
      }

      ctx.putImageData(imageData, 0, 0);
    },
    kepElkeszites(data, width, height, pixelMeret) {
      const cols = Math.ceil(width / pixelMeret);
      const rows = Math.ceil(height / pixelMeret);

      for (let y = 0; y < rows; y++) {
        for (let x = 0; x < cols; x++) {
          const avg = this.szinekKinyeres(data, width, x * pixelMeret, y * pixelMeret, pixelMeret);
          
          for (let Ytengely = y * pixelMeret; Ytengely < (y + 1) * pixelMeret && Ytengely < height; Ytengely++) {
            for (let Xtengely = x * pixelMeret; Xtengely < (x + 1) * pixelMeret && Xtengely < width; Xtengely++) {
              const i = (Ytengely * width + Xtengely) * 4;
              data[i] = avg.r;
              data[i + 1] = avg.g;
              data[i + 2] = avg.b;
            }
          }
        }
      }
    },
    kepElkeszitesKevesebbSzin(data, width, height, pixelMeret) {
      const cols = Math.ceil(width / pixelMeret);
      const rows = Math.ceil(height / pixelMeret);

      for (let y = 0; y < rows; y++) {
        for (let x = 0; x < cols; x++) {
          const avg = this.szinekKinyeres(data, width, x * pixelMeret, y * pixelMeret, pixelMeret);
          
          //
          const precision = Math.round(255 / this.szinekSzama);
          const limitedR = Math.round(avg.r / precision) * precision;
          const limitedG = Math.round(avg.g / precision) * precision;
          const limitedB = Math.round(avg.b / precision) * precision;
          
          // szinek cseréje hoyg kevesebbet használjon
          for (let Ytengely = y * pixelMeret; Ytengely < (y + 1) * pixelMeret && Ytengely < height; Ytengely++) {
            for (let Xtengely = x * pixelMeret; Xtengely < (x + 1) * pixelMeret && Xtengely < width; Xtengely++) {
              const i = (Ytengely * width + Xtengely) * 4;
              data[i] = limitedR;
              data[i + 1] = limitedG;
              data[i + 2] = limitedB;
            }
          }
        }
      }
    },
    szinekKinyeres(data, width, startX, startY, blockSize) {
      let r = 0, g = 0, b = 0, a = 0, count = 0;

      for (let y = startY; y < startY + blockSize && y < width; y++) {
        for (let x = startX; x < startX + blockSize && x < width; x++) {
          const i = (y * width + x) * 4;
          if (i >= data.length - 3) continue;

          r += data[i];
          g += data[i + 1];
          b += data[i + 2];
          a += data[i + 3];
          count++;
        }
      }

      return {
        r: Math.round(r / count),
        g: Math.round(g / count),
        b: Math.round(b / count),
        a: a / count / 255
      };
    },
    kinyertSzinPaletta() {
      if (!this.jelenlegiKep) return;
      
      const { data, width, height } = this.jelenlegiKep;
      const szinek = new Set();
      
      // Színek kinyerése (eddig borzasztó, változtatni kell)
      for (let i = 0; i < data.length; i += 80) {
        const r = data[i];
        const g = data[i + 1];
        const b = data[i + 2];
        const color = `rgb(${r}, ${g}, ${b})`;
        szinek.add(color);
      }
      
      this.szinPaletta = Array.from(szinek).slice(0, this.szinekSzama); // 20 szín a limit
    },
    szinValaszto(color) {
      this.valasztottSzin = color;
    },
    frissítettSzin(index, newColor) {
      this.szinPaletta[index] = newColor;
      // színcserélő (a képen frissüljön a szín)
    },
    ujrakedzes() {
      this.kepFrissites();
    },
    kepletoltes() {
      const canvas = this.$refs.canvas;
      const link = document.createElement('a');
      link.letolt = 'pixelated-image.png';
      link.href = canvas.toDataURL();
      link.click();
    }
  }
};
</script>

<style scoped>
.pixelesContainer {
  padding: 2rem;
  max-width: 1200px;
  margin: 0 auto;
  background-color: #f5f5f5;
  min-height: 100vh;
}

.feltoltes {
  text-align: center;
  padding: 2rem;
}

.visszaGomb {
  padding: 10px 20px;
  background-color: #4CAF50;
  color: white;
  border: none;
  border-radius: 5px;
  cursor: pointer;
}

.modositas {
  display: flex;
  flex-wrap: wrap;
  gap: 2rem;
  margin-bottom: 2rem;
  padding: 1rem;
  background: white;
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

.szin-paletta {
  margin: 2rem 0;
  padding: 1rem;
  background: white;
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

.szinek-class.selected {
  border-color: #007bff;
}

.szinek-class input[type="color"] {
  opacity: 0;
  position: absolute;
  width: 100%;
  height: 100%;
  cursor: pointer;
}

canvas {
  max-width: 100%;
  border: 2px solid #ddd;
  border-radius: 8px;
  box-shadow: 0 4px 8px rgba(0,0,0,0.1);
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
</style>