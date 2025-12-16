<template>
<main>
  <h1 class="title">Blog</h1>
    <section class="cards-wrapper">
      <!-- Loading state -->
      <div v-if="loading" class="loading">
        <p>Blogbejegyzések betöltése...</p>
        <div class="three-body">
          <div class="three-body__dot"></div>
          <div class="three-body__dot"></div>
          <div class="three-body__dot"></div>
        </div>
      </div>
      
      <!-- Error state -->
      <div v-if="error" class="error">
        <p>{{ error }}</p>
      </div>
      
      <!-- Blog posts -->
      <div class="card-grid-space" v-for="post in posztok" :key="post.id">
        <div class="card">
          <div class="card-img-holder">
            <img 
              :src="getImageUrl(post.fo_kep)" 
              :alt="post.cim"
              @error="handleImageError"
            />
          </div>
          <h3 class="blog-title">{{ post.cim }}</h3>
          <span class="blog-time"> 
            <font-awesome-icon icon="fa-solid fa-calendar" class="naptar"/> 
            <i class="fa fa-calendar" aria-hidden="true"></i>
            {{ formatDate(post.letrehozas_datuma) }}
          </span>
          <p class="description">
            {{ post.kivonat || post.tartalom || 'Nincs leírás...' }}
          </p>
          <div class="tags">
            <div class="tag" v-for="tag in post.cimkek" :key="tag">{{ tag }}</div>
          </div>
          <div class="options">
            <button class="Btn">
              <span class="leftContainer">
                <svg fill="white" viewBox="0 0 512 512" height="1em" xmlns="http://www.w3.org/2000/svg"><path d="M47.6 300.4L228.3 469.1c7.5 7 17.4 10.9 27.7 10.9s20.2-3.9 27.7-10.9L464.4 300.4c30.4-28.3 47.6-68 47.6-109.5v-5.8c0-69.9-50.5-129.5-119.4-141C347 36.5 300.6 51.4 268 84L256 96 244 84c-32.6-32.6-79-47.5-124.6-39.9C50.5 55.6 0 115.2 0 185.1v5.8c0 41.5 17.2 81.2 47.6 109.5z"></path></svg>
                <span class="like">Like</span>
              </span>
              <span class="likeCount">2,050</span>
            </button>
            <!--<span>Teljes bejegyzés olvasása</span>-->
            <button class="btn" @click="navigateToBlog(post.id)">Megtekintés →</button>
          </div>
        </div>
      </div>
      
      <!-- No posts message -->
      <div v-if="!loading && posztok.length === 0" class="no-posts">
        <p>Még nincsenek blog bejegyzések.</p>
      </div>
    </section>
</main>
</template>

<script>
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import { library } from '@fortawesome/fontawesome-svg-core'
import { faCalendar } from '@fortawesome/free-solid-svg-icons'

library.add(faCalendar)

import api from '@/services/api.js'

// Import your fallback image at the top
import fallbackImage from '@/assets/Public/b-pl1.jpg'

export default {
  name: 'Blog',
  data() {
    return {
      posztok: [],
      loading: true,
      error: null
    }
  },
  methods: {
    async navigateToBlog(postId) {
      this.$router.push(`/blog/${postId}`);
    },
    async fetchBlogPosts() {
      try {
        this.loading = true;
        this.error = null;
        
        // Fetch blog posts
        const response = await api.get('/api/blog');
        this.posztok = response.data;
        
      } catch (error) {
        console.error('Error fetching blog posts:', error);
        this.error = 'Hiba történt a blog bejegyzések betöltése közben.';
        this.posztok = this.getDummyPosts();
      } finally {
        this.loading = false;
      }
    },
    getImageUrl(imagePath) {
      // If no image or invalid path, use default
      if (!imagePath || typeof imagePath !== 'string') {
        return fallbackImage; // Use the imported image
      }
      
      // If it's already a full URL, return as is
      if (imagePath.startsWith('http')) {
        return imagePath;
      }
      
      // Otherwise, assume it's a relative path from storage
      return `http://localhost:8000/storage/${imagePath}`;
    },
    handleImageError(event) {
      // Set fallback image - use the imported image directly
      event.target.src = fallbackImage;
    },
    formatDate(dateString) {
      if (!dateString) return 'Ismeretlen dátum';
      return dateString;
    },
    getDummyPosts() {
      return [
        {
          id: 1,
          title: "HTML Syntax",
          excerpt: "The syntax of a language is how it works. How to actually write it. Learn HTML syntax…",
          created_at: "6 Oct 2017",
          tags: ["HTML"],
          main_image: null
        },
        {
          id: 2,
          title: "Basic types of HTML tags",
          excerpt: "Learn about some of the most common HTML tags…",
          created_at: "9 Oct 2017",
          tags: ["HTML", "CSS", "JavaScript", "Vue"],
          main_image: null
        }
      ];
    }
  },
  mounted() {
    this.fetchBlogPosts();
  },
  components: {
    FontAwesomeIcon
  }
}
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Rubik:wght@300;400;500;600&display=swap');
@import url('https://fonts.googleapis.com/css?family=Heebo:400,700|Open+Sans:400,700');

.Btn {
  width: 140px;
  height: 35px;
  display: flex;
  align-items: center;
  justify-content: flex-start;
  border: none;
  border-radius: 5px;
  overflow: hidden;
  box-shadow: 5px 5px 10px rgba(0, 0, 0, 0.089);
  cursor: pointer;
  background-color: transparent;
}

