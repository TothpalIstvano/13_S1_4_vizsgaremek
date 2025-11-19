<script>
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import { faFacebook, faInstagram, faTwitter, faLinkedin, faGithub, faTelegram } from '@fortawesome/free-brands-svg-icons'
import { library } from '@fortawesome/fontawesome-svg-core'

library.add(faFacebook, faInstagram, faTwitter, faLinkedin, faGithub, faTelegram)

export default {
  components: {
    FontAwesomeIcon
  }
}
</script>

<template>
  <main>
    <h1 id="cim">Rólunk</h1>

    <div class="kontener egesz-kontener">
      <div class="kontener felso-resz">
        <div class="kepdiv">
          <img class="kep" src="@\assets\public\rolunk_asztal.avif">
          <div class="piros-doboz">
            <p class="piros-doboz-szoveg">
              Lorem ipsum dolor sit amet, consectetur adipiscing elit. Eget purus lectus viverra in semper nec pretium mus.
            </p>
            <img class="stars" src="https://workik-widget-assets.s3.amazonaws.com/widget-assets/images/mp5.svg">
          </div>
        </div>
        <div class="szovegek">
          <p class="szoveg-stilus cimszoveg">
            About Me
          </p>
          <p class="szoveg-stilus also-cimszoveg">
            Lorem ipsum dolor sit amet, consectetur adipiscing elit.
          </p>
          <p class="szoveg-stilus leiras">
            Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fermentum pulvinar ullamcorper suspendisse ac eget. Pellentesque tempus leo in ullamcorper quis vestibulum ligula elementum ut. Lorem ipsum dolor sit amet consectetur adipisicing elit. Optio odit inventore, obcaecati dolore atque modi doloribus, deleniti quae, quis rem totam. Magnam distinctio esse adipisci qui delectus repellendus in corporis?
          </p>
          <a class="gomb">
            View Services
          </a>
        </div>
      </div>

      <hr>

      <h1>Csapatunk: </h1>
      <div class="cardscontainer">
        <div class="card">
          <button class="mail">
              <a href="#" aria-label="Email">
                <FontAwesomeIcon :icon="['fab', 'telegram']" id="emailicon"/>
              </a>
          </button>
          
          <div class="profile-pic">
              <img src="@\assets\public\noi_profil.jpg" alt="Profilkép">
          </div>
          
          <div class="bottom">
              <div class="content">
                  <span class="name">My Name</span>
                  <span class="about-me">Lorem ipsum dolor sit amet consectetur adipiscing</span>
              </div>
              <div class="bottom-bottom">
                  <div class="social-links-container">
                      <a href="#" aria-label="Instagram">
                          <FontAwesomeIcon :icon="['fab', 'instagram']" class="icons"/>
                      </a>
                      <a href="#" aria-label="Facebook">
                          <FontAwesomeIcon :icon="['fab', 'twitter']" class="icons"/>
                      </a>
                      <a href="#" aria-label="GitHub">
                          <FontAwesomeIcon :icon="['fab', 'github']" class="icons"/>
                      </a>
                  </div>
                  <button class="button">Contact Me</button>
              </div>
          </div>
        </div>

        <!-- Kék kártya-->
        <div class="kártya">
          <button class="emailcim">
              <a href="#" aria-label="Email">
                <FontAwesomeIcon :icon="['fab', 'telegram']" id="emailikon"/>
              </a>
          </button>
          
          <div class="profilkep">
              <img src="@\assets\public\ferfi_profil.jpg" alt="Profilkép">
          </div>
          
          <div class="alsosav">
              <div class="content">
                  <span class="name">My Name</span>
                  <span class="about-me">Lorem ipsum dolor sit amet consectetur adipiscing</span>
              </div>
              <div class="alsosav-alsosav">
                  <div class="social-links-container">
                      <a href="#" aria-label="Instagram">
                          <FontAwesomeIcon :icon="['fab', 'instagram']" class="ikonok"/>
                      </a>
                      <a href="#" aria-label="Facebook">
                          <FontAwesomeIcon :icon="['fab', 'twitter']" class="ikonok"/>
                      </a>
                      <a href="#" aria-label="GitHub">
                          <FontAwesomeIcon :icon="['fab', 'github']" class="ikonok"/>
                      </a>
                  </div>
                  <button class="button">Contact Me</button>
              </div>
          </div>
        </div>
      </div>
    </div>

  </main>
