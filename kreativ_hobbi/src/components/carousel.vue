<script setup>
import { ref } from 'vue';
//webáruház meghívása

// Define the array of images
const kepek = [
    { src: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQrtQU3c2xsXwINXpu67nm_M--1igQ55tSYqA&s', alt: 'A beautiful sunset' },
    { src: 'https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcTTRwJNz1yEui-o79WsNSpWJSZ7dWPACZL4S2F4DNgpXNQ9qpptmVhms5tFYzzkDwHEbBKS1h8K4q3KpHY3NBMh3wytwkq5LcTugeF0NEfUMw', alt: 'A stunning mountain landscape' },
    { src: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAKEAAACUCAMAAADMOLmaAAAAA1BMVEVkAAoIcbc4AAAALUlEQVR4nO3BAQEAAACCIP+vbkhAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAB8GV2oAAFi+4XjAAAAAElFTkSuQmCC', alt: 'A cute cat' },
    { src: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAALAAAACUCAMAAAAEVFNMAAAAElBMVEX/67z97sr/8Mr+67n99NT989blvNdPAAAAr0lEQVR4nO3OQQ3AMAwAsXTd+FMeCj8inRF43rPKN+fOIvdZFp7CWmGtsFZYK6wV1gprhbXCWmGtsFZYK6wV1gprhbXCWmGtsFZYK6wV1gprhbXCWmGtsFZYK6wV1gprhbXCWmGtsFZYK6wV1gprhbXCWmGtsFZYK6wV1gprhbXCWmGtsFZYK6wV1gprhbXCWmGtsFZYK6wV1gprhbXCWmGtsFZYK6wV1gprhbV94R8C1gQtK4sb8AAAAABJRU5ErkJggg==', alt: 'A delicious looking cake' },
    { src: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAANEAAACUCAMAAAA6cTwCAAAACVBMVEXan/v58v3WmffsqHDhAAAARUlEQVR4nO3dAQkAQAgEsNP+ob/DIwiyFVnqmvQ1AQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADgz3ZQOy7bifC4B+SHBOdHjtdMAAAAAElFTkSuQmCC', alt: 'A beautiful beach' }
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
        <div id="carouselContainer">
            <img id="carouselImage" :src="kepek[currentIndex].src" :alt="kepek[currentIndex].alt" />

            <div class="webshop-item" :key="currentIndex + '-title'">
                <img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRy3Kj4qK7M7jT6j9q8lYh7sR7h8q3XhQ&s" alt="A beautiful webshop item">
                <h2 id="carouselTitle" :key="currentIndex + '-title'" :class="currentIndex % 2 === 0 ? 'leftText' : 'rightText'">{{ kepek[currentIndex].alt }}</h2>
                <p id="carouselDescription" :key="currentIndex + '-title'" :class="currentIndex % 2 === 0 ? 'leftText' : 'rightText'">Lorem ipsum dolor sit amet, consectetur adipisicing elit. Est laudantium excepturi illo consectetur iure numquam vitae quo sequi. Quis error magnam non modi vitae atque repellendus dicta distinctio aliquid eius.</p>
                <p id="carouselPrice" :class="currentIndex % 2 === 0 ? 'leftText' : 'rightText'">$29.99</p>
                <button @click="addToCart" :key="currentIndex + '-title'" id="carouselAddToCartButton" :class="currentIndex % 2 === 0 ? 'leftText' : 'rightText'">Add to cart</button> 
            </div>
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
                    @click="currentIndex = index-1 " :style="{ borderBlockColor: currentIndex === index-1 ? 'white' : '#bebebe', color: currentIndex === index-1 ? 'white' : '#bebebe' }" 
                    :checked="currentIndex === index-1">
                    {{ index }}</div>
            </div>
        </div>
    </div>
</template>

<style scoped>
/*#region Carousel elemei */
#carouselContainer {
    position: relative;
    overflow: hidden;
}
#carouselTitle, #carouselDescription {
    position: absolute;
    color: rgb(255, 255, 255);
    width: 20%; 
    overflow: hidden;
}
#carouselTitle {
    animation: popUP 0.8s ease-in-out;
    width: 550px;
    opacity: 1;
}
#carouselDescription {
    top: 100px;
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
        top: 100px;
        opacity: 0;
    }
    100% {
        top: 25 px;
        opacity: 1;
        
    } 
}
#carouselImage {
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
/*#endregion */

/*#region Webhop elemek */
.webshop-item {
    position: absolute;
    color: rgb(255, 255, 255);
    top: 50px;
    width: 1200px;
    animation: popUP 0.8s ease-in-out;
    opacity: 1;
}
#carouselPrice {
    position: absolute;
    color: rgb(255, 255, 255);
    top: 250px;
    left: 700px;
    animation: fade-in 0.8s ease-in-out;
    opacity: 1;
}
#carouselAddToCartButton {
    background-color: #4CAF50;
    position: absolute;
    color: rgb(255, 255, 255);
    top: 320px;
    left: 700px;
    animation: fade-in 0.8s ease-in-out;
    opacity: 1;
}
.leftText {
    float: left;
    left: 200px ;
}
.rightText {
    float: right;
    right: 200px;
}
/*#endregion */
</style>