<script>
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'

export default {
  name: 'HybridCard',
  methods: {
    navigateToBlog() {
      // Handle navigation to blog
      this.$router.push('/');
    }
  },
  components: {
    FontAwesomeIcon
  }
}
</script>

<template>
<main>
    <section class="cards-wrapper">
      <div class="card-grid-space">
        <div class="card">
          <div class="card-img-holder">
            <img src="..\assets\Public\b-pl1.jpg" alt="HTML Syntax">
          </div>
          <h3 class="blog-title">HTML Syntax</h3>
          <span class="blog-time"> <font-awesome-icon icon="fa-solid fa-calendar" class="naptar"/> 6 Oct 2017</span>
          <p class="description">
            The syntax of a language is how it works. How to actually write it. Learn HTML syntax…
          </p>
          <div class="tags">
            <div class="tag">HTML</div>
          </div>
          <div class="options">
            <span>
              Read Full Blog
            </span>
            <button class="btn" @click="navigateToBlog">Blog</button>
          </div>
        </div>
      </div>
      
      <div class="card-grid-space">
        <div class="card">
          <div class="card-img-holder">
            <img src="..\assets\Public\b-pl2.jpg" alt="HTML Tags">
          </div>
          <h3 class="blog-title">Basic types of HTML tags</h3>
          <span class="blog-time"> <font-awesome-icon icon="fa-solid fa-calendar" class="naptar"/> 9 Oct 2017</span>
          <p class="description">
            Learn about some of the most common HTML tags…
          </p>
          <div class="tags">
            <div class="tag">HTML</div>
            <div class="tag">CSS</div>
            <div class="tag">JavaScript</div>
            <div class="tag">Vue</div>
          </div>
          <div class="options">
            <span>
              Read Full Blog
            </span>
            <button class="btn" @click="navigateToBlog">Blog</button>
          </div>
        </div>
      </div>
      
      <div class="card-grid-space">
        <div class="card">
          <div class="card-img-holder">
            <img src="..\assets\Public\b-pl3.jpg" alt="Links and Images">
          </div>
          <h3 class="blog-title">Links, images and about file paths</h3>
          <span class="blog-time"> <font-awesome-icon icon="fa-solid fa-calendar" class="naptar"/> 14 Oct 2017</span>
          <p class="description">
            Learn how to use links and images along with file paths…
          </p>
          <div class="tags">
            <div class="tag">HTML</div>
          </div>
          <div class="options">
            <span>
              Read Full Blog
            </span>
            <button class="btn" @click="navigateToBlog">Blog</button>
          </div>
        </div>
      </div>

      <div class="card-grid-space">
        <div class="card">
          <div class="card-img-holder">
            <img src="..\assets\Public\b-pl4.jpg" alt="Links and Images">
          </div>
          <h3 class="blog-title">Your favourite lorem ipsum</h3>
          <span class="blog-time"> <font-awesome-icon icon="fa-solid fa-calendar" class="naptar"/> 14 Oct 2017</span>
          <p class="description">
            Learn how to use links and images along with file paths…
          </p>
          <div class="tags">
            <div class="tag">HTML</div>
            <div class="tag">CSS</div>
          </div>
          <div class="options">
            <span>
              Read Full Blog
            </span>
            <button class="btn" @click="navigateToBlog">Blog</button>
          </div>
        </div>
      </div>
    </section>
</main>
</template>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Rubik:wght@300;400;500;600&display=swap');
@import url('https://fonts.googleapis.com/css?family=Heebo:400,700|Open+Sans:400,700');

main {
  min-height: 100vh;
  padding: 32px 0;
}

.cards-wrapper {
  display: grid;
  justify-content: center;
  align-items: center;
  grid-template-columns: 1fr 1fr 1fr;
  grid-gap: 64px;
  padding: 64px;
  margin: 0 auto;
  width: max-content;
}

.card-grid-space {
  position: relative;
}