</template>

<style scoped>
*, *::before, *::after {
  box-sizing: border-box;
}

main {
  text-align: center;
}

#cim {
  display: inline-block;
  font-weight: 700;
  font-size: 45px;
  background-image: linear-gradient(90deg, rgb(223, 130, 130), rgb(199, 71, 71));
  background-repeat: no-repeat;
  background-position: 0 100%;
  background-size: 100% 4px;
  padding-bottom: 6px;
}

/* #region felső boxok */
.kontener {
  min-height: 75px;
  height: fit-content;
  width: 100%;
  padding: 10px;
  display: flex;
  flex-wrap: wrap;
  margin: 0px auto;
  justify-content: flex-start;
}

.szoveg-stilus {
  margin: 0px;
  padding: 10px;
  line-height: 25px;
}

.kontener.egesz-kontener {
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 10px 50px;
}

.kep {
  color: black;
  width: 100%;
  height: auto;
  border-radius: 10px;
}

.szovegek {
  padding: 0px;
  width: 45%;
  margin: 0px;
  text-align: justify;
}

.szoveg-stilus.cimszoveg {
  font-size: 22px;
  font-weight: 700;
  line-height: 30px;
  color: rgb(199, 71, 71);
  margin-bottom: 5px;
}

.szoveg-stilus.also-cimszoveg {
  color: rgb(102, 102, 102);
  font-size: 26px;
  line-height: 32px;
  font-weight: 700;
  margin-bottom: 15px;
}

.szoveg-stilus.leiras {
  font-size: 18px;
  line-height: 26px;
  color: rgb(102, 102, 102);
  margin-bottom: 50px;
  font-weight: 400;
  padding-right: 10px;
}

.gomb {
  font-size: 16px;
  line-height: 28px;
  color: rgb(102, 102, 102);
  border: 2px solid rgb(102, 102, 102);
  cursor: pointer;
  background-color: white;
  margin: 0px;
  padding: 8px 40px;
}

.gomb:hover {
  background-color: rgb(199, 71, 71);
  color: white;
}

.kontener.felso-resz {
  margin-top: 80px;
  margin-right: auto;
  margin-bottom: 50px;
  margin-left: auto;
  justify-content: center;
  align-items: center;
  max-width: 1320px;
  padding: 10px;
  flex-direction: row-reverse;
  position: static;
}

.szovegek{
  margin-right: 40px;
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  justify-content: flex-start;
  padding-right: 15px;
}

.piros-doboz {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  max-width: 430px;
  background-color: rgb(199, 71, 71);
  padding: 20px;
  border-radius: 10px;
  position: absolute;
  bottom: -35px;
  left: -8%;
}

.piros-doboz-szoveg {
  font-size: 18px;
  line-height: 26px;
  color: white;
  margin-bottom: 10px;
}

.kepdiv {
  width: 50%;
  position: relative;
}

@media (max-width: 1024px) {
  .kontener.felso-resz {
    max-width: 850px;
  }

  .kep {
    width: 55%;
    height: auto;
  }

  .kontener.felso-resz {
    max-width: 830px;
  }

  .szoveg-stilus.also-cimszoveg {
    text-align: left;
    font-size: 26px;
    line-height: 32px;
  }

  .kontener.felso-resz {
    justify-content: space-evenly;
    padding: 10px 0px;
    max-width: 930px;
  }

  .piros-doboz {
    margin-top: 80px;
  }

  .szovegek {
    width: 40%;
  }

  .kep {
    width: 100%;
  }
}

@media (max-width: 768px) {
  .szovegek {
    width: 100%;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
  }

  .kontener.felso-resz {
    flex-direction: column;
    height: auto;
    flex-direction: column;
  }

  .kep {
    width: 100%;
    margin-bottom: -70px;
  }

  .piros-doboz {
    position: static;
  }

  .szovegek {
    width: 100%;
    align-items: flex-start;
  }

  .szoveg-stilus.cimszoveg, .szoveg-stilus.also-cimszoveg, .szoveg-stilus.leiras{
    text-align: left;
  }

  .kepdiv {
    position: relative;
    width: 100%;
  }

}

