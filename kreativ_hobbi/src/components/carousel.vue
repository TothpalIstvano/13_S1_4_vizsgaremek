<template>
    <div>
        <div id="carouselContainer" :style="{ backgroundColor: bgColors[currentIndex % bgColors.length] }">
            <!--img id="carouselBackground" :src="kepek[currentIndex].src" :alt="kepek[currentIndex].alt" /-->

            <div class="webshop-item" :key="currentIndex">
                <h2 
                id="carouselTitle" 
                :key="currentIndex" 
                :class="currentIndex % 2 === 0 ? 'leftText' : 'rightText'">{{ kepek[currentIndex].nev }}</h2>
                <p 
                id="carouselDescription" 
                :key="currentIndex" 
                :class="currentIndex % 2 === 0 ? 'leftText' : 'rightText'">
                    {{ kepek[currentIndex].leiras || 'Ez egy fantasztikus termék, amelyet érdemes megtekinteni!' }}
                </p>
                <p id="carouselPrice" :key="currentIndex" :class="currentIndex % 2 === 0 ? 'leftText' : 'rightText'">
                    Ár: {{ kepek[currentIndex].ar ? kepek[currentIndex].ar + ' Ft' : 'Ár nincs megadva' }}
                </p>
                <button 
                @click="router.push(`/aruhaz/${kepek[currentIndex].id}`)"
                :key="currentIndex" 
                id="termekMegtekinteseGomb" 
                    :class="currentIndex % 2 === 0 ? 'leftText' : 'rightText'">Termék megtekintése</button>
                <div id="carouselItemImageContainer"
                    :style="{ left: currentIndex % 2 === 0 ? '56.6%' : '10%' }"
                    >
                    <img 
                    :src="kepek[currentIndex].termek_fo_kep ? kepek[currentIndex].termek_fo_kep.url_Link : ''"
                    :key="currentIndex + '-title'"
                    id="carouselItemImage" 
                    width="200" 
                    height="200"
                    alt="A beautiful webshop item" 
                    />
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
    height: 500px;
    border-radius: 25px;
    background-color: var(--carousel-bg);
    transition: background-color 0.6s ease-in-out;
    box-shadow: var(--carousel-shadow);
    width: 97%;
    margin: 0 auto ;
    margin-top: 5px;
}
#carouselTitle, #carouselDescription {
    position: absolute;
    color: rgb(255, 255, 255);
    width: 25%; 
    overflow: hidden;
}
#carouselTitle {
    animation: titlePopUp 1.5s ease-in-out;
    margin-top: 60px;
    width: 550px;
    opacity: 1;
}
#carouselDescription {
    top: 100px;
    animation: fade-in 1.5s ease-in-out;
    opacity: 1;
    overflow: hidden;          
    text-overflow: ellipsis;
    display: -webkit-box;
    -webkit-line-clamp: 6; /* number of lines to show */
    -webkit-box-orient: vertical;
}
#carouselPrice{
    position: absolute;
    top: 270px;
    width: 25%; 
    overflow: hidden;
    animation: fade-in 1.5s ease-in-out;
    opacity: 1;
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

/*#region Webhop elemek */
.webshop-item {
    position: absolute;
    color: rgb(255, 255, 255);
    top: 50px;
    width: 100%;
    animation: fade-in 0.8s ease-in-out;
    opacity: 1;
}
#termekMegtekinteseGomb {
    background-color: #4CAF50;
    border: none;
    color: white;
    padding: 10px 20px;
    text-align: center;
    text-decoration: none;
    display: inline-block;
    font-size: 16px;
    margin: 4px 2px;
    cursor: pointer;
    border-radius: 5px;
    position: absolute;
    color: rgb(255, 255, 255);
    top: 320px;
    animation: buttonPopUp 0.75s ease-in-out;
    opacity: 1;
}
.leftText {
    justify-content: left;
    float: left;
    left: 12%;
}
.rightText {
    justify-content: right;
    float: right;
    left: 60%;
}
#carouselItemImageContainer {
    width: 600px;
    height: 350px;
    display: block;
    border-radius: 15px;
    box-shadow: var(--carousel-shadow);
    margin-bottom: 20px;
    position: absolute;
    top: 20px;
}
#carouselItemImage {
    width: 600px;
    height: 350px;
    border-radius: 15px;
    box-shadow: var(--carousel-shadow);
    display: block;
    margin: 0 auto;
    opacity: 1;
    transition: fade-in-image  ease-in-out 25s;
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
    0% {
        top: 420px;
        opacity: 0;
    }
    100% {
        top: 320px;
        opacity: 1;
        
    }
}
/*#endregion */
</style>