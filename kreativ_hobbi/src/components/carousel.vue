<template>
    <div>
        <div id="carouselContainer" :style="{ backgroundColor: bgColors[currentIndex % bgColors.length] }">
            <!--img id="carouselBackground" :src="kepek[currentIndex].src" :alt="kepek[currentIndex].alt" /-->

            <div class="webshop-item" :class="currentIndex % 2 === 0 ? 'layout-even' : 'layout-odd'" :key="currentIndex">

                <div class="col-image">
                    <div id="carouselItemImageContainer">
                        <img 
                        :src="kepek[currentIndex].termek_fo_kep ? kepek[currentIndex].termek_fo_kep.url_Link : 'http://localhost:8000/storage/termekkepek/default.jpg'"
                        :key="currentIndex + '-img'"
                        id="carouselItemImage" 
                        alt="A beautiful webshop item" 
                        />
                    </div>
                </div>

                <div class="col-center">
                    <p id="carouselPrice" :key="currentIndex">
                        Ár: {{ kepek[currentIndex].ar ? kepek[currentIndex].ar + ' Ft' : 'Ár nincs megadva' }}
                    </p>
                    <p>Elérhető színek:</p>
                    <div class="color-swatches">
                        <span
                            v-for="(color, i) in bgColors"
                            :key="i"
                            class="swatch"
                            :style="{ backgroundColor: color }"
                        ></span>
                    </div>
                    <button 
                        @click="router.push(`/aruhaz/${kepek[currentIndex].id}`)"
                        :key="currentIndex" 
                        id="termekMegtekinteseGomb">Termék megtekintése
                    </button>
                </div>

                <div class="col-info">
                    <h2 id="carouselTitle" :key="currentIndex">{{ kepek[currentIndex].nev || 'Termék neve' }}</h2>
                    <p id="carouselDescription" :key="currentIndex">
                        {{ kepek[currentIndex].leiras || 'Ez egy fantasztikus termék, amelyet érdemes megtekinteni!' }}
                    </p>
                </div>

                

            </div>
            <button @click="prevImage" type="button" id="balGomb"> 	&#129104;</button>
            <button @click="nextImage" type="button" id="jobbGomb">&#129106;</button>
        </div>
        <div id="helyzetJelzoContainer">
            <div v-for="(index) in kepek.length" :key="index">
                <div 
                class="helyzetJelzo" 
                :value="index" 
                    @click="currentIndex = index-1 " :style="{ borderBlockColor: currentIndex === index-1 ? 'white' : '#bebebe', color: currentIndex === index-1 ? 'white' : '#bebebe' }" 
                    :checked="currentIndex === index-1">
                    {{ index }}</div>
            </div>
        </div>
    </div>
</template>

<script setup>
import { onMounted, ref, watch } from 'vue';
import axios from 'axios';
import { useRouter } from 'vue-router';

const router = useRouter();
// Define the array of images
const kepek = ref([
    { nev: '', src: '', alt: '', leiras: '' },
    { nev: '', src: '', alt: '', leiras: '' },
    { nev: '', src: '', alt: '', leiras: '' },
    { nev: '', src: '', alt: '', leiras: '' },
    { nev: '', src: '', alt: '', leiras: '' },
]);
const bgColors = ['#946609', '#944309', '#c7590a', '#c45529', '#912b03'];
let currentIndex = ref(0);
function nextImage() {
    currentIndex.value = currentIndex.value + 1 ;
    if (currentIndex.value >= kepek.value.length) {
        currentIndex.value = 0;
    }
}
function prevImage() {
    currentIndex.value = currentIndex.value - 1 ;
    if (currentIndex.value < 0) {
        currentIndex.value = kepek.value.length - 1;
    }
}

async function fetchCarouselImages() {
  try {
    const response = await axios.get('/api/carousel/termekek');
    console.log(response.data);
    return response.data;
  } catch (error) {
    console.error('Error fetching carousel images:', error);
    return [];
  }
}

let interval = setInterval(nextImage, 10000);
watch(currentIndex, () => {
    clearInterval(interval);
    interval = setInterval(nextImage, 10000);
})

onMounted(() => {
    fetchCarouselImages().then(fetchedImages => {
        if (fetchedImages) {
            kepek.value = fetchedImages;
        }
        console.log(kepek.value);
    });
});

</script>

<style scoped>
/*#region Carousel elemei */
#carouselContainer {
    position: relative;
    height: clamp(300px, 40vw, 500px);
    border-radius: 25px;
    background-color: var(--carousel-bg);
    transition: background-color 0.6s ease-in-out;
    box-shadow: var(--carousel-shadow);
    width: 97%;
    margin: 0 auto;
    margin-top: 5px;
    display: flex;
    align-items: center;
}
/*#region Carousel háttér */
#carouselBackground {
    display: block;
    margin: 0 auto ;
    margin-top: 20px;
    border-radius: 25px;
    width: 97%;
    height: auto;
    max-height: 500px;
    box-shadow: var(--carousel-shadow);
    transition: opacity 0.5s ease-in-out;
    z-index: -1;
    
}
/*#endregion */
#balGomb, #jobbGomb {
    width: 40px;
    height: 40px;
    border-radius: 50%;
    position: absolute;
    top: 50%;
    transform: translateY(-50%);
    background-color: rgba(0, 0, 0, 0.1);
    border: none;
    color: white;
    padding: 10px;
    cursor: pointer;
}
#balGomb {
    left: 50px;
}
#jobbGomb {
    right: 50px;
}

