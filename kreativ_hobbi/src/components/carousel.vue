<script setup>
import { ref } from 'vue';
const kepek = [
    'https://picsum.photos/id/1015/800/300',
    'https://picsum.photos/id/1016/800/300',
    'https://picsum.photos/id/1018/800/300',
    'https://picsum.photos/id/1020/800/300',
    'https://picsum.photos/id/1024/800/300'

];
let alt = 'Carousel Image';
let currentIndex = ref(0);
function nextImage() {
    currentIndex.value = currentIndex.value + 1 ;
    if (currentIndex.value >= kepek.length) {
        currentIndex.value = 0;
    }
}
setInterval(nextImage, 3000);
</script>

<template>
    <div>
        <h1>Carousel Component</h1>
        <div>
            <div>
                <img :src="kepek[currentIndex]" :alt="alt" width="800" height="300" />
            </div>
            <div style="display: flex;">
                <div v-for="index in Array(kepek.length).keys()">
                    <input type="radio" name="carousel-image" :value="index" @click="currentIndex = index" :checked="currentIndex === index" />
                </div>
            </div>
        </div>
    </div>
</template>

<style scoped>

</style>
