<template>
    <div class="email-verified">
        <div class="icon">✅</div>
        <h1>Email sikeresen megerősítve!</h1>
        <p>Köszönjük, hogy megerősítette email címét.</p>
        <p class="sub">Ez az ablak automatikusan bezárul...</p>
    </div>
</template>

<script setup>
import { onMounted } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()

onMounted(() => {
    // Ha a régi tab még nyitva van, szóljunk neki
    if (window.opener && !window.opener.closed) {
        window.opener.postMessage(
            { type: 'EMAIL_VERIFIED' },
            import.meta.env.VITE_APP_URL || 'http://localhost:5173'
        )
        // Rövid delay, hogy a message biztosan megérkezzen
        setTimeout(() => window.close(), 1000)
    } else {
        // Ha nincs régi tab, maradjunk itt
        setTimeout(() => router.push('/belepes'), 2500)
    }
})
</script>

<style scoped>
.email-verified {
    text-align: center;
    margin: 8% auto;
    border: rgb(248, 230, 194) solid 1px;
    padding: 30px;
    border-radius: 10px;
    width: 40%;
    box-shadow: 0 10px 8px rgba(0, 0, 0, 0.1);
    background-color: rgb(255, 251, 243);
}
.icon {
    font-size: 48px;
    margin-bottom: 16px;
}
.email-verified h1 {
    color: #28a745;
    margin-bottom: 20px;
}
.email-verified p {
    font-size: 18px;
    margin-bottom: 10px;
}
.sub {
    font-size: 14px !important;
    color: #888;
}
</style>