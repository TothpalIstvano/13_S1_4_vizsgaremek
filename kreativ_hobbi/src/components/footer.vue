<script setup>
import { RouterLink } from 'vue-router'
import { ref } from 'vue'

const adatvedelemFile = async () => {
  const response = await fetch('/assets/Public/Adatkezelési-tájékoztató.docx')
  const blob = await response.blob()
  const url = window.URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.download = 'Adatkezelési-tájékoztató.docx'
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
  window.URL.revokeObjectURL(url)
}

const adatfelhasznalasFile = async () => {
  const response = await fetch('/assets/Public/Adatfelhasználási-tájékoztató.docx')
  const blob = await response.blob()
  const url = window.URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.download = 'Adatfelhasználási-tájékoztató.docx'
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
  window.URL.revokeObjectURL(url)
}
</script>

<template>
  <footer class="footer">
    <div class="footer-content">
      <div class="footer-section">
        <h3>Elérhetőségek</h3>
        <p>Cím: 1234 Budapest, Fő utca 1.</p>
        <p>Telefon: +36 1 234 5678</p>
        <p>Email: info@hobbitar.hu</p>
      </div>
      <div class="footer-section">
        <h3>Oldalak</h3>
        <div class="footer-links">
          <RouterLink to="/rolunk" class="link">Rólunk</RouterLink>
          <p @click="adatvedelemFile" class="link">Adatvédelem</p>
          <p @click="adatfelhasznalasFile" class="link">Adatfelhasználás</p>
        </div>
      </div>
      <div class="footer-section">
        <h3>Térkép</h3>
        <iframe
          src="https://www.openstreetmap.org/export/embed.html?bbox=19.040236%2C47.497913%2C19.040236%2C47.497913&amp;layer=mapnik"
          style="border:1px solid #ccc; width:100%; height:120px;"
          allowfullscreen
          loading="lazy"
          referrerpolicy="no-referrer-when-downgrade"
        ></iframe>
      </div>
    </div>
    <div class="footer-bottom">
      🄯 2025-2026 Hobbitár. Minden jog fenntartva.
    </div>
  </footer>
</template>

<style scoped>

.footer {
  background: var(--navbar-bg);
  color: var(--vt-c-white);
  padding: 30px ;
  font-size: 1rem;
  margin-top: 3%;
  box-sizing: border-box;
}

.footer-content {
  display: flex;
  flex-wrap: wrap;
  justify-content: space-around;
  gap: 2rem;
  max-width: 80%;
  height: 150px;
  margin: 0 auto;
}

.footer-section {
  flex: 1 1 200px;
  min-width: 200px;
}

.footer-section h3 {
  margin-bottom: 0.5rem;
  color: var(--router-link-color);
}

.footer-section a {
  color: var(--text);
  text-decoration: none;
}

.footer-section a:hover {
  text-decoration: underline;
}

.footer-bottom {
  text-align: center;
  margin-top: 20px;
  font-size: 0.95rem;
  color: var(--router-link-color);
}

.link:hover {
  cursor: pointer;
  font-weight: bold;
}

.footer-links {
  /*display: flex;
  flex-direction: column;*/
  gap: 1rem; /* Adjust this value for bigger/smaller gaps */
  text-decoration: underline;
}
@media (max-width: 700px) {
  .footer-section {
    min-width: unset;
    width: 100%;
    text-align: center;
    flex: 100%;
  }
}
</style>
