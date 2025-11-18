<template>
  <main >
    <div>
      <div class="card">
        <button class="mail">
            <!-- Using an SVG icon from a library like Lucide or Font Awesome -->
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <rect width="20" height="16" x="2" y="4" rx="2"></rect>
                <path d="m22 7-8.97 5.7a1.94 1.94 0 0 1-2.06 0L2 7"></path>
            </svg>
        </button>
        
        <!-- Replace the complex SVG with a simple image or much simpler SVG -->
        <div class="profile-pic">
            <img src="@\assets\Public\noi_profil.jpg" alt="Profilkép">
            <!-- OR use a much simpler SVG if needed -->
        </div>
        
        <div class="bottom">
            <div class="content">
                <span class="name">My Name</span>
                <span class="about-me">Lorem ipsum dolor sit amet consectetur adipiscing</span>
            </div>
            <div class="bottom-bottom">
                <div class="social-links-container">
                    <!-- Using icon libraries for social icons -->
                    <a href="#" aria-label="Instagram">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
                            <path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zM5.838 12a6.162 6.162 0 1 1 12.324 0 6.162 6.162 0 0 1-12.324 0zM12 16a4 4 0 1 1 0-8 4 4 0 0 1 0 8zm4.965-10.405a1.44 1.44 0 1 1 2.881.001 1.44 1.44 0 0 1-2.881-.001z"/>
                        </svg>
                    </a>
                    <a href="#" aria-label="Twitter">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
                            <path d="M23.953 4.57a10 10 0 01-2.825.775 4.958 4.958 0 002.163-2.723c-.951.555-2.005.959-3.127 1.184a4.92 4.92 0 00-2.184-2.718c.951-.192 1.937-.317 2.948-.317a12.02 12.02 0 01-3.656 3.447 12.02 12.02 0 01-6.586 1.928 12.018 12.018 0 01-3.658-3.447 12.02 12.02 0 01-1.928-6.586c0-1.898.433-3.695 1.207-5.291a14.95 14.95 0 005.291 1.207c1.898 0 3.695-.433 5.291-1.207a12.02 12.02 0 01-1.928 6.586z"/>
                        </svg>
                    </a>
                    <a href="#" aria-label="GitHub">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
                            <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/>
                        </svg>
                    </a>
                </div>
                <button class="button">Contact Me</button>
            </div>
        </div>
      </div>

      <!-- Kék kártya-->
       <div class="kártya">
        <button class="emailcim">
            <!-- Using an SVG icon from a library like Lucide or Font Awesome -->
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <rect width="20" height="16" x="2" y="4" rx="2"></rect>
                <path d="m22 7-8.97 5.7a1.94 1.94 0 0 1-2.06 0L2 7"></path>
            </svg>
        </button>
        
        <!-- Replace the complex SVG with a simple image or much simpler SVG -->
        <div class="profilkep">
            <img src="@\assets\Public\ferfi_profil.jpg" alt="Profilkép">
            <!-- OR use a much simpler SVG if needed -->
        </div>
        
        <div class="alsosav">
            <div class="content">
                <span class="name">My Name</span>
                <span class="about-me">Lorem ipsum dolor sit amet consectetur adipiscing</span>
            </div>
            <div class="alsosav-alsosav">
                <div class="social-links-container">
                    <!-- Using icon libraries for social icons -->
                    <a href="#" aria-label="Instagram">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
                            <path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zM5.838 12a6.162 6.162 0 1 1 12.324 0 6.162 6.162 0 0 1-12.324 0zM12 16a4 4 0 1 1 0-8 4 4 0 0 1 0 8zm4.965-10.405a1.44 1.44 0 1 1 2.881.001 1.44 1.44 0 0 1-2.881-.001z"/>
                        </svg>
                    </a>
                    <a href="#" aria-label="Facebook">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
                            <path d="M23.953 4.57a10 10 0 01-2.825.775 4.958 4.958 0 002.163-2.723c-.951.555-2.005.959-3.127 1.184a4.92 4.92 0 00-2.184-2.718c.951-.192 1.937-.317 2.948-.317a12.02 12.02 0 01-3.656 3.447 12.02 12.02 0 01-6.586 1.928 12.018 12.018 0 01-3.658-3.447 12.02 12.02 0 01-1.928-6.586c0-1.898.433-3.695 1.207-5.291a14.95 14.95 0 005.291 1.207c1.898 0 3.695-.433 5.291-1.207a12.02 12.02 0 01-1.928 6.586z"/>
                        </svg>
                    </a>
                    <a href="#" aria-label="GitHub">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
                            <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/>
                        </svg>
                    </a>
                </div>
                <button class="button">Contact Me</button>
            </div>
        </div>
      </div>
    </div>
    
    
  </main>
</template>

<style scoped>
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

.card .mail {
  position: absolute;
  right: 2rem;
  top: 1.4rem;
  background: transparent;
  border: none;
}

