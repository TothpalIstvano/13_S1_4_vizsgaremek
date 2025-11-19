<template>

</template>
<script>
import axios from 'axios';

// CSRF-cookie lekérése (Sanctum használatához)
await axios.get('/sanctum/csrf-cookie');
// Bejelentkezés
await axios.post('/login', { email: 'teszt@user.hu', password: 'titkos' });
// Auth utáni védekezett erőforrás elérése (pl. a bejelentkezett felhasználó adatai)
const response = await axios.get('/api/user');
console.log(response.data);

</script>