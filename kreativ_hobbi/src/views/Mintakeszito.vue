<script setup>
import { ref } from "vue"
import { useRouter } from "vue-router"

const resz = ref(1)
const elsoLepes = ref(null)
const masodikLepes = ref(null)
const file = ref(null)

const tipusok = ["Horgolás", "Kötés", "Hímzés"]
const fonalak = [" 'A' fonal csoport", " 'B' fonal csoport", " 'C' fonal csoport", " 'D' fonal csoport", " 'E' fonal csoport"]

const router = useRouter()

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
    router.push({
      path: 'mintakeszito/mintavaltoztato',
      query: { 
        imageUrl: url,
        fileName: file.value.name
      }
    })
  }
}

</script>


<template>
  <main>
    <h1 class="title">Mintakészítő</h1>
    
    <div id="bemutato">
      <h2 class="cim">Mi is ez az oldal?</h2>
      <p>Lorem ipsum dolor sit amet consectetur adipisicing elit...</p>
      
      <div class="harom_oszlop">
        <div class="kartya">
          <h3>Horgolás</h3>
          <p>Lorem ipsum, dolor sit amet consectetur adipisicing elit...</p>
        </div>
        <div class="kartya">
          <h3>Kötés</h3>
          <p>Lorem ipsum dolor sit amet consectetur adipisicing elit...</p>
        </div>
        <div class="kartya">
          <h3>Hímzés</h3>
          <p>Lorem, ipsum dolor sit amet consectetur adipisicing elit...</p>
        </div>
      </div>
    </div>

    <div id="adatok">
      <div class="progress-container">
        <div class="progress-bar">
          <div class="progress-step" :class="{ active: resz >= 1 }">1</div>
          <div class="progress-step" :class="{ active: resz >= 2 }">2</div>
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
          <div v-for="option in tipusok" :key="option" >
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
          <div v-for="option in fonalak" :key="option" >
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
  </main>
</template>

<!--Benne akarom tartani az animációs rádiógombokat, és rendbe kell szedni a stílust és színeket
Most a rádiógombokon nem látszanak ha ki vannak jelölve, meg furák az árnyékok-->

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap');

:root {
  --primary-color: #c74f57;
  --primary-light: #ca8489;
  --primary-dark: #a63840;
  --secondary-color: #f3c78e;
  --secondary-light: #f8e6d0;
  --text-dark: #333;
  --text-light: #666;
  --background-light: #f9f5f2;
  --white: #ffffff;
  --shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  --shadow-hover: 0 8px 15px rgba(0, 0, 0, 0.2);
} /*ezek nem működnek, de ki lehetne őket rakni base.css-be */



body {
  font-family: 'Poppins', sans-serif;
  color: var(--text-dark);
  background-color: rgb(255, 211, 144);
}

.title {
  font-weight: 700;
  color: rgb(0, 0, 0);
  margin-bottom: 2rem;
  position: relative;
  display: inline-block;
}

.title::after {
  content: '';
  position: absolute;
  bottom: -10px;
  left: 50%;
  transform: translateX(-50%);
  width: 80px;
  height: 4px;
  background: linear-gradient(90deg, rgb(209, 94, 0), rgb(95, 58, 2));
  border-radius: 2px;
}

#adatok {
  max-width: 800px;
  margin: 0 auto;
  padding: 2rem;
  background-color: rgb(206, 16, 133);
  border-radius: 15px;
  box-shadow: rgb(133, 5, 58);
}

.radioStilus {
  padding: 1.5rem;
  transition: opacity 0.3s ease;
}

.cimek {
  font-size: 1.5rem;
  font-weight: 600;
  color: rgb(0, 0, 0);
  margin-bottom: 1.5rem;
  text-align: center;
}

.radioBelso {
  background-color: rgb(247, 30, 210);
  border-radius: 15px;
  padding: 1.5rem;
  margin-bottom: 2rem;
}

