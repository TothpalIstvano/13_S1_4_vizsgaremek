<script setup>
import { ref } from "vue"
import { useRouter } from "vue-router"

const resz = ref(1)
const elsoLepes = ref(null)
const masodikLepes = ref(null)
const harmadikLepes = ref(null)
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
      path: '/mintavaltoztato',
      query: { 
        imageUrl: url,
        fileName: file.value.name
      }
    })
  }
}

</script>
<script>
export default {
  name: "Mintakeszito",
};
</script>


<template>
  <main>

    <h1 class="title">Mintakészítő</h1>

    <hr>
    
    <div id="bemutato">
      <h2 class="cim" style="color:black; border-bottom: none;">Mi is ez az oldal?</h2>
      <p>Lorem ipsum dolor sit amet consectetur adipisicing elit. Harum, consequuntur natus sed eius minima ipsa ipsum nesciunt perferendis iure repellat ducimus, nemo facilis doloremque consectetur accusantium nisi, vel quibusdam. Distinctio.</p>
      <ul>
        <li>Horgolás</li>
        <li>Kötés</li>
        <li>Hímzés</li>
      </ul>
      <p>Lorem ipsum dolor, sit amet consectetur adipisicing elit. Rerum quod, blanditiis nostrum deserunt quas possimus saepe tempora earum consequuntur doloribus debitis voluptatibus atque totam accusamus aut. Vero modi quod vitae!</p>
    </div>

    <div class="harom_oszlop">
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


    <div id="adatok">
      <!-- 1. rész -->
      <div v-if="resz === 1" id="elsoResz" class="radioStilus">
        <p class="cimek">Válassz típust a projektedhez:</p>
        <div v-for="option in tipusok" :key="option">
          <input
            type="radio"
            :id="option"
            name="elsoLepes"
            :value="option"
            v-model="elsoLepes"
            class="gombStilus"
          />
          <label :for="option">{{ option }}</label>
        </div>
        <button
          :disabled="!elsoLepes"
          @click="kovetkezoResz"
          class="tovabbGomb"
        >
          Következő
        </button>
      </div>

      <!-- 2. rész -->
      <div v-else-if="resz === 2" id="masodikResz" class="radioStilus">
        <p
          @click="modositas(1)"
          class="vissza"
        >
          A projekted: <strong>{{ elsoLepes }}</strong> ✅
        </p>

        <p class="cimek">Válassz fonaltípust: </p>
        <div v-for="option in fonalak" :key="option">
          <input
            type="radio"
            :id="option"
            name="masodikLepes"
            :value="option"
            v-model="masodikLepes"
            class="gombStilus"
          />
          <label :for="option">{{ option }}</label>
        </div>
        <button
          :disabled="!masodikLepes"
          @click="kovetkezoResz"
          class="tovabbGomb"
        >
          Következő
        </button>
      </div>

      <!-- 3. rész -->
      <div v-else-if="resz === 3" id="harmadikResz" class="radioStilus">
        <p
          @click="modositas(1)"
          class="vissza"
        >
          A projekted: <strong>{{ elsoLepes }}</strong> ✅
        </p>
        <p
          @click="modositas(2)"
          class="vissza"
        >
          A fonaltípusod: <strong>{{ masodikLepes }}</strong> ✅
        </p>

        <p class="cimek">Fájl feltöltése:</p>
        <input
          type="file"
          @change="kepfeltoltes"
        />
        <br>

        <button
            :disabled="!file"
            @click="toMintavaltoztato" 
            class="tovabbGomb">
          Minta készítése >>
        </button>

      </div>
    </div>
    
  </main>
</template>


<style scoped>
/* a színek placeholderesek*/
  main {
    margin: 0 auto 0 auto;
    background-color: rgb(241, 228, 212);
    padding: 20px;
    height: auto;
  }

  .title {
    text-align: center;
    margin-bottom: 30px;
    font-size: 50px;
  }

  hr {
    border-top: 1px solid black;
  }

  .cim {
    text-align: center;
    font-size: 30px;
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

  /*3 oszlop - még nem reszponzív */
  .harom_oszlop {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    gap: 50px;
    margin-bottom: 50px;
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

  #adatok {
    justify-items: center;
  }

  .cimek {
    text-align: center;
    font-size: 30px;
    margin-bottom: 30px;
  }

  .tovabbGomb {
  max-width: 200px;
  height: 40px;
  border-radius: 5px;
  padding: 10px 25px;
  font-weight: bold;
  background: transparent;
  cursor: pointer;
  transition: all 0.3s ease;
  position: relative;
  /*display: inline-block;*/
   box-shadow:inset 2px 2px 2px 0px rgba(255,255,255,.5),
   7px 7px 20px 0px rgba(0,0,0,.1),
   4px 4px 5px 0px rgba(0,0,0,.1);
  outline: none;
  border: none;
  background: rgb(241, 167, 159);
  background: linear-gradient(0deg, rgb(248, 121, 107) 0%, rgb(236, 182, 158) 100%);
  margin-top: 50px;
  color: rgb(24, 23, 23);
  }

  .tovabbGomb:hover {
  color: #f0094a;
  background: transparent;
  box-shadow:none;
  }

  .tovabbGomb:before,
  .tovabbGomb:after{
    content:'';
    position:absolute;
    top:0;
    right:0;
    height:2px;
    width:0;
    background: #f0094a;
    box-shadow:
    -1px -1px 5px 0px #fff,
    7px 7px 20px 0px #0003,
    4px 4px 5px 0px #0002;
    transition:400ms ease all;
  }

  .tovabbGomb:after{
    right:inherit;
    top:inherit;
    left:0;
    bottom:0;
  }

  .tovabbGomb:hover:before,
  .tovabbGomb:hover:after{
    width:100%;
    transition:800ms ease all;
  }

  .tovabbGomb:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.tovabbGomb:disabled:hover {
  background: linear-gradient(0deg, rgb(248, 121, 107) 0%, rgb(236, 182, 158) 100%);
  color: rgb(24, 23, 23);
  box-shadow: inset 2px 2px 2px 0px rgba(255,255,255,.5),
              7px 7px 20px 0px rgba(0,0,0,.1),
              4px 4px 5px 0px rgba(0,0,0,.1);
}

.image-preview {
  margin: 20px 0;
  text-align: center;
}

.image-preview img {
  max-width: 300px;
  max-height: 300px;
  border: 2px solid #ddd;
  border-radius: 5px;
}

.tovabbGomb:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}
</style>