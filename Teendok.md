* \[x] Navbar alapok
* \[x] Navbar
* \[x] Regsiztráció / Belépés
* \[x] Profil
* \[x] Nav animációk
* \[x] Carousel
* \[x] Képek
* \[x] Szövegek
* \[x] Blog kártyák
* \[x] Footer
* \[x] Jelszó(regisztráció)
* \[x] Jelszó(megtekintés)

* \[/] Webshop
* \[ ] cimke szűrés + ha itemen katintás akkkor hozzá adás
* \[X] active cimkek
* \[ ] active termékeknél cimkek
* \[ ] active cimkek megtartása sessionstorage
* \[/] active cimkek stilus
* \[ ] termek cimkek termékeken katinthatók legyenek
* \[X] cimke kategoriára való csere
* \[ ] szöveg röviditése ha overflow van és ... hozááadása
* \[ ] cimkeék az itemen való mennyiség kiírás + + jel oda írása + enyitható legyen
* \[ ] kosár mennyiség írása
* \[ ] Carouselbe itemek berakása kedvenc alapján
* \[ ] email verifikáció
* \[ ] vásárol email
* \[ ] jelszó reset
* \[ ] kosár eltárolása
* \[ ] rendelés pending
* \[ ] Dashboard betöltése + valós input"" from database
* \[ ] áruház loading
* \[ ] Rendelések javtása
* \[ ] Analitika fixelés
* \[ ] Sorba rendezés admin felületen
* \[ ] Admin oldalak alsó oldalakra bontása a számos cucc
* \[ ] Admin oldal blogok javítása
* \[ ] Admin oldal kategoria megoszlás csere to fokategoriak és az alá tartozok szám

* \[ ] Dashboard szerző + modosítás javítás +/- jobb stilus
* \[ ] kicsit akad az animáció a belépés oldalon a váltásnál 
* \[X] resend ki cserélésre gmailre
* \[X] verifikáld az emailed felszólitás

* \[ ] Táblák egységesítése ez alat azt értve hogy a táblákban lévő adatok megegyezenek 
* \[ ] különböző roleok hozzá adása
* \[ ] Admin site
* \[ ] Posztok és további backend helyekből kivenni a létrehozás dátuma nevű felesleges taget, mivel a created_at egyszerűbb és alap 
* \[ ] Elfeljtette a jelszót + email 
* \[ ] Térkép javítása

* \[ ] Az oldal kódjának tisztázás
* \[ ] Az oldal tesztelése
* \[ ] Az oldal dokumenálása
* \[ ] Optimalizálás
* \[ ] Mintakészitő✅, regisztráció✅, regisztráció rossz adattal✅, bejelentekezés✅, bejelentekezés rossz adattal✅, jelszó reset(egy része done), új felhasználó admin siteon, új item admin siteon, rendelés, bankkártya, poszthozáadása profilról + modósítás, profil modositás

ha megakarjuk oldani azt hogy bejelentkezve maradok

2. Vagy hozzáadni a táblához migráccióval:
bashphp artisan make:migration add_remember_token_to_felhasznalok_table
phppublic function up(): void
{
    Schema::table('felhasznalok', function (Blueprint $table) {
        $table->rememberToken();
    });
}
bashphp artisan migrate

ja és a NewPasswordController törlöd ki a // hogy müköjön->néz utána 


lehet old meg

router.js-ben az admin route-hoz nem kell változtatni, de a Dashboard komponensben:
jsimport { useRouter, useRoute } from 'vue-router';

const router = useRouter();
const route = useRoute();

// currentView inicializálása URL-ből
const currentView = ref(route.query.view ?? 'dashboard');
const currentPage = ref(Number(route.query.page) ?? 1);
const currentProductPage = ref(Number(route.query.page) ?? 1);
const currentBlogPage = ref(Number(route.query.page) ?? 1);
A currentView watch-hoz add hozzá az URL frissítést:
jswatch(currentView, (newView) => {
  if (oldView === 'dashboard') destroyDashboardCharts();
  if (oldView === 'analytics') destroyAnalyticsCharts();
  
  // URL frissítése
  router.replace({ query: { view: newView, page: 1 } });
  
  // Oldal reset nézet váltáskor
  currentPage.value = 1;
  currentProductPage.value = 1;
  currentBlogPage.value = 1;
  
  initCharts();
});
Az oldalszám változásakor is frissítsd az URL-t — add hozzá mindhárom paginált nézethez:
jswatch(currentPage, (val) => {
  router.replace({ query: { view: currentView.value, page: val } });
});

watch(currentProductPage, (val) => {
  router.replace({ query: { view: currentView.value, page: val } });
});

watch(currentBlogPage, (val) => {
  router.replace({ query: { view: currentView.value, page: val } });
});
Az onMounted-ban olvasd vissza az URL-t:
jsonMounted(async () => {
  // URL-ből visszaállítás
  if (route.query.view) currentView.value = route.query.view;
  if (route.query.page) {
    const page = Number(route.query.page);
    currentPage.value = page;
    currentProductPage.value = page;
    currentBlogPage.value = page;
  }

  const { data } = await axios.get('/api/user');
  currentUserId.value = data.id;

  await Promise.all([
    fetchStats(), 
    fetchOrders(), 
    fetchAnalytics(), 
    fetchProducts(),
    fetchUsers(),
    fetchBlogPosts(),
    fetchTagsFromDatabase()
  ]);
  initCharts();
});
Így például http://localhost:5173/dashboard?view=products&page=3 — F5 után pontosan ugyanoda tölt vissza.