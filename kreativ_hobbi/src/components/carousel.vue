<script setup>
import { callWithAsyncErrorHandling, ref } from 'vue';
const kepek = [
    { src: 'https://picsum.photos/id/1015/800/600', alt: 'A beautiful sunset' },
    { src: 'https://picsum.photos/id/1016/800/600', alt: 'A stunning mountain landscape' },
    { src: 'https://picsum.photos/id/1018/800/600', alt: 'A cute cat' },
    { src: 'https://picsum.photos/id/1020/800/600', alt: 'A delicious looking cake' },
    { src: 'https://picsum.photos/id/1024/800/600', alt: 'A beautiful beach' }
];
let currentIndex = ref(0);
function resetInterval() {
    clearInterval(intervalId.value);
    intervalId.value = setInterval(nextImage, 10000);
}
function nextImage() {
    currentIndex.value = currentIndex.value + 1 ;
    if (currentIndex.value >= kepek.length) {
        currentIndex.value = 0;
    }
    resetInterval();

}
function prevImage() {
    currentIndex.value = currentIndex.value - 1 ;
    if (currentIndex.value < 0) {
        currentIndex.value = kepek.length - 1;
    }
    resetInterval();
}

setInterval(nextImage, 10000);
</script>

<template>
    <div>
        <div >
            <div id="carouselContainer">
                <img id="carouselImage" :src="kepek[currentIndex].src" :alt="kepek[currentIndex].alt" />
                <h1 id="carouselTitle">{{ kepek[currentIndex].alt }}</h1>
                <p id="carouselDescription">Lorem ipsum dolor sit amet, consectetur adipisicing elit. Est laudantium excepturi illo consectetur iure numquam vitae quo sequi. Quis error magnam non modi vitae atque repellendus dicta distinctio aliquid eius.</p>
                <!--
                <svg xmlns="http://www.w3.org/2000/svg" class="prev" width="56.898" height="91" viewBox="0 0 56.898 91"><path d="M45.5,0,91,56.9,48.452,24.068,0,56.9Z" transform="translate(0 91) rotate(-90)" fill="#fff"></path></svg>
                
                <svg xmlns="http://www.w3.org/2000/svg" class="next" width="56.898" height="91" viewBox="0 0 56.898 91"><path d="M45.5,0,91,56.9,48.452,24.068,0,56.9Z" transform="translate(56.898) rotate(90)" fill="#fff"></path></svg>
                -->
                <button @click="prevImage" type="button" id="balGomb"> 	&#129104;</button>
                <button @click="nextImage" type="button" id="jobbGomb">&#129106;</button>
            </div>
            <div style="display: flex; justify-content: center; gap: 10px; margin-top: 10px;">
                <div v-for="(index) in kepek.length" :key="index">
                    <div 
                        class="helyzetJelzo" 
                        :value="index" 
                        @click="currentIndex = index-1 " :style="{ borderBlockColor: currentIndex === index-1 ? 'white' : 'grey', color: currentIndex === index-1 ? 'white' : 'grey' }" 
                        :checked="currentIndex === index-1">
                        {{ index }}</div>
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
#carouselTitle, #carouselDescription {
    position: absolute;
    color: black; 
    left: 200px; 
    width: 20%; 
    overflow: hidden;
}
#carouselTitle {
    top: 100px;
    animation: popUP 0.8s ease-in-out;
    opacity: 1;
}
#carouselDescription {
    top: 150px;
    animation: fade-in 1s ease-in-out;
    opacity: 1;
}
@keyframes fade-in {
    0% {
        opacity: 0;
    }
    100% {
        opacity: 1;
    }
    
}
    
@keyframes popUP {
    0% {
        top: 200px;
        opacity: 0;
    }
    100% {
        top: 100px;
        opacity: 1;
        
    } 
}


#carouselImage {
    position: relative;
    display: block;
    margin: 0 auto ;
    margin-top: 20px;
    border-radius: 25px;
    width: 97%;
    height: auto;
    max-height: 500px;
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
    transition: opacity 0.5s ease-in-out;
    z-index: -1;
}
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
.helyzetJelzo {
    width: 225px;
    height: 15px;
    margin: 0 5px;
    cursor: pointer;
    text-align: center;
    padding-top: 15px;
    border-top: 3px solid;
    margin-top: 3px;
    color: gray;
    transform: translateY(-180%);
}
</style>