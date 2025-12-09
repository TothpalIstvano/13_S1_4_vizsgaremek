<style scoped>
body {
    font-family: Arial, sans-serif;
    background-color: #f8f9fa;
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 100vh;
    margin: 0;
}
.container {
    text-align: center;
    padding: 2rem;
}
h1 {
    color: #9e3641;
    font-size: 4rem;
    margin-bottom: 1rem;
}
p {
    color: #6c757d;
    font-size: 1.2rem;
    margin-bottom: 2rem;
}
.button {
    padding: 0.75rem 1.5rem;
    background-color: #9c6341;
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 1rem;
    text-decoration: none;
}
.button:hover {
    background-color: #0056b3;
}
</style>

<template>
    <div class="container">
        <h1>404 - Page Not Found</h1>
        <p>The page you're looking for doesn't exist.</p>
        <a href="/" class="button">Go Home</a>
    </div>
</template>