input[type="radio"] {
  appearance: none;
  width: 22px;
  height: 22px;
  border: 2px solid rgb(69, 0, 78);
  border-radius: 50%;
  margin-right: 12px;
  position: relative;
  top: 3px;
  transition: all 0.2s ease;
}

input[type="radio"]:checked::before {
  content: "";
  display: block;
  width: 12px;
  height: 12px;
  background-color: rgb(236, 34, 226);
  border-radius: 50%;
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
}

label {
  font-size: 1.1rem;
  color: rgb(0, 0, 0);
  font-weight: 500;
  cursor: pointer;
  transition: color 0.2s ease;
}

label:hover {
  color: rgb(110, 2, 105);
}

main {
  margin: 0 auto;
  padding: 20px;
  height: auto;
}

.cim {
  text-align: center;
  font-size: 26px;
  margin-bottom: 30px;
}

#bemutato {
  max-width: 1200px;
  margin: auto;
  padding: 10px 50px 10px 50px;
  text-align: justify;
  margin-bottom: 50px;
  border-radius: 10px;
}

.harom_oszlop {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 2rem;
  margin-bottom: 3rem;
  padding: 1rem;
}

.kartya {
  background-color: rgb(137, 44, 212);
  border-radius: 15px;
  padding: 2rem;
  box-shadow: rgb(87, 5, 155);
  transition: transform 0.3s ease, box-shadow 0.3s ease;
  position: relative;
  overflow: hidden;
}

.kartya::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 5px;
  background: linear-gradient(90deg, red, red);
}

.kartya:hover {
  transform: translateY(-10px);
  box-shadow: rgb(69, 8, 182);
}

.kartya h3 {
  color: rgb(0, 0, 0);
  margin-bottom: 1rem;
  font-size: 1.5rem;
  font-weight: 600;
}

.tovabbGomb {
  display: block;
  width: 200px;
  height: 50px;
  margin: 2rem auto 0;
  border: none;
  border-radius: 50px;
  background: linear-gradient(135deg, rgb(70, 255, 79), rgb(133, 245, 157));
  color: var(--white);
  font-weight: 600;
  font-size: 1rem;
  letter-spacing: 1px;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 15px rgba(199, 79, 87, 0.4);
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
  box-shadow: 0 6px 20px rgba(199, 79, 87, 0.5);
}

.visszaGomb {
  padding: 0.5rem 1rem;
  border: none;
  border-radius: 20px;
  background-color: rgb(57, 45, 235);
  color: rgb(0, 0, 0);
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  margin-left: 1rem;
}

.visszaGomb:hover {
  background-color: rgb(3, 0, 177);
  transform: translateY(-2px);
}

.tovabbGomb:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.tovabbGomb:disabled:hover {
  background: linear-gradient(0deg, #c26066 0%, #cc8b8f 100%);
  color: rgb(24, 23, 23);
  box-shadow: inset 2px 2px 2px 0px rgba(255,255,255,.5),
              7px 7px 20px 0px rgba(0,0,0,.1),
              4px 4px 5px 0px rgba(0,0,0,.1);
}

input[type="file"] {
  display: none;
}

.file-upload-label {
  display: inline-block;
  padding: 1rem 2rem;
  background-color: rgb(0, 168, 180);
  color: rgb(0, 0, 0);
  border-radius: 10px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
  margin-bottom: 1rem;
}

.file-upload-label:hover {
  background-color: rgb(109, 253, 241);
  transform: translateY(-3px);
}

.file-preview {
  max-width: 100%;
  max-height: 300px;
  margin: 1rem auto;
  border-radius: 10px;
  box-shadow: rgb(176, 241, 250);
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
  background-color: #e0e0e0;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 600;
  color: #999;
  position: relative;
}

.progress-step.active {
  background-color: rgb(34, 48, 247);
  color: white;
}

.progress-step:not(:last-child)::after {
  content: '';
  position: absolute;
  top: 50%;
  left: 100%;
  width: 100%;
  height: 2px;
  background-color: #e0e0e0;
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
  color: rgb(29, 235, 22);
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