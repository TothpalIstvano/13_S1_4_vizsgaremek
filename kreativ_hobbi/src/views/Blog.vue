<script setup></script>

<template>
<section class="feature-section">
  <div class="feature-grid">
    <article class="feature-card">
      <div class="feature-icon" aria-hidden="true">🎨</div>
      <h3 class="feature-title">Mintakészítő</h3>
      <p class="feature-desc">
        Készíts személyre szabott mintákat saját képeid alapján. Kötés, horgolás és hímzés egy helyen.
      </p>
    </article>

    <article class="feature-card">
      <div class="feature-icon" aria-hidden="true">📦</div>
      <h3 class="feature-title">Minőségi termékek</h3>
      <p class="feature-desc">
        Prémium alapanyagok és eszközök a legszebb alkotásokhoz. Raktárról, gyors szállítással.
      </p>
    </article>

    <article class="feature-card">
      <div class="feature-icon" aria-hidden="true">📚</div>
      <h3 class="feature-title">Blog és közösség</h3>
      <p class="feature-desc">
        Oszd meg tapasztalataidat, tanulj másoktól és inspirálódj a közösségünk által.
      </p>
    </article>

    <article class="feature-card">
      <div class="feature-icon" aria-hidden="true">👥</div>
      <h3 class="feature-title">Szakértő segítség</h3>
      <p class="feature-desc">
        Tapasztalt kézművesek állnak rendelkezésedre, hogy segítsenek a projektjeidben.
      </p>
    </article>

    <article class="feature-card">
      <div class="feature-icon" aria-hidden="true">⭐</div>
      <h3 class="feature-title">Elégedettség garancia</h3>
      <p class="feature-desc">
        Ha nem vagy elégedett a termékkel, 30 napon belül visszaküldheted.
      </p>
    </article>

    <article class="feature-card">
      <div class="feature-icon" aria-hidden="true">🚚</div>
      <h3 class="feature-title">Gyors szállítás</h3>
      <p class="feature-desc">
        Rendeléseket 2–3 munkanapon belül házhoz szállítjuk országszerte.
      </p>
    </article>
  </div>
</section>
</template>
<style scoped>

.feature-section{
  background: var(--bg);
  padding: 32px 64px;
}

.feature-grid{
  max-width: 1200px;
  margin: 0 auto;
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 32px;
}

@media (max-width: 800px){
  .feature-grid{ grid-template-columns: 1fr; }
}

.feature-card{
  background: var(--card);
  border-radius: var(--radius);
  box-shadow: var(--shadow);
  min-height: 150px;
  padding: 60px ;
  text-align: center;
  transition: transform .15s ease, box-shadow .15s ease;
}

.feature-card:hover{
  transform: translateY(-2px);
  box-shadow: 0 12px 28px rgba(17, 24, 39, 0.08);
}

.feature-icon{
  width: 56px;
  height: 56px;
  margin: 0 auto 14px;
  border-radius: 14px;
  display: grid;
  place-items: center;
  background: var(--accent-soft);
  color: var(--accent);
  font-size: 26px; /* swap emoji for SVG if desired */
}

.feature-title{
  margin: 6px 0 8px;
  font-size: 20px;
  line-height: 1.2;
  color: var(--text);
  font-weight: 700;
}

.feature-desc{
  margin: 0;
  color: var(--muted);
  font-size: 15px;
  line-height: 1.6;
}
</style>