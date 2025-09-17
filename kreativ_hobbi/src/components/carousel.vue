<script setup>
import { ref } from 'vue';
const kepek = [
    { src: 'https://picsum.photos/id/1015/800/300', alt: 'A beautiful sunset' },
    { src: 'https://picsum.photos/id/1016/800/300', alt: 'A stunning mountain landscape' },
    { src: 'https://picsum.photos/id/1018/800/300', alt: 'A cute cat' },
    { src: 'https://picsum.photos/id/1020/800/300', alt: 'A delicious looking cake' },
    { src: 'https://picsum.photos/id/1024/800/300', alt: 'A beautiful beach' }
];
let alt = 'Carousel Image';
let currentIndex = ref(0);
function nextImage() {
    currentIndex.value = currentIndex.value + 1 ;
    if (currentIndex.value >= kepek.length) {
        currentIndex.value = 0;
    }
}
function prevImage() {
    currentIndex.value = currentIndex.value - 1 ;
    if (currentIndex.value < 0) {
        currentIndex.value = kepek.length - 1;
    }
}
setInterval(nextImage, 10000);
</script>

<template>
    <div>
        <div>
            <div>
                <button @click="prevImage" type="button" id="balGomb"> 	&#129104;</button>
                <img :src="kepek[currentIndex].src" :alt="kepek[currentIndex].alt" id="carouselImage"/>
                <button @click="nextImage" type="button" id="jobbGomb">&#129106;</button>
            </div>
            <div style="display: flex; justify-content: center; gap: 10px; margin-top: 10px;">
                <div v-for="(index) in kepek.length" :key="index">
                    <input type="radio" name="carousel-image" :value="index" @click="currentIndex = index-1 " :checked="currentIndex === index-1" />
                </div>
            </div>
        </div>
    </div>
</template>

<style scoped>
#carouselImage {
    width: 100%;
    height: auto;
    max-height: 600px;
    border-radius: 8px;
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
    transition: opacity 0.5s ease-in-out;
    z-index: -1;
}
#balGomb {
    width: 40px;
    height: 600px;
    position: absolute;
    left: 10px;
    top: 43.5%;
    transform: translateY(-50%);
    background-color: rgba(0, 0, 0, 0.1);
    border: none;
    color: white;
    padding: 10px;
    cursor: pointer;
}
#jobbGomb {
    width: 40px;
    height: 600px;
    position: absolute;
    right: 10px;
    top: 43.5%;
    transform: translateY(-50%);
    background-color: rgba(0, 0, 0, 0.1);
    border: none;
    color: white;
    padding: 10px;
    cursor: pointer;
    
}
#balGomb:hover, #jobbGomb:hover {
    background-color: rgba(0, 0, 0, 0.5);
    transition: all 1.5s ease-in-out;
}
#balGomb:hover::after, #jobbGomb:hover::after {
   background-color: rgba(0, 0, 0, 0.5);
   transition: all 1.5s ease-in-out;
}

/*
                <div class="box1 box">
                    <div class="bg"></div>
                    <div class="details">
                        <h1>I'm the first Box</h1>
                        <p>
                            Lorem ipsum dolor sit amet, consectetur adipiscing 
                            elit. Integer lacinia dui lectus. Donec scelerisque ipsum
                            diam, ac mattis orci pellentesque eget. 
                        </p>
                        <button>Check Now</button>
                    </div>

                    <div class="illustration"><div class="inner"></div></div>
                </div>
                                
*/
</style>
 