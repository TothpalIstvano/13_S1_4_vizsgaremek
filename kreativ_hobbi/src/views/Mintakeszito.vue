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
  file.value = event.target.files[0]
  if (file.value) {
    // do your upload logic here (API call, etc.)
    // then redirect
    router.push("/thank-you") // change path as needed
  }
}
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

    <!--
    <div class="ket_oszlop">
      <div class="adatok">
        <p>Milyen projektet szeretne készíteni?</p>
        <div id="tipusok">
          <input type="radio" name="tipus" id="1">
          <label for="tipus">Horgolás</label><br>
          <input type="radio" name="tipus" id="2">
          <label for="tipus">Kötés</label><br>
          <input type="radio" name="tipus" id="3">
          <label for="tipus">Hímzés</label><br>
        </div>

        <p>Milyen vastag fonalból készülne?</p> //hímzésnél nyilván ne lehessen választani, disabled lesz
        <div id="fonalCsoportok">
          <input type="radio" name="fonal" id="1">
          <label for="fonal">'A' fonal csoport</label><br>
          <input type="radio" name="fonal" id="2">
          <label for="fonal">'B' fonal csoport</label><br>
          <input type="radio" name="fonal" id="3">
          <label for="fonal">'C' fonal csoport</label><br>
          <input type="radio" name="fonal" id="4">
          <label for="fonal">'D' fonal csoport</label><br>
          <input type="radio" name="fonal" id="5">
          <label for="fonal">'E' fonal csoport</label><br>
        </div>
      </div>

      <div class="adatok" id="vmiSzar">
        <p>Válassza ki a fájlt:</p>
        <input type="file" name="kepFeltoltes" id="" accept="image/*">

        <p>Állítsa be a méretet:</p>
        <form action="">
          <input type="range" name="meret" id="" min="20" max="200" resz="1" value="100" oninput="this.form.mennyi.value=this.value">
          //https://www.w3schools.com/howto/tryit.asp?filename=tryhow_css_js_rangeslider_round
          <input type="number" name="mennyi" min="20" max="200" value="100" oninput="this.form.meret.value=this.value" />
        </form>
      
        <p id="meretKiiras"></p>

      </div>

      <div class="adatok">

      </div>

      <div class="adatok">

      </div>

    </div>
  -->

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
        >
          Következő
        </button>
      </div>

      <!-- 3. rész -->
      <div v-else-if="resz === 3" id="harmadikResz">
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
          :disabled="!masodikLepes"
          @click="kovetkezoResz"
        >
          Minta készítése >>
        </button>
      </div>
    </div>
    

    <div class="glass-radio-group-vertical">
      <input checked="" id="glass-silver" name="plan" type="radio" />
      <label data-color="silver" for="glass-silver">
        <span class="radio-indicator">
          <span class="checkmark">✓</span>
        </span>
        <span class="label-text">Silver</span>
      </label>

      <input id="glass-gold" name="plan" type="radio" />
      <label data-color="gold" for="glass-gold">
        <span class="radio-indicator">
          <span class="checkmark">✓</span>
        </span>
        <span class="label-text">Gold</span>
      </label>

      <input id="glass-platinum" name="plan" type="radio" />
      <label data-color="platinum" for="glass-platinum">
        <span class="radio-indicator">
          <span class="checkmark">✓</span>
        </span>
        <span class="label-text">Platinum</span>
      </label>

      <div class="glass-glider-vertical"></div>
  </div>
  </main>
</template>