.kártya .emailcim {
  position: absolute;
  right: 2rem;
  top: 1.4rem;
  background: transparent;
  border: none;
}

.card .mail svg {
  stroke: #fbb9b6;
  stroke-width: 3px;
}

.card .mail svg:hover {
  stroke: #f55d56;
}

.kártya .emailcim svg {
  stroke: #80d0f5;
  stroke-width: 3px;
}

.kártya .emailcim svg:hover {
  stroke: #2779f3;
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

.card .profile-pic svg {
  width: 100%;
  height: 100%;
  -o-object-fit: cover;
  object-fit: cover;
  -o-object-position: 0px 0px;
  object-position: 0px 0px;
  transform-origin: 45% 20%;
  transition: all 0.5s ease-in-out 0s;
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

.card .bottom .content {
  position: absolute;
  bottom: 0;
  left: 1.5rem;
  right: 1.5rem;
  height: 160px;
}

.kártya .alsosav .content {
  position: absolute;
  bottom: 0;
  left: 1.5rem;
  right: 1.5rem;
  height: 160px;
}

.card .bottom .content .name {
  display: block;
  font-size: 1.2rem;
  color: white;
  font-weight: bold;
}

.kártya .alsosav .content .name {
  display: block;
  font-size: 1.2rem;
  color: white;
  font-weight: bold;
}

.card .bottom .content .about-me {
  display: block;
  font-size: 0.9rem;
  color: white;
  margin-top: 1rem;
}

.kártya .alsosav .content .about-me {
  display: block;
  font-size: 0.9rem;
  color: white;
  margin-top: 1rem;
}

.card .bottom .bottom-bottom {
  position: absolute;
  bottom: 1rem;
  left: 1.5rem;
  right: 1.5rem;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.kártya .alsosav .alsosav-alsosav {
  position: absolute;
  bottom: 1rem;
  left: 1.5rem;
  right: 1.5rem;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.card .bottom .bottom-bottom .social-links-container {
  display: flex;
  gap: 1rem;
}

.kártya .alsosav .alsosav-alsosav .social-links-container {
  display: flex;
  gap: 1rem;
}

.card .bottom .bottom-bottom .social-links-container svg {
  height: 20px;
  fill: white;
  filter: drop-shadow(0 5px 5px rgba(165, 132, 130, 0.1333333333));
}

.kártya .alsosav .alsosav-alsosav .social-links-container svg {
  height: 20px;
  fill: white;
  filter: drop-shadow(0 5px 5px rgba(165, 132, 130, 0.1333333333));
}

.card .bottom .bottom-bottom .social-links-container svg:hover {
  fill: #f55d56;
  transform: scale(1.2);
}

.kártya .alsosav .alsosav-alsosav .social-links-container svg:hover {
  fill: #2779f3;
  transform: scale(1.2);
}

.card .bottom .bottom-bottom .button {
  background: white;
  color: #fbb9b6;
  border: none;
  border-radius: 20px;
  font-size: 0.6rem;
  padding: 0.4rem 0.6rem;
  box-shadow: rgba(165, 132, 130, 0.1333333333) 0px 5px 5px 0px;
}

.kártya .alsosav .alsosav-alsosav .button {
  background: white;
  color: #80d0f5;
  border: none;
  border-radius: 20px;
  font-size: 0.6rem;
  padding: 0.4rem 0.6rem;
  box-shadow: rgba(165, 132, 130, 0.1333333333) 0px 5px 5px 0px;
}

.card .bottom .bottom-bottom .button:hover {
  background: #f55d56;
  color: white;
}

.kártya .alsosav .alsosav-alsosav .button:hover {
  background: #2779f3;
  color: white;
}

.card:hover {
  border-top-left-radius: 55px;
}

.kártya:hover {
  border-top-left-radius: 55px;
}

.card:hover .bottom {
  top: 20%;
  border-radius: 80px 29px 29px 29px;
  transition: all 0.5s cubic-bezier(0.645, 0.045, 0.355, 1) 0.2s;
}

.kártya:hover .alsosav {
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

.card:hover .profile-pic:hover {
  transform: scale(1.3);
  border-radius: 0px;
}

.kártya:hover .profilkep:hover {
  transform: scale(1.3);
  border-radius: 0px;
}

.card:hover .profile-pic img {
  transform: scale(2.5);
  -o-object-position: 0px 25px;
  object-position: 0px 25px;
  transition: all 0.5s ease-in-out 0.5s;
}

.kártya:hover .profilkep img {
  transform: scale(2.5);
  -o-object-position: 0px 25px;
  object-position: 0px 25px;
  transition: all 0.5s ease-in-out 0.5s;
}

.card:hover .profile-pic svg {
  transform: scale(2.5);
  transition: all 0.5s ease-in-out 0.5s;
}

.kártya:hover .profilkep svg {
  transform: scale(2.5);
  transition: all 0.5s ease-in-out 0.5s;
}

</style>
