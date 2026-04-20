<template>
    <div class="page-wrapper">
        <div class="noise-overlay"></div>

        <div class="card" :class="{ 'card--visible': mounted }">
            <div class="card__accent"></div>

            <div class="status-badge">
                <span class="status-badge__dot"></span>
                Már megerősítve
            </div>

            <div class="icon-wrap">
                <svg class="check-svg" viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <circle class="check-circle" cx="32" cy="32" r="30" stroke="#e8c87a" stroke-width="2.5" />
                    <path class="check-mark" d="M18 33 L27 42 L46 23" stroke="#e8c87a" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" />
                </svg>
            </div>

            <h1 class="title">
                <span class="title__line">Email cím</span>
                <span class="title__line title__line--accent">már megerősítve</span>
            </h1>

            <p class="body-text">
                Ez az email cím korábban már aktiválásra került. Nem szükséges ismételt megerősítés.
            </p>

            <div class="divider">
                <span></span><span class="divider__diamond">◆</span><span></span>
            </div>

            <router-link to="/profil" class="cta-btn">
                <span>Bejelentkezés</span>
                <svg class="cta-btn__arrow" viewBox="0 0 20 20" fill="none">
                    <path d="M4 10h12M12 6l4 4-4 4" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
            </router-link>

            <p class="hint">Vagy <router-link to="/" class="hint__link">vissza a főoldalra</router-link></p>
        </div>
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const mounted = ref(false)

onMounted(() => {
    requestAnimationFrame(() => {
        mounted.value = true
    })
})
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,400;0,600;1,400&family=DM+Sans:wght@300;400;500&display=swap');

:root {
    --gold: #e8c87a;
    --gold-dim: #c9a84c;
    --ink: #1a1611;
    --parchment: #faf6ee;
    --parchment-mid: #f2ead8;
    --text-main: #2d2517;
    --text-sub: #7a6b52;
}

.page-wrapper {
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    background-image:
        radial-gradient(ellipse 80% 60% at 30% 20%, rgba(232, 200, 122, 0.18) 0%, transparent 60%),
        radial-gradient(ellipse 60% 50% at 75% 80%, rgba(201, 168, 76, 0.12) 0%, transparent 55%);
    font-family: 'DM Sans', sans-serif;
    position: relative;
    padding: 24px;
}

.noise-overlay {
    position: fixed;
    inset: 0;
    background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.75' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)' opacity='0.04'/%3E%3C/svg%3E");
    pointer-events: none;
    opacity: 0.6;
}

.card {
    position: relative;
    background: #ffffff75;
    border: 1px solid rgba(232, 200, 122, 0.4);
    border-radius: 4px;
    padding: 56px 52px 48px;
    width: 100%;
    max-width: 460px;
    text-align: center;
    box-shadow:
        0 2px 4px rgba(26, 22, 17, 0.04),
        0 8px 24px rgba(26, 22, 17, 0.08),
        0 32px 64px rgba(26, 22, 17, 0.06);
    overflow: hidden;

    opacity: 0;
    transform: translateY(20px);
    transition: opacity 0.6s ease, transform 0.6s ease;
}

.card--visible {
    opacity: 1;
    transform: translateY(0);
}

.card__accent {
    position: absolute;
    top: 0;
    left: 10%;
    right: 10%;
    height: 2px;
    background: linear-gradient(90deg, transparent, var(--gold), transparent);
}

.status-badge {
    display: inline-flex;
    align-items: center;
    gap: 7px;
    font-size: 11px;
    font-weight: 500;
    letter-spacing: 0.12em;
    text-transform: uppercase;
    color: var(--gold-dim);
    border: 1px solid rgba(232, 200, 122, 0.35);
    border-radius: 2px;
    padding: 5px 12px;
    margin-bottom: 36px;
    background: rgba(232, 200, 122, 0.07);
}

.status-badge__dot {
    width: 6px;
    height: 6px;
    border-radius: 50%;
    background: var(--gold);
    animation: pulse 2.4s ease infinite;
}

@keyframes pulse {
    0%, 100% { opacity: 1; transform: scale(1); }
    50% { opacity: 0.5; transform: scale(0.75); }
}

.icon-wrap {
    margin-bottom: 28px;
}

.check-svg {
    width: 64px;
    height: 64px;
}

.check-circle {
    stroke-dasharray: 188;
    stroke-dashoffset: 188;
    animation: draw-circle 0.9s cubic-bezier(0.4, 0, 0.2, 1) 0.3s forwards;
}

.check-mark {
    stroke-dasharray: 40;
    stroke-dashoffset: 40;
    animation: draw-check 0.5s cubic-bezier(0.4, 0, 0.2, 1) 1s forwards;
}

@keyframes draw-circle {
    to { stroke-dashoffset: 0; }
}
@keyframes draw-check {
    to { stroke-dashoffset: 0; }
}

.title {
    font-family: 'Cormorant Garamond', serif;
    font-size: 2rem;
    font-weight: 600;
    line-height: 1.15;
    color: var(--text-main);
    margin: 0 0 18px;
    display: flex;
    flex-direction: column;
    gap: 2px;
}

.title__line--accent {
    font-style: italic;
    color: var(--gold-dim);
}

.body-text {
    font-size: 14.5px;
    line-height: 1.7;
    color: var(--text-sub);
    margin: 0;
    font-weight: 300;
}

.divider {
    display: flex;
    align-items: center;
    gap: 12px;
    margin: 32px 0;
}

.divider span:first-child,
.divider span:last-child {
    flex: 1;
    height: 1px;
    background: linear-gradient(90deg, transparent, rgba(232, 200, 122, 0.35));
}

.divider span:last-child {
    background: linear-gradient(90deg, rgba(232, 200, 122, 0.35), transparent);
}

.divider__diamond {
    flex: none;
    font-size: 8px;
    color: var(--gold-dim);
    opacity: 0.6;
}

.cta-btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 10px;
    width: 100%;
    padding: 14px 24px;
    background: var(--ink);
    color: var(--gold);
    font-family: 'DM Sans', sans-serif;
    font-size: 13.5px;
    font-weight: 500;
    letter-spacing: 0.06em;
    text-decoration: none;
    border-radius: 3px;
    border: 1px solid rgba(232, 200, 122, 0.2);
    transition: background 0.25s ease, color 0.25s ease, box-shadow 0.25s ease;
    margin-bottom: 16px;
}

.cta-btn:hover {
    background: #f3e5ce;
    box-shadow: 0 4px 20px rgba(26, 22, 17, 0.25);
}

.cta-btn__arrow {
    width: 18px;
    height: 18px;
    transition: transform 0.2s ease;
}

.cta-btn:hover .cta-btn__arrow {
    transform: translateX(3px);
}

.hint {
    font-size: 13px;
    color: var(--text-sub);
    margin: 0;
}

.hint__link {
    color: var(--gold-dim);
    text-decoration: none;
    border-bottom: 1px solid transparent;
    transition: border-color 0.2s ease;
}

.hint__link:hover {
    border-color: var(--gold-dim);
}

@media (max-width: 520px) {
    .card {
        padding: 40px 28px 36px;
    }
    .title {
        font-size: 1.7rem;
    }
}
</style>