.card {
  width: 480px;
  height: auto;
  background: var(--b-kartya);
  color: var(--b-text-light);
  border-radius: 8px;
  padding: 24px;
  overflow: hidden;
  position: relative;
  font-family: 'Rubik', sans-serif;
  box-sizing: border-box;
  box-shadow: 0 0 80px -16px rgba(0,0,0,0.1);
  transition: all, var(--b-transition-time);
  /* border: 10px solid #f0f0f0; */
}

.card:hover {
  transform: translateY(-5px);
  box-shadow: 0 10px 30px rgba(0,0,0,0.15);
  color: var(--b-text-dark);
  /*border-color: #e0dddd;*/
}


.card-img-holder {
  width: 100%;
  height: auto;
  position: relative;
  overflow: hidden;
  border-radius: 4px 60px 8px 60px;
  margin-bottom: 16px;
}

.card-img-holder img {
  width: 100%;
  height: auto;
  max-height: 240px;
  object-fit: cover;
  transition: all, var(--b-transition-time);
  transform: scale(1.05); /* azért kell hogy rendesen nézzen ki a bal alsó border radiusa */
}

.card:hover .card-img-holder img {
  transform: scale(1.10);
}

.blog-title {
  padding: 16px 0 8px 0;
  font-size: 24px;
  margin: 0;
  transition: all, var(--b-transition-time);
}

.card:hover .blog-title {
  color: var(--b-text-dark);
}

.description {
  padding: 16px 0;
  font-size: 16px;
  margin: 0;
  line-height: 1.6;
}

.card:hover .description {
  color: var(--b-text-dark);  
}

.blog-time {
  font-size: 12px;
  display: block;
  opacity: 0.9;
}

.tags {
  display: flex;
  margin: 16px 0;
}

.tag {
  font-size: 12px;
  background: var(--b-tag);
  color: var(--b-text-light);
  border-radius: 0.3rem;
  padding: 0.3em 0.8em;
  margin-right: 0.5em;
  line-height: 1.5em;
  transition: all, var(--b-transition-time);
  font-weight: 500;
}

.card:hover .tag {
    background: var(--b-tag-hover);
    color: var(--b-text-dark);
    transform: translateY(-2px);
}

.options {
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: 16px;
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px solid var(--b-text-light);
}

.options span {
  font-weight: 600;
  transition: all, var(--b-transition-time);
}

.card:hover .options {
  color: var(--b-text-dark);
  border-top: 1px solid var(--b-text-dark);
}

.btn {
  font-size: 16px;
  padding: 8px 24px;
  border-radius: 8px;
  font-weight: 400;
  background: var(--b-gomb);
  color: var(--b-text-light);
  cursor: pointer;
  border: none;
  transition: all, var(--b-transition-time);
}

.btn:hover {
  background: var(--b-gomb-hover);
  color: var(--b-text-dark);
  transform: translateY(-2px);
}

/* Card hover effects */
.card:before, .card:after {
  content: '';
  transform: scale(0);
  transform-origin: top left;
  border-radius: 50%;
  position: absolute;
  left: -50%;
  top: -50%;
  z-index: -1;
  transition: all, var(--b-transition-time);
  transition-timing-function: ease-in-out;
}

.card:before {
  /*background: rgba(60, 49, 99, 0.05);*/
  width: 250%;
  height: 250%;
}

.card:after {
  background: #ffffff80;
  width: 200%;
  height: 200%;
}

.card:hover:before, .card:hover:after {
  transform: scale(1);
}

@media screen and (max-width: 1285px) {
  .cards-wrapper {
    grid-template-columns: 1fr 1fr;
  }
}

@media screen and (max-width: 900px) {
  .cards-wrapper {
    grid-template-columns: 1fr;
  }
  .info {
    justify-content: center;
  }
}

@media screen and (max-width: 768px) {
  .card {
    font-size: 15px;
  }
}

@media screen and (max-width: 500px) {
  .cards-wrapper {
    padding: 64px 32px;
  }
  .card {
    max-width: calc(100vw - 64px);
  }
}

@media screen and (max-width: 465px) {
  .card {
    font-size: 14px;
  }
}

@media screen and (max-width: 450px) {
  .info {
    display: block;
    text-align: center;
  }
  .info h1 {
    margin: 0;
  }
}
</style>