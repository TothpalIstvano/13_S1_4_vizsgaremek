<script setup>
import Carousel from '@/components/carousel.vue';
</script>

<template>
  <main>
    <carousel></carousel>
    <div id="mottoContainer">
      <h1>Webáruházunk vmije</h1>
      <p>
        "Lorem ipsum dolor sit amet consectetur adipisicing elit. Magnam rerum beatae sunt, laboriosam minima nam sapiente reprehenderit quisquam repellat asperiores minus quis, fuga natus ipsum ipsam quod molestiae corporis incidunt!
        Lorem ipsum dolor sit amet consectetur adipisicing elit. Quisquam, natus.LOREM ipsum dolor sit amet consectetur adipisicing elit. "
      </p>
    </div>
  </main>
</template>

<style scoped>
/*#region Motto Container*/
#mottoContainer {
  text-align: center;
  margin: 3rem;
  width: 60%;
  justify-content: center;
  justify-self: center;
}
#mottoContainer h1 {
  font-size: 2.5rem;
  margin-bottom: 1rem;
}
#mottoContainer p {
  font-size: 1.2rem;
  font-style: italic;
  line-height: 1.6;
}
/*#endregion*/


</style>
