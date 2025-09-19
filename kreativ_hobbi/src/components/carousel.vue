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
        <div >
            <div id="carouselContainer" :style="{ backgroundImage: `url(${kepek[currentIndex].src})`}">
                <button @click="prevImage" type="button" id="balGomb"> 	&#129104;</button>
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
#carouselContainer {
    position: relative;
    overflow: hidden;
}
#carouselImage {
    width: 100%;
    height: auto;
    max-height: 600px;
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
    transition: opacity 0.5s ease-in-out;
    z-index: -1;
}
#balGomb {
    width: 40px;
    height: 40px;
    border-radius: 50%;
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
    height: 40px;
    border-radius: 50%;
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
</style>