@media (max-width: 500px) {
  .szovegek {
    margin-top: 30px;
  }

}
/* #endregion*/

hr {
  width: 96%;
  border: none;
  border-top: 3px double #333333;
  color: #333333;
  overflow: visible;
  text-align: center;
  height: 5px;
}

hr::after {
  background-color: var(--bg);
  content: "(ﾉ◕ヮ◕)ﾉ*:･ﾟ✧";
  padding: 0 4px;
  position: relative;
  top: -13px;
}

.card, .kártya{
  width: 340px;
  height: 340px;
  background: white;
  border-radius: 32px;
  padding: 3px;
  position: relative;
  box-shadow: #604b4a30 0px 70px 30px -50px;
  transition: all 0.5s ease-in-out;
}

.cardscontainer {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 100px;
  margin-top: 32px;
}

@media (max-width: 768px) {
  .cardscontainer {
    flex-direction: column;
    align-items: center;
  }
}

/* #region női kártya*/
.card .mail {
  position: absolute;
  right: 32px;
  top: 22px;
  background: transparent;
  border: none;
}

#emailicon {
  color: #fbb9b6;
  font-size: 25px;
}

#emailicon:hover {
  color: #f55d56;
}

.card .profile-pic {
  position: absolute;
  width: calc(100% - 6px);
  height: calc(100% - 6px);
  top: 3px;
  left: 3px;
  border-radius: 29px;
  z-index: 1;
  border: 0px solid #fbb9b6;
  overflow: hidden;
  transition: all 0.5s ease-in-out 0.2s, z-index 0.5s ease-in-out 0.2s;
}

.card .profile-pic img {
  -o-object-fit: cover;
  object-fit: cover;
  width: 100%;
  height: 100%;
  -o-object-position: 0px 0px;
  object-position: 0px 0px;
  transition: all 0.5s ease-in-out 0s;
}

.card .bottom {
  position: absolute;
  bottom: 3px;
  left: 3px;
  right: 3px;
  background: #fbb9b6;
  top: 80%;
  border-radius: 29px;
  z-index: 2;
  box-shadow: rgba(96, 75, 74, 0.1882352941) 0px 5px 5px 0px inset;
  overflow: hidden;
  transition: all 0.5s cubic-bezier(0.645, 0.045, 0.355, 1) 0s;
}

.card .bottom .content {
  position: absolute;
  bottom: 0;
  left: 24px;
  right: 24px;
  height: 160px;
  cursor: default;
}

.card .bottom .content .name {
  display: block;
  font-size: 19px;
  color: white;
  font-weight: bold;
}

.card .bottom .content .about-me {
  display: block;
  font-size: 15px;
  color: white;
  margin-top: 16px;
}

.card .bottom .bottom-bottom {
  position: absolute;
  bottom: 16px;
  left: 24px;
  right: 24px;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.card .bottom .bottom-bottom .social-links-container {
  display: flex;
  gap: 16px;
}

.icons {
  height: 20px;
  color: white;
  filter: drop-shadow(0 5px 5px rgba(165, 132, 130, 0.1333333333));
}

.icons:hover {
  color: #f55d56;
  transform: scale(1.2);
}

.card .bottom .bottom-bottom .button {
  background: white;
  color: #fbb9b6;
  border: none;
  border-radius: 20px;
  font-size: 15px;
  padding: 7px 10px;
  box-shadow: rgba(165, 132, 130, 0.1333333333) 0px 5px 5px 0px;
}

.card .bottom .bottom-bottom .button:hover {
  background: #f55d56;
  color: white;
  cursor: pointer;
}

.card:hover {
  border-top-left-radius: 55px;
}

.card:hover .bottom {
  top: 20%;
  border-radius: 80px 29px 29px 29px;
  transition: all 0.5s cubic-bezier(0.645, 0.045, 0.355, 1) 0.2s;
}

.card:hover .profile-pic {
  width: 100px;
  height: 100px;
  aspect-ratio: 1;
  top: 10px;
  left: 10px;
  border-radius: 50%;
  z-index: 3;
  border: 7px solid #fbb9b6;
  box-shadow: rgba(96, 75, 74, 0.1882352941) 0px 5px 5px 0px;
  transition: all 0.5s ease-in-out, z-index 0.5s ease-in-out 0.1s;
}

.card:hover .profile-pic:hover {
  transform: scale(1.3);
  border-radius: 0px;
}

.card:hover .profile-pic img {
  transform: scale(2.5);
  -o-object-position: 0px 25px;
  object-position: 0px 25px;
  transition: all 0.5s ease-in-out 0.5s;
}

/* #endregion*/

/* #region férfi kártya*/
.kártya .emailcim {
  position: absolute;
  right: 2rem;
  top: 22px;
  background: transparent;
  border: none;
}

#emailikon {
  color: #80d0f5;
  font-size: 25px;
}

