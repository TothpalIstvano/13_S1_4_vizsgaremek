<template>
    <div class="email-verified">
        <h1>Email sikeresen megerősítve!</h1>
        <p>Köszönjük, hogy megerősítette email címét. Most már teljes hozzáférése van a fiókjához.</p>
        <router-link to="/belepes" class="btn btn-primary">Bejelentkezés</router-link>
    </div>
</template>
<script setup>

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
.email-verified h1 {
    color: #28a745;
    margin-bottom: 20px;
}
.email-verified p {
    font-size: 18px;
    margin-bottom: 30px;
}
.email-verified .btn {
    padding: 10px 20px;
    font-size: 16px;
    text-decoration: none;
    color: #fff;
    background-color: #28a745;
    border: none;
    border-radius: 5px;
    transition: background-color 0.3s;
}
.email-verified .btn:hover {
    background-color: #1e7432;
}
</style>