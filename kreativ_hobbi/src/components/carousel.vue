<script setup>
import { ref, watch } from 'vue';
//webáruház meghívása

// Define the array of images
const kepek = [
    { src: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQrtQU3c2xsXwINXpu67nm_M--1igQ55tSYqA&s', alt: 'A beautiful sunset' },
    { src: 'https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcTTRwJNz1yEui-o79WsNSpWJSZ7dWPACZL4S2F4DNgpXNQ9qpptmVhms5tFYzzkDwHEbBKS1h8K4q3KpHY3NBMh3wytwkq5LcTugeF0NEfUMw', alt: 'A stunning mountain landscape' },
    { src: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAKEAAACUCAMAAADMOLmaAAAAA1BMVEVkAAoIcbc4AAAALUlEQVR4nO3BAQEAAACCIP+vbkhAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAB8GV2oAAFi+4XjAAAAAElFTkSuQmCC', alt: 'A cute cat' },
    { src: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSgMTaSoiKAZMhA13RNwbv53bBD2nnNeS4-2wWmtg2rZTinHoaqyWInX1RraCNzFgyDygt9mxpqpuE6TDQK93JQaWQRhBkmxM2zIXVka90HLw', alt: 'A delicious looking cake' },
    { src: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAANEAAACUCAMAAAA6cTwCAAAACVBMVEXan/v58v3WmffsqHDhAAAARUlEQVR4nO3dAQkAQAgEsNP+ob/DIwiyFVnqmvQ1AQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADgz3ZQOy7bifC4B+SHBOdHjtdMAAAAAElFTkSuQmCC', alt: 'A beautiful beach' }
];
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

let interval = setInterval(nextImage, 10000);
watch(currentIndex, () => {
    clearInterval(interval);
    interval = setInterval(nextImage, 10000);
})

</script>

<template>
    <div>
        <div id="carouselContainer">
            <img id="carouselBackground" :src="kepek[currentIndex].src" :alt="kepek[currentIndex].alt" />

            <div class="webshop-item" :key="currentIndex + '-title'">
                <h2 
                    id="carouselTitle" 
                    :key="currentIndex + '-title'" 
                    :class="currentIndex % 2 === 0 ? 'leftText' : 'rightText'">{{ kepek[currentIndex].alt }}</h2>
                <p 
                    id="carouselDescription" 
                    :key="currentIndex + '-title'" 
                    :class="currentIndex % 2 === 0 ? 'leftText' : 'rightText'">
                    Lorem ipsum dolor sit amet, consectetur adipisicing elit. Est laudantium excepturi illo consectetur iure numquam vitae quo sequi. Quis error magnam non modi vitae atque repellendus dicta distinctio aliquid eius.
                    Lorem ipsum dolor sit amet consectetur adipisicing elit. Rerum enim eius maiores, sint qui hic necessitatibus at, officia sunt ducimus dicta. Nam explicabo laboriosam aliquid sed dolor atque fuga provident?
                </p>
                <button 
                    onclick="alert('Termék megtekintése gombra kattintottál!')" 
                    :key="currentIndex + '-title'" 
                    id="termekMegtekinteseGomb" 
                    :class="currentIndex % 2 === 0 ? 'leftText' : 'rightText'">Termék megtekintése</button>
                <div id="carouselItemImageContainer"
                    :style="{ left: currentIndex % 2 === 0 ? '56.6%' : '10%' }"
                    >
                    <img 
                        src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQXfpo2zSyUFO56QdVu_0shk8V-jrcl4ckjog&s"
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

<style scoped>
/*#region Carousel elemei */
#carouselContainer {
    position: relative;
    overflow: hidden;
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
}

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