#emailikon:hover {
  color: #2779f3;
}

.kártya .profilkep {
  position: absolute;
  width: calc(100% - 6px);
  height: calc(100% - 6px);
  top: 3px;
  left: 3px;
  border-radius: 29px;
  z-index: 1;
  border: 0px solid #80d0f5;
  overflow: hidden;
  transition: all 0.5s ease-in-out 0.2s, z-index 0.5s ease-in-out 0.2s;
}

.kártya .profilkep img {
  -o-object-fit: cover;
  object-fit: cover;
  width: 100%;
  height: 100%;
  -o-object-position: 0px 0px;
  object-position: 0px 0px;
  transition: all 0.5s ease-in-out 0s;
}

.kártya .alsosav {
  position: absolute;
  bottom: 3px;
  left: 3px;
  right: 3px;
  background: #80d0f5;
  top: 80%;
  border-radius: 29px;
  z-index: 2;
  box-shadow: rgba(96, 75, 74, 0.1882352941) 0px 5px 5px 0px inset;
  overflow: hidden;
  transition: all 0.5s cubic-bezier(0.645, 0.045, 0.355, 1) 0s;
}

.kártya .alsosav .content {
  position: absolute;
  bottom: 0;
  left: 24px;
  right: 24px;
  height: 160px;
  cursor: default;
}

.kártya .alsosav .content .name {
  display: block;
  font-size: 19px;
  color: white;
  font-weight: bold;
}

.kártya .alsosav .content .about-me {
  display: block;
  font-size: 15px;
  color: white;
  margin-top: 16px;
}

.kártya .alsosav .alsosav-alsosav {
  position: absolute;
  bottom: 16px;
  left: 24px;
  right: 24px;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.kártya .alsosav .alsosav-alsosav .social-links-container {
  display: flex;
  gap: 16px;
}

.ikonok {
  height: 20px;
  color: white;
  filter: drop-shadow(0 5px 5px rgba(165, 132, 130, 0.1333333333));
}

.ikonok:hover {
  color: #2779f3;
  transform: scale(1.2);
}

.kártya .alsosav .alsosav-alsosav .button {
  background: white;
  color: #80d0f5;
  border: none;
  border-radius: 20px;
  font-size: 15px;
  padding: 7px 10px;
  box-shadow: rgba(165, 132, 130, 0.1333333333) 0px 5px 5px 0px;
}

.kártya .alsosav .alsosav-alsosav .button:hover {
  background: #2779f3;
  color: white;
  cursor: pointer;
}

.kártya:hover {
  border-top-left-radius: 55px;
}

.kártya:hover .alsosav {
  top: 20%;
  border-radius: 80px 29px 29px 29px;
  transition: all 0.5s cubic-bezier(0.645, 0.045, 0.355, 1) 0.2s;
}

.kártya:hover .profilkep {
  width: 100px;
  height: 100px;
  aspect-ratio: 1;
  top: 10px;
  left: 10px;
  border-radius: 50%;
  z-index: 3;
  border: 7px solid #80d0f5;
  box-shadow: rgba(96, 75, 74, 0.1882352941) 0px 5px 5px 0px;
  transition: all 0.5s ease-in-out, z-index 0.5s ease-in-out 0.1s;
}

.kártya:hover .profilkep:hover {
  transform: scale(1.3);
  border-radius: 0px;
}

.kártya:hover .profilkep img {
  transform: scale(2.5);
  -o-object-position: 0px 25px;
  object-position: 0px 25px;
  transition: all 0.5s ease-in-out 0.5s;
}
/* #endregion*/
</style>
