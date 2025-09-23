<template>
  <div class="pixelator-container">
    <h1>Minta Változtató</h1>
    
    <div v-if="!imageUrl" class="upload-section">
      <p>Nincs kép betöltve. Kérjük, menj vissza és tölts fel egy képet.</p>
      <button @click="$router.back()" class="back-button">Vissza a feltöltéshez</button>
    </div>

    <div v-else class="editor-container">
      <!-- Controls -->
      <div class="controls">
        <div class="control-group">
          <label>Pixel Méret: {{ pixelSize }}px</label>
          <input 
            type="range" 
            min="2" 
            max="50" 
            v-model="pixelSize" 
            class="slider"
          />
        </div>

        <div class="control-group">
          <label>Szín Mód:</label>
          <select v-model="colorMode" class="select-box">
            <option value="original">Eredeti színek</option>
            <option value="grayscale">Szürkeárnyalatos</option>
            <option value="limited">Korlátozott színpaletta</option>
          </select>
        </div>

        <div class="control-group" v-if="colorMode === 'limited'">
          <label>Színek száma: {{ colorCount }}</label>
          <input 
            type="range" 
            min="2" 
            max="20" 
            v-model="colorCount" 
            class="slider"
          />
        </div>
      </div>

      <!-- Color Palette -->
      <div v-if="colorPalette.length > 0" class="color-palette">
        <h3>Színpaletta</h3>
        <div class="colors">
          <div 
            v-for="(color, index) in colorPalette" 
            :key="index" 
            class="color-item"
            :style="{ backgroundColor: color }"
            @click="selectColor(color)"
            :class="{ selected: selectedColor === color }"
          >
            <input 
              type="color" 
              :value="color" 
              @input="updateColor(index, $event.target.value)"
              @click.stop
            />
          </div>
        </div>
      </div>

      <!-- Canvas -->
      <div class="canvas-container">
        <canvas ref="canvas"></canvas>
      </div>

      <!-- Actions -->
      <div class="actions">
        <button @click="resetImage" class="action-button">Eredeti kép</button>
        <button @click="downloadImage" class="action-button download">Letöltés</button>
        <button @click="$router.back()" class="action-button">Új kép</button>
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
      originalImage: null,
      pixelSize: 10,
      colorMode: "original",
      colorCount: 8,
      colorPalette: [],
      selectedColor: null,
      ctx: null
    };
  },
  mounted() {
    // Get image URL from route query
    this.imageUrl = this.$route.query.imageUrl;
    if (this.imageUrl) {
      this.loadImage();
    }
  },
  watch: {
    pixelSize() {
      this.pixelate();
    },
    colorMode() {
      this.pixelate();
    },
    colorCount() {
      if (this.colorMode === 'limited') {
        this.pixelate();
      }
    }
  },
  methods: {
    loadImage() {
      this.originalImage = new Image();
      this.originalImage.onload = () => {
        this.setupCanvas();
        this.pixelate();
      };
      this.originalImage.src = this.imageUrl;
    },
    setupCanvas() {
      const canvas = this.$refs.canvas;
      this.ctx = canvas.getContext("2d");
      canvas.width = this.originalImage.width;
      canvas.height = this.originalImage.height;
    },
    pixelate() {
      if (!this.originalImage) return;

      const canvas = this.$refs.canvas;
      const ctx = this.ctx;
      const { width, height } = this.originalImage;

      // Draw original image
      ctx.drawImage(this.originalImage, 0, 0, width, height);

      if (this.colorMode === 'original') {
        this.applyPixelation();
      } else if (this.colorMode === 'grayscale') {
        this.applyGrayscalePixelation();
      } else if (this.colorMode === 'limited') {
        this.applyLimitedColorPixelation();
      }

      this.extractColorPalette();
    },
    applyPixelation() {
      const ctx = this.ctx;
      const width = this.originalImage.width;
      const height = this.originalImage.height;
      const size = this.pixelSize;

      for (let y = 0; y < height; y += size) {
        for (let x = 0; x < width; x += size) {
          const imageData = ctx.getImageData(x, y, size, size);
          const data = imageData.data;
          
          let r = 0, g = 0, b = 0, count = 0;

          for (let i = 0; i < data.length; i += 4) {
            r += data[i];
            g += data[i + 1];
            b += data[i + 2];
            count++;
          }

          const avgR = Math.round(r / count);
          const avgG = Math.round(g / count);
          const avgB = Math.round(b / count);

          ctx.fillStyle = `rgb(${avgR}, ${avgG}, ${avgB})`;
          ctx.fillRect(x, y, size, size);
        }
      }
    },
    applyGrayscalePixelation() {
      const ctx = this.ctx;
      const width = this.originalImage.width;
      const height = this.originalImage.height;
      const size = this.pixelSize;

      for (let y = 0; y < height; y += size) {
        for (let x = 0; x < width; x += size) {
          const imageData = ctx.getImageData(x, y, size, size);
          const data = imageData.data;
          
          let total = 0, count = 0;

          for (let i = 0; i < data.length; i += 4) {
            const avg = (data[i] + data[i + 1] + data[i + 2]) / 3;
            total += avg;
            count++;
          }

          const grayValue = Math.round(total / count);
          ctx.fillStyle = `rgb(${grayValue}, ${grayValue}, ${grayValue})`;
          ctx.fillRect(x, y, size, size);
        }
      }
    },
    applyLimitedColorPixelation() {
      // This is a simplified version - you might want to use more advanced color quantization
      const ctx = this.ctx;
      const width = this.originalImage.width;
      const height = this.originalImage.height;
      const size = this.pixelSize;

      for (let y = 0; y < height; y += size) {
        for (let x = 0; x < width; x += size) {
          const imageData = ctx.getImageData(x, y, size, size);
          const data = imageData.data;
          
          let r = 0, g = 0, b = 0, count = 0;

          for (let i = 0; i < data.length; i += 4) {
            r += data[i];
            g += data[i + 1];
            b += data[i + 2];
            count++;
          }

          const avgR = Math.round(r / count);
          const avgG = Math.round(g / count);
          const avgB = Math.round(b / count);

          // Reduce color precision based on colorCount
          const precision = Math.round(255 / this.colorCount);
          const limitedR = Math.round(avgR / precision) * precision;
          const limitedG = Math.round(avgG / precision) * precision;
          const limitedB = Math.round(avgB / precision) * precision;

          ctx.fillStyle = `rgb(${limitedR}, ${limitedG}, ${limitedB})`;
          ctx.fillRect(x, y, size, size);
        }
      }
    },
    extractColorPalette() {
      // Extract unique colors from the pixelated image
      const canvas = this.$refs.canvas;
      const ctx = canvas.getContext("2d");
      const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);
      const data = imageData.data;
      
      const colors = new Set();
      
      for (let i = 0; i < data.length; i += 4) {
        const r = data[i];
        const g = data[i + 1];
        const b = data[i + 2];
        const color = `rgb(${r}, ${g}, ${b})`;
        colors.add(color);
      }
      
      this.colorPalette = Array.from(colors).slice(0, 20); // Limit to 20 colors
    },
    selectColor(color) {
      this.selectedColor = color;
    },
    updateColor(index, newColor) {
      this.colorPalette[index] = newColor;
      // Here you would need to redraw the image with the updated colors
      // This is a complex operation that would require tracking which pixels use which colors
    },
    resetImage() {
      this.pixelate();
    },
    downloadImage() {
      const canvas = this.$refs.canvas;
      const link = document.createElement('a');
      link.download = 'pixelated-image.png';
      link.href = canvas.toDataURL();
      link.click();
    }
  }
};
</script>