#balGomb:hover, #jobbGomb:hover {
    background-color: rgba(0, 0, 0, 0.5);
    transition: all 1.5s ease-in-out;
}
#balGomb:hover::after, #jobbGomb:hover::after {
    background-color: rgba(0, 0, 0, 0.5);
    transition: all 1.5s ease-in-out;
}
#helyzetJelzoContainer {
    display: flex; 
    justify-content: center; 
    gap: 10px; 
    margin-top: 10px; 
    margin-bottom: 1rem;
}
.helyzetJelzo {
    width: 225px;
    height: 15px;
    margin: 0 5px;
    cursor: pointer;
    text-align: center;
    padding: 15px;
    border-top: 3px solid;
    margin-top: 3px;
    transform: translateY(-180%);
    transition: all 0.6s ease-in-out;
}
/*#endregion */

/*#region Webshop elemek */

/* 3-column grid inside the carousel */
.webshop-item {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    align-items: center;
    height: 100%;
    width: 100%;
    padding: 0 70px; /* leave room for nav buttons */
    box-sizing: border-box;
    color: white;
    animation: fade-in 0.8s ease-in-out;
    gap: 16px;
}

/* Even slides: image | center | info */
.layout-even {
    grid-template-areas: "image center info";
}
/* Odd slides: info | center | image  */
.layout-odd {
    grid-template-areas: "info center image";
}

.col-image  { grid-area: image;  display: flex; align-items: center; justify-content: center; }
.col-center { grid-area: center; display: flex; flex-direction: column; justify-content: center; gap: 10px; text-align: center; }
.col-info   { grid-area: info;   display: flex; flex-direction: column; justify-content: center; align-items: center; gap: 16px; text-align: center; }

/* Title & Description */
#carouselTitle {
    margin: 0;
    animation: titlePopUp 1.5s ease-in-out;
    font-size: clamp(1rem, 2vw, 1.6rem);
}
#carouselDescription {
    margin: 0;
    animation: fade-in 1.5s ease-in-out;
    overflow: hidden;
    text-overflow: ellipsis;
    display: -webkit-box;
    -webkit-line-clamp: 6;
    -webkit-box-orient: vertical;
    font-size: clamp(0.8rem, 1.2vw, 1rem);
    opacity: 0.9;
}

/* Price */
#carouselPrice {
    margin: 0;
    font-size: clamp(1rem, 1.5vw, 1.3rem);
    font-weight: bold;
    animation: fade-in 1.5s ease-in-out;
}

/* Color swatches */
.color-swatches {
    display: flex;
    gap: 8px;
    justify-content: center;
    flex-wrap: wrap;
}
.swatch {
    width: 20px;
    height: 20px;
    border-radius: 50%;
    border: 2px solid rgba(255,255,255,0.6);
    display: inline-block;
}

/* Button */
#termekMegtekinteseGomb {
    background-color: #4CAF50;
    border: none;
    color: white;
    padding: 10px 20px;
    font-size: 16px;
    cursor: pointer;
    border-radius: 5px;
    animation: fade-in 0.75s ease-in-out;
    white-space: nowrap;
}
#termekMegtekinteseGomb:hover {
    background-color: #45a049;
}

/* Image */
#carouselItemImageContainer {
    width: 100%;
    display: flex;
    justify-content: center;
}
#carouselItemImage {
    width: 100%;
    max-width: 380px;
    height: auto;
    max-height: 300px;
    object-fit: contain;
    border-radius: 15px;
    box-shadow: var(--carousel-shadow);
    opacity: 1;
}
/*#endregion */

/*#region Animációk */
@keyframes fade-in {
    0% {
        opacity: 0;
    }
    100% {
        opacity: 1;
    }
    
}
@keyframes fade-in-image {
    0% {
        opacity: 0;
    }
    50% {
        opacity: 0.3;
    }
    100% {
        opacity: 1;
    }
}
@keyframes titlePopUp {
    0% {
        top: 100px;
        opacity: 0;
    }
    50% {
        opacity: 0.2;
    }
    100% {
        top: 0px;
        opacity: 1;
        
    } 
}
@keyframes buttonPopUp {
    0% { opacity: 0; transform: translateY(20px); }
    100% { opacity: 1; transform: translateY(0); }
}
/*#endregion */

@media (max-width: 768px) {
  #carouselContainer {
    height: auto;
    min-height: 400px;
    padding: 20px 0 60px;
  }

  .webshop-item {
    grid-template-columns: 1fr;
    grid-template-areas:
      "image"
      "center"
      "info" !important;
    padding: 0 50px;
    gap: 12px;
  }

  .layout-even, .layout-odd {
    grid-template-areas:
      "image"
      "center"
      "info";
  }

  #carouselItemImage {
    max-height: 160px;
  }

  #balGomb { left: 8px; }
  #jobbGomb { right: 8px; }

  .helyzetJelzo { width: 60px; }
}
</style>