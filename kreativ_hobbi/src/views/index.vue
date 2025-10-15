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
        Lorem ipsum dolor sit amet consectetur adipisicing elit. Quisquam, natus.LOREM ipsum dolor sit amet consectetur adipisicing elit."
      </p>
    </div>
    <div class="mozaikFoContainer">
      <div class="mozaikContainer">
        <div id="mozaikKep1"></div>
        <div class="mozaikSzovegContainer">
          <h2 class="mozaikCim"></h2>
          <p class="mozaikLeiras"></p>
        </div>
      </div >
      <div class="mozaikContainer">
        <div class="mozaikSzovegContainer">
          <div id="mozaikKep2"></div>
          <h2 class="mozaikCim"></h2>
          <p class="mozaikLeiras"></p>
        </div>
      </div>
      <div class="mozaikContainer">
        <div id="mozaikKep3"></div>
        <div class="mozaikSzovegContainer">
          <h2 class="mozaikCim"></h2>
          <p class="mozaikLeiras"></p>
        </div>
      </div>
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

/*#region At Container*/
.mozaikFoContainer {
  display: flex;
  flex-direction: column;
  margin: 8rem 3rem 6rem 3rem; /* top right bottom left */
  border-radius: 24px;      
  overflow: hidden;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
}

.mozaikContainer {
  display: flex;
  flex-direction: column;
  width: 100%;
  height: 300px;
}

#mozaikKep1, #mozaikKep2, #mozaikKep3  {
  background-color: rgb(255, 0, 0);
  width: 50%;
  height: 300px;
}
#mozaikKep1 {
  background-image: url('@/images/mozaikKep1.jpg');
  background-size: cover;
  background-position: center;
}
#mozaikKep2 {
  background-image: url("@/images/mozaikKep2.jpg");
  background-size: cover;
  background-position: center;
}
#mozaikKep3 {
  background-image: url('@/images/mozaikKep3.png');
  background-size: cover;
  background-position: center;
}
.mozaikSzovegContainer{
  justify-content: center;
  align-items: center;
  background-color: lightgray;
  width: 50%;
  height: 300px;
  text-align: center;
  border-radius: 3%;
}
.mozaikCim {
  font-size: 2rem;
  color: #000000;
  font-weight: bold;
  padding-left: 2rem;
  border: none;
  text-align: calc(70% - 9rem);
}
.mozaikLeiras {
  font-size: 1.2rem;
  color: #000000;
  padding-left: 2rem;
}
/*#endregion*/

</style>
