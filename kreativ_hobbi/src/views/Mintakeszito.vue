<script setup>

</script>

<template>
  <main>

    <h1 class="title">Mintakészítő</h1>

    
    <div id="bemutato">
      <h2 class="title" style="color:black; border-bottom: none;">Mi is ez az oldal?</h2>
      <p>Lorem ipsum dolor sit amet consectetur adipisicing elit. Harum, consequuntur natus sed eius minima ipsa ipsum nesciunt perferendis iure repellat ducimus, nemo facilis doloremque consectetur accusantium nisi, vel quibusdam. Distinctio.</p>
      <ul>
        <li>Horgolás</li>
        <li>Kötés</li>
        <li>Hímzés</li>
      </ul>
      <p>Lorem ipsum dolor, sit amet consectetur adipisicing elit. Rerum quod, blanditiis nostrum deserunt quas possimus saepe tempora earum consequuntur doloribus debitis voluptatibus atque totam accusamus aut. Vero modi quod vitae!</p>
    </div>

    <div class="harom_oszlop">
        <div class="kartya">
          <h3>Horgolás</h3>
          <p>Lorem ipsum, dolor sit amet consectetur adipisicing elit. Ut ipsum exercitationem fugit dolores facere totam? Ex sit deserunt laudantium ab quasi iure consequuntur, repellendus et dicta sapiente explicabo dolorum! Sunt.</p>
        </div>
        <div class="kartya">
          <h3>Kötés</h3>
          <p>Lorem ipsum dolor sit amet consectetur adipisicing elit. Suscipit asperiores minima perferendis officiis aliquam quis facilis fuga eum doloremque ipsam, nostrum, dolorem dicta quidem eaque veniam quisquam, a molestiae quibusdam!</p>
        </div>
        <div class="kartya">
          <h3>Hímzés</h3>
          <p>Lorem, ipsum dolor sit amet consectetur adipisicing elit. Soluta, aliquam dolores. Fugiat, dolorum! Earum sint quae laudantium ea consectetur ducimus placeat ab, ipsum incidunt veniam ullam soluta hic excepturi illum.</p>
        </div>
    </div>

    <div class="ket_oszlop">
      <div class="adatok">
        <p>Milyen projektet szeretne készíteni?</p>
        <div id="tipusok">
          <input type="radio" name="tipus" id="1">
          <label for="tipus">Horgolás</label><br>
          <input type="radio" name="tipus" id="2">
          <label for="tipus">Kötés</label><br>
          <input type="radio" name="tipus" id="3">
          <label for="tipus">Hímzés</label><br>
        </div>

        <p>Milyen vastag fonalból készülne?</p> <!--hímzésnél nyilván ne lehessen választani, disabled lesz-->
        <div id="fonalCsoportok">
          <input type="radio" name="fonal" id="1">
          <label for="fonal">'A' fonal csoport</label><br>
          <input type="radio" name="fonal" id="2">
          <label for="fonal">'B' fonal csoport</label><br>
          <input type="radio" name="fonal" id="3">
          <label for="fonal">'C' fonal csoport</label><br>
          <input type="radio" name="fonal" id="4">
          <label for="fonal">'D' fonal csoport</label><br>
          <input type="radio" name="fonal" id="5">
          <label for="fonal">'E' fonal csoport</label><br>
        </div>
      </div>

      <div class="adatok" id="vmiSzar">
        <p>Válassza ki a fájlt:</p>
        <input type="file" name="kepFeltoltes" id="" accept="image/*">

        <p></p>
        <form action="">
          <input type="range" name="meret" id="" min="20" max="200" step="1" value="100" oninput="this.form.mennyi.value=this.value">
          <!--https://www.w3schools.com/howto/tryit.asp?filename=tryhow_css_js_rangeslider_round-->
          <input type="number" name="mennyi" min="20" max="200" value="100" oninput="this.form.meret.value=this.value" />
        </form>
        

        <p id="meretKiiras"></p>

      </div>
    </div>
  

    
  </main>
</template>


<style scoped>
/* a színek placeholderesek*/
  main {
    margin: 87px auto 0 auto;
    background-color: rgb(241, 228, 212);
    padding: 20px;
    height: auto;
  }

  .title {
    text-align: center;
    margin-bottom: 30px;
  }

  #bemutato {
    background-color: #f3c78e;
    max-width: 1200px;
    margin: auto;
    padding: 10px 50px 10px 50px;
    text-align: justify;
    margin-bottom: 50px;
    border-radius: 10px;
    box-shadow: rgba(50, 50, 93, 0.25) 0px 2px 5px -1px, rgba(0, 0, 0, 0.3) 0px 1px 3px -1px;
  }

  /*3 oszlop - még nem reszponzív */
  .harom_oszlop {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    gap: 50px;
    margin-bottom: 50px;
    padding:1rem;
  }

  .kartya {
    background-color: rgb(243, 199, 142);
    text-align: justify;
    padding: 20px;
    border-radius: 10px;
    box-shadow: rgba(50, 50, 93, 0.25) 0px 2px 5px -1px, rgba(0, 0, 0, 0.3) 0px 1px 3px -1px;
    /* vagy innen valami: https://getcssscan.com/css-box-shadow-examples */
  }  

  .ket_oszlop {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 20px;
    margin-bottom: 50px;
    padding:1rem;
    justify-items: center;

  }

  .adatok {
    background-color: rosybrown;
    text-align: justify;
    padding: 20px;
    max-width: 650px;
    border-radius: 10px;
    box-shadow: rgba(50, 50, 93, 0.25) 0px 2px 5px -1px, rgba(0, 0, 0, 0.3) 0px 1px 3px -1px;
    width: 100%;
  }
  
  #tipusok, #fonalCsoportok {
    margin-left: 20px;
  }

</style>