.leftContainer {
  width: 60%;
  height: 100%;
  background-color: rgb(238, 0, 0);
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.leftContainer .like {
  color: white;
  font-weight: 600;
}

.likeCount {
  width: 40%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: rgb(238, 0, 0);
  font-weight: 600;
  position: relative;
  background-color: white;
}

.likeCount::before {
  height: 8px;
  width: 8px;
  position: absolute;
  content: "";
  background-color: rgb(255, 255, 255);
  transform: rotate(45deg);
  left: -4px;
}

.Btn:hover .leftContainer {
  background-color: rgb(219, 0, 0);
}

.Btn:active .leftContainer {
  background-color: rgb(201, 0, 0);
}

.Btn:active .leftContainer svg {
  transform: scale(1.15);
  transform-origin: top;
}


main {
  min-height: 100vh;
  margin: 0;
  padding: 0;
  text-align: center;
}

.title {
  display: inline-block;
  font-weight: 700;
  font-size: 45px;
  color: var(--mk-text-dark);
  background-image: linear-gradient(90deg, #a08283, #4d0303);
  background-repeat: no-repeat;
  background-position: 0 100%;
  background-size: 100% 4px;
  padding-bottom: 6px;
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
  text-align: left;
}

.card-grid-space {
  position: relative;
}

.card {
  width: 520px;
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
}

.card:hover {
  transform: translateY(-5px);
  box-shadow: 0 10px 30px rgba(0,0,0,0.15);
  color: var(--b-text-dark);
}

.card-img-holder {
  width: 100%;
  height: 240px;
  position: relative;
  overflow: hidden;
  border-radius: 6px 40px 6px 40px;
  margin-bottom: 16px;
}

.card-img-holder img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: all, var(--b-transition-time);
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
  min-height: 80px;
  overflow: hidden;
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
  flex-wrap: wrap;
  margin: 16px 0;
  gap: 8px;
}

.tag {
  font-size: 12px;
  background: var(--b-tag);
  color: var(--b-text-light);
  border-radius: 5px;
  padding: 5px 13px;
  line-height: 24px;
  transition: all, var(--b-transition-time);
  font-weight: 500;
  box-shadow: inset 0px 0px 10px 1px rgba(80, 33, 0, 0.5);
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
  letter-spacing: 0.7px;
  background: var(--b-gomb);
  color: var(--b-text-light);
  cursor: pointer;
  border: none;
  transition: all, var(--b-transition-time);
  box-shadow: inset 0px 0px 10px 1px rgba(255, 254, 254, 0.5);
}

.btn:hover {
  background: var(--b-gomb-hover);
  transform: translateY(-2px);
}

.loading {
  text-align: center;
  align-items: center;
  position: absolute;
  padding-top: 100px;
  margin: 0;
}

.three-body {
 --uib-size: 35px;
 --uib-speed: 0.8s;
 --uib-color: #580303;
 position: relative;
 display: inline-block;
 height: var(--uib-size);
 width: var(--uib-size);
 animation: spin78236 calc(var(--uib-speed) * 2.5) infinite linear;
}

.three-body__dot {
 position: absolute;
 height: 100%;
 width: 30%;
}

.three-body__dot:after {
 content: '';
 position: absolute;
 height: 0%;
 width: 100%;
 padding-bottom: 100%;
 background-color: var(--uib-color);
 border-radius: 50%;
}

.three-body__dot:nth-child(1) {
 bottom: 5%;
 left: 0;
 transform: rotate(60deg);
 transform-origin: 50% 85%;
}

.three-body__dot:nth-child(1)::after {
 bottom: 0;
 left: 0;
 animation: wobble1 var(--uib-speed) infinite ease-in-out;
 animation-delay: calc(var(--uib-speed) * -0.3);
}

.three-body__dot:nth-child(2) {
 bottom: 5%;
 right: 0;
 transform: rotate(-60deg);
 transform-origin: 50% 85%;
}

.three-body__dot:nth-child(2)::after {
 bottom: 0;
 left: 0;
 animation: wobble1 var(--uib-speed) infinite
    calc(var(--uib-speed) * -0.15) ease-in-out;
}

.three-body__dot:nth-child(3) {
 bottom: -5%;
 left: 0;
 transform: translateX(116.666%);
}

.three-body__dot:nth-child(3)::after {
 top: 0;
 left: 0;
 animation: wobble2 var(--uib-speed) infinite ease-in-out;
}

@keyframes spin78236 {
 0% {
  transform: rotate(0deg);
 }

 100% {
  transform: rotate(360deg);
 }
}

@keyframes wobble1 {
 0%,
  100% {
  transform: translateY(0%) scale(1);
  opacity: 1;
 }

 50% {
  transform: translateY(-66%) scale(0.65);
  opacity: 0.8;
 }
}

@keyframes wobble2 {
 0%,
  100% {
  transform: translateY(0%) scale(1);
  opacity: 1;
 }

 50% {
  transform: translateY(66%) scale(0.65);
  opacity: 0.8;
 }
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

@media screen and (max-width: 1800px) {
  .card {
    width: 420px;
  }
}

@media screen and (max-width: 1500px) {
  .card {
    width: 400px;
  }
}

@media screen and (max-width: 1400px) {
  .cards-wrapper {
    grid-template-columns: 1fr 1fr;
  }
  .card {
    width: 520px;
  }
}

@media screen and (max-width: 1200px) {
  .card {
    width: 460px;
  }
}

@media screen and (max-width: 1050px) {
  .card {
    width: 400px;
  }
}

@media screen and (max-width: 950px) {
  .card {
    width: 380px;
  }
}

@media screen and (max-width: 890px) {
  .cards-wrapper {
    grid-template-columns: 1fr;
    padding: 26px;
  }
  .card {
    width: 520px;
  }
}

@media screen and (max-width: 600px) {
  .card {
    width: 400px;
  }
}

@media screen and (max-width: 450px) {
  .card {
    width: 300px;
  }
}
</style>