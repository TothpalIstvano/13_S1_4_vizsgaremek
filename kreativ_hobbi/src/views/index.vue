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
    <div class="atContainer">
      <div>
        <div class="atSzoveg">
          <h2 class="atOldalCim">Valami címe</h2>
          <p class="atOLdalLeiras">
            Lorem ipsum dolor sit amet consectetur adipisicing elit. Quisquam, natus.LOREM ipsum dolor sit amet consectetur adipisicing elit.
          </p>
        </div>
        <div class="atKep">
          <img src="" alt="">
        </div>
      </div>
      <div>
        <div class="atSzoveg">
          <h2 class="atOldalCim">Valami címe</h2>
          <p class="atOLdalLeiras">
            Lorem ipsum dolor sit amet consectetur adipisicing elit. Quisquam, natus.LOREM ipsum dolor sit amet consectetur adipisicing elit.
          </p>
        </div>
        <div class="atKep">
        </div>
      </div>
      <div>
        <div class="atSzoveg">
          <h2 class="atOldalCim">Valami címe</h2>
          <p class="atOLdalLeiras">
            Lorem ipsum dolor sit amet consectetur adipisicing elit. Quisquam, natus.LOREM ipsum dolor sit amet consectetur adipisicing elit.
          </p>
        </div>
        <div class="atKep">

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
.atContainer {
  display: flex;
  flex-direction: column;
  margin: 8rem 3rem 6rem 3rem; /* top right bottom left */
  border-radius: 24px;      
  overflow: hidden;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);       
}

.atContainer > div {
  display: flex;
  flex-direction: row;
}
.atContainer > div:nth-child(odd) {
  flex-direction: row-reverse;
}

.atKep {
  background-color: rgb(255, 0, 0);
  width: 50%;
  height: 300px;
}
.atSzoveg{
  justify-content: center;
  align-items: center;
  background-color: lightgray;
  width: 50%;
  height: 300px;
  text-align: center;
}
.atOldalCim {
  font-size: 2rem;
  color: #000000;
  font-weight: bold;
  text-decoration: none;
  border: none;
}
.atOLdalLeiras {
  text-decoration: none;
  border: none;
}
/*#endregion*/

</style>
