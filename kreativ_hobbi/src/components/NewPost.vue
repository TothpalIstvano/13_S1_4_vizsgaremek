<template>
<main>
    <h1 class="title">Új poszt hozzáadása</h1>
    <div class="container">
        <form action="/">
            <label for="fname">Poszt címe</label>
            <input type="text" id="fname" name="firstname" placeholder="Your name..">

            <label for="country">Címkék</label>
            <select id="country" name="country">
            <option value="australia">Australia</option>
            <option value="canada">Canada</option>
            <option value="usa">USA</option>
            </select>
            <!-- e helyett meg nyilván ez: https://v3.primevue.org/multiselect/-->

            <!-- nem mükszik
            <MultiSelect v-model="selectedCountries" :options="countries" optionLabel="name" filter placeholder="Select Countries" display="chip" class="w-full md:w-80">
            <template #option="slotProps">
                <div class="flex items-center">
                    <img :alt="slotProps.option.name" src="https://primefaces.org/cdn/primevue/images/flag/flag_placeholder.png" :class="`flag flag-${slotProps.option.code.toLowerCase()} mr-2`" style="width: 18px" />
                    <div>{{ slotProps.option.name }}</div>
                </div>
            </template>
            <template #dropdownicon>
                <i class="pi pi-map" />
            </template>
            <template #filtericon>
                <i class="pi pi-map-marker" />
            </template>
            <template #header>
                <div class="font-medium px-3 py-2">Available Countries</div>
            </template>
            <template #footer>
                <div class="p-3 flex justify-between">
                    <Button label="Add New" severity="secondary" variant="text" size="small" icon="pi pi-plus" />
                    <Button label="Remove All" severity="danger" variant="text" size="small" icon="pi pi-times" />
                </div>
            </template>
        </MultiSelect>-->

            <label for="subject">Subject</label>
            <!-- kéne: https://v3.primevue.org/editor/-->
            <textarea id="subject" name="subject" placeholder="Write something.." style="height:200px"></textarea>

            <input type="submit" value="Submit">
        </form>        
    </div>
</main>
</template>
<script setup>
import { ref } from "vue";
import MultiSelect from 'primevue/multiselect';

const selectedCountries = ref();
const countries = ref([
    { name: 'Australia', code: 'AU' },
    { name: 'Brazil', code: 'BR' },
    { name: 'China', code: 'CN' },
    { name: 'Egypt', code: 'EG' },
    { name: 'France', code: 'FR' },
    { name: 'Germany', code: 'DE' },
    { name: 'India', code: 'IN' },
    { name: 'Japan', code: 'JP' },
    { name: 'Spain', code: 'ES' },
    { name: 'United States', code: 'US' }
]);
</script>
<style scoped>
*, *::before, *::after {
  box-sizing: border-box;
}

main {
  text-align: center;
  margin: 0 auto;
  padding: 0;
}

.title {
  font-weight: 700;
  font-size: 45px;
  color: var(--mk-text-dark);
  display: inline-block;
  background-image: linear-gradient(90deg, #a08283, #4d0303);
  background-repeat: no-repeat;
  background-position: 0 100%;
  background-size: 100% 4px;
  padding-bottom: 6px;
}

.container {
  border-radius: 5px;
  background-color: #f2f2f2;
  padding: 35px;
  text-align: left;
  max-width: 1400px;
  margin: 0 auto;
  /*position: relative;*/
}

input[type=text], select, textarea {
  width: 100%;
  padding: 12px;
  border: 1px solid #ccc;
  border-radius: 4px;
  box-sizing: border-box;
  margin-top: 6px;
  margin-bottom: 16px;
  resize: vertical;
}

input[type=submit] {
  background-color: #04AA6D;
  color: white;
  padding: 12px 20px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
display: block;
  margin-left: auto;
  margin-right: 0;
  /*float: right;*/
}

input[type=submit]:hover {
  background-color: #45a049;
}
</style>