<style scoped>
.pixelator-container {
  padding: 2rem;
  max-width: 1200px;
  margin: 0 auto;
  background-color: #f5f5f5;
  min-height: 100vh;
}

.upload-section {
  text-align: center;
  padding: 2rem;
}

.back-button {
  padding: 10px 20px;
  background-color: #4CAF50;
  color: white;
  border: none;
  border-radius: 5px;
  cursor: pointer;
}

.controls {
  display: flex;
  flex-wrap: wrap;
  gap: 2rem;
  margin-bottom: 2rem;
  padding: 1rem;
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.control-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.slider {
  width: 200px;
}

.select-box {
  padding: 5px;
  border-radius: 4px;
  border: 1px solid #ddd;
}

.color-palette {
  margin: 2rem 0;
  padding: 1rem;
  background: white;
  border-radius: 8px;
}

.colors {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin-top: 1rem;
}

.color-item {
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

.color-item.selected {
  border-color: #007bff;
}

.color-item input[type="color"] {
  opacity: 0;
  position: absolute;
  width: 100%;
  height: 100%;
  cursor: pointer;
}

.canvas-container {
  text-align: center;
  margin: 2rem 0;
}

canvas {
  max-width: 100%;
  border: 2px solid #ddd;
  border-radius: 8px;
  box-shadow: 0 4px 8px rgba(0,0,0,0.1);
}

.actions {
  display: flex;
  justify-content: center;
  gap: 1rem;
  margin-top: 2rem;
}

.action-button {
  padding: 10px 20px;
  border: none;
  border-radius: 5px;
  cursor: pointer;
  font-weight: bold;
}

.action-button.download {
  background-color: #4CAF50;
  color: white;
}
</style>