<style scoped>
  .glass-radio-group-vertical {
    position: relative;
    display: flex;
    flex-direction: column;
    background: rgba(255, 255, 255, 0);
    padding: 1.5rem 1.2rem;
    border: 0px solid rgb(255, 255, 255, 0);
    border-radius: 1rem;
    backdrop-filter: blur(16px);
    width: 230px;
    overflow: hidden;
    gap: 0.5rem;
  }

  .glass-radio-group-vertical input {
    display: none;
  }

  .glass-radio-group-vertical label {
    position: relative;
    display: flex;
    align-items: center;
    gap: 0.8rem;
    padding: 1rem 1.2rem;
    border-radius: 0.8rem;
    font-weight: 600;
    font-size: 1rem;
    color: #ccc;
    cursor: pointer;
    z-index: 2;
    transition: all 0.4s ease-in-out;
    overflow: hidden;
  }

  .label-text {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: flex-start;
  }

  .radio-indicator {
    width: 1.2rem;
    height: 1.2rem;
    border-radius: 50%;
    background: #999;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 0.75rem;
    color: white;
    box-shadow: 0 0 0 2px transparent;
    transition: all 0.3s ease-in-out;
  }

  .checkmark {
    opacity: 0;
    transform: scale(0);
    transition: all 0.3s ease-in-out;
  }

  .glass-glider-vertical {
    position: absolute;
    left: 0;
    height: 56px;
    width: 80%;
    margin-left: 20px;
    border-radius: 0.8rem;
    z-index: 1;
    transition:
      transform 0.4s cubic-bezier(0.5, 1.6, 0.4, 1),
      background 0.5s ease-in-out,
      box-shadow 0.4s;
  }

  #glass-silver:checked ~ .glass-glider-vertical {
    transform: translateY(0%);
    background: linear-gradient(135deg, #00000050, #d1d1d1cc);
    box-shadow: 0 0 15px #00000077;
  }
  #glass-silver:checked + label {
    color: white;
  }
  #glass-silver:checked + label .radio-indicator {
    background: #c0c0c0;
    box-shadow:
      0 0 0 2px #858585aa,
      0 0 6px #6b6b6baa;
  }
  #glass-silver:checked + label .checkmark {
    opacity: 1;
    transform: scale(1);
  }

  #glass-gold:checked ~ .glass-glider-vertical {
    transform: translateY(115%);
    background: linear-gradient(135deg, #00000050, #ffbb00);
    box-shadow: 0 0 15px #00000077;
  }
  #glass-gold:checked + label {
    color: white;
  }
  #glass-gold:checked + label .radio-indicator {
    background: #ffc400;
    box-shadow:
      0 0 0 2px #9c7300d3,
      0 0 6px #695a00aa;
  }
  #glass-gold:checked + label .checkmark {
    opacity: 1;
    transform: scale(1);
  }

  #glass-platinum:checked ~ .glass-glider-vertical {
    transform: translateY(230%);
    background: linear-gradient(135deg, #00000050, #57d5ff);
    box-shadow: 0 0 15px #00000077;
  }
  #glass-platinum:checked + label {
    color: white;
  }
  #glass-platinum:checked + label .radio-indicator {
    background: #75c5ff;
    box-shadow:
      0 0 0 2px #0095ff5b,
      0 0 6px #0095ff57;
  }
  #glass-platinum:checked + label .checkmark {
    opacity: 1;
    transform: scale(1);
  }

  .glass-radio-group-vertical:has(#glass-silver:checked) {
    border-color: #c0c0c0;
    box-shadow:
      0 4px 20px rgba(0, 0, 0, 0.2),
      inset 0 0 8px rgba(255, 255, 255, 0.4);
  }

  .glass-radio-group-vertical:has(#glass-gold:checked) {
    border-color: #ffbb00;
    box-shadow:
      0 4px 20px rgba(0, 0, 0, 0.2),
      inset 0 0 8px rgba(255, 196, 0, 0.527);
  }

  .glass-radio-group-vertical:has(#glass-platinum:checked) {
    border-color: #57d5ff;
    box-shadow:
      0 4px 20px rgba(0, 0, 0, 0.2),
      inset 0 0 8px rgba(0, 183, 255, 0.63);
  }
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

 /* .ket_oszlop {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr 1fr;
    gap: 20px;
    margin-bottom: 50px;
    padding:1rem;
    justify-items: center;

  }

  .adatok {
    background-color: rosybrown;
    text-align: justify;
    padding: 20px;
    border-radius: 10px;
    box-shadow: rgba(50, 50, 93, 0.25) 0px 2px 5px -1px, rgba(0, 0, 0, 0.3) 0px 1px 3px -1px;
 
  }
  
  #tipusok, #fonalCsoportok {
    margin-left: 20px;
  }*/

</style>