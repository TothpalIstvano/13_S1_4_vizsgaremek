<template>
  <div class="page-container">
    <section class="cards-wrapper">
      <div class="card-grid-space">
        <div class="card">
          <div class="card-img-holder">
            <img src="@/components/icons/Cart.png" alt="HTML Syntax">
          </div>
          <h3 class="blog-title">HTML Syntax</h3>
          <span class="blog-time">6 Oct 2017</span>
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
            <img src="https://images1-focus-opensocial.googleusercontent.com/gadgets/proxy?container=focus&resize_w=1500&url=https://codetheweb.blog/assets/img/posts/basic-types-of-html-tags/cover.jpg" alt="HTML Tags">
          </div>
          <h3 class="blog-title">Basic types of HTML tags</h3>
          <span class="blog-time">9 Oct 2017</span>
          <p class="description">
            Learn about some of the most common HTML tags…
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
            <img src="https://images1-focus-opensocial.googleusercontent.com/gadgets/proxy?container=focus&resize_w=1500&url=https://codetheweb.blog/assets/img/posts/links-images-about-file-paths/cover.jpg" alt="Links and Images">
          </div>
          <h3 class="blog-title">Links, images and about file paths</h3>
          <span class="blog-time">14 Oct 2017</span>
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
    </section>
  </div>
</template>

<script>
export default {
  name: 'HybridCard',
  methods: {
    navigateToBlog() {
      // Handle navigation to blog
      this.$router.push('/');
    }
  }
}
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Rubik:wght@300;400;500;600&display=swap');
@import url('https://fonts.googleapis.com/css?family=Heebo:400,700|Open+Sans:400,700');

:root {
  --color: #3c3163;
  --transition-time: 0.5s;
}

.page-container {
  background: #fafafa;
  min-height: 100vh;
  padding: 2rem 0;
}
/* Cards Grid */
.cards-wrapper {
  display: grid;
  justify-content: center;
  align-items: center;
  grid-template-columns: 1fr 1fr 1fr;
  grid-gap: 4rem;
  padding: 4rem;
  margin: 0 auto;
  width: max-content;
}

.card-grid-space {
  position: relative;
}

/* Hybrid Card Styles */
.card {
  width: 25rem;
  height: auto;
  background: #fff;
  border-radius: 1.5rem;
  padding: 1.5rem;
  overflow: hidden;
  position: relative;
  font-family: 'Rubik', sans-serif;
  box-sizing: border-box;
  box-shadow: 0 0 5em -1em rgba(0,0,0,0.1);
  transition: all, var(--transition-time);
  /* border: 10px solid #f0f0f0; */
}

.card:hover {
  transform: translateY(-5px);
  box-shadow: 0 10px 30px rgba(0,0,0,0.15);
  /*border-color: var(--color);*/
}


.card-img-holder {
  width: 100%;
  height: auto;
  position: relative;
  overflow: hidden;
  border-radius: 1.5rem;
  margin-bottom: 1rem;
}

.card-img-holder img {
  width: 100%;
  height: auto;
  max-height: 15rem;
  object-fit: cover;
  transition: all, var(--transition-time);
}

.card:hover .card-img-holder img {
  transform: scale(1.05);
}

.blog-title {
  color: #22215B;
  padding: 1rem 0 0.5rem 0;
  font-size: 1.5rem;
  margin: 0;
  transition: all, var(--transition-time);
}

.card:hover .blog-title {
  color: var(--color);
}

.description {
  padding: 1rem 0;
  color: #22215B80;
  font-size: 1rem;
  margin: 0;
  line-height: 1.6;
}

.blog-time {
  font-size: .8rem;
  color: #22215B;
  display: block;
  opacity: 0.7;
}

.tags {
  display: flex;
  margin: 1rem 0;
}

.tags .tag {
  font-size: 0.75em;
  background: rgba(60, 49, 99, 0.1);
  color: var(--color);
  border-radius: 0.3rem;
  padding: 0.3em 0.8em;
  margin-right: 0.5em;
  line-height: 1.5em;
  transition: all, var(--transition-time);
  font-weight: 500;
}

.card:hover .tags .tag {
    background: var(--color); /* Change color on hover */
    color: rgb(255, 0, 0); /* Change text color on hover */
    transform: translateY(-2px);
}

.options {
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: 1rem;
  margin-top: 1rem;
  padding-top: 1rem;
  border-top: 1px solid #f0f0f0;
}

.options span {
  font-weight: 600;
  color: #22215B;
  transition: all, var(--transition-time);
}

.card:hover .options span {
  color: var(--color);
}

.btn {
  font-size: 1rem;
  padding: .5rem 1.5rem;
  border-radius: .5rem;
  font-weight: 400;
  background: #EEF7FE;
  color: #22215B;
  cursor: pointer;
  border: none;
  transition: all, var(--transition-time);
}

.btn:hover {
  background: var(--color);
  color: white;
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
  transition: all, var(--transition-time);
  transition-timing-function: ease-in-out;
}

.card:before {
  background: rgba(60, 49, 99, 0.05);
  width: 250%;
  height: 250%;
}

.card:after {
  background: rgba(255,255,255,0.5);
  width: 200%;
  height: 200%;
}

.card:hover:before, .card:hover:after {
  transform: scale(1);
}

/* MEDIA QUERIES */
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
    padding: 4rem 2rem;
  }
  .card {
    max-width: calc(100vw - 4rem);
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