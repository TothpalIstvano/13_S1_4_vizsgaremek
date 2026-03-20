

* \[/] Webshop
* \[ ] kosár jel hozzáadása a kis méretű módhoz vhogy ez alatt azt étve hogy mikor nem fullos a navbar
* \[ ] vásárlási mezők verfikációjának javítása
* \[ ] kártya adatverifikáció
* \[ ] telefon szám jobbá tétele
* \[ ] Analitika fixelés és kisebbre vétele
* \[ ] Rendelések tagolása
* \[ ] Hero banner
* \[ ] verifikációs emailra való várás
- \[ ] Alertek lecserélése mindenhol modellekre
* \[ ] Táblák egységesítése ez alat azt értve hogy a táblákban lévő adatok megegyezenek 
* \[ ] Posztok és további backend helyekből kivenni a letrehozas_datuma nevű felesleges taget, mivel a created_at egyszerűbb és alap 
* \[ ] Térkép javítása
* \[ ] Az oldal kódjának tisztázás
* \[ ] Az oldal tesztelése
* \[ ] Az oldal dokumenálása
* \[ ] Optimalizálás


* \[X] Admin oldal kategoria megoszlás csere to fokategoriak és az alá tartozok szám✅
* \[X] szét szedni a szálitási címet kisebb részekre✅
* \[X] kártya adatok mentése✅
* \[X] rendelés adatoki szét szedése és a rendelés táblába vagy szédeni külön ugyan úgy vagy összefüzni✅
* \[X] Dashboard szerző + modosítás javítás +/- jobb stilus✅
* \[X] rendelés pending✅
* \[X] active cimkek✅
* \[X] active termékeknél cimkek✅
* \[X] active cimkek megtartása sessionstorage✅
* \[X] active cimkek stilus✅
* \[X] termekképek több galeria✅
* \[X] cimke kategoriára való csere✅
* \[X] szöveg röviditése ha overflow van és ... hozááadása✅
* \[X] cimkeék az itemen való mennyiség kiírás + + jel oda írása + enyitható legyen✅
* \[X] kosár mennyiség írása✅
* \[X] Carouselbe itemek berakása kedvenc alapján ->IMPLEMENTÁCIÓRA VÁRÓ NEM LEHETSÉGES FEATURE✅
* \[X] email verifikáció✅
* \[X] vásárol email✅
* \[X] vissza api/user végpont által vissza adott adatok limitálása a csak kellökre és több helyen is van használva✅
* \[X] jelszó reset✅
* \[X] kosár eltárolása✅
* \[X] Dashboard betöltése + valós input"" from database✅
* \[X] áruház loading✅
* \[X] Rendelések javtása✅
* \[x] Navbar alapok✅
* \[x] Navbar✅
* \[x] Regsiztráció / Belépés✅
* \[x] Profil✅
* \[x] Nav animációk✅
* \[x] Carousel✅
* \[x] Képek✅
* \[x] Szövegek✅
* \[x] Blog kártyák✅
* \[x] Footer✅
* \[x] Jelszó(regisztráció)✅
* \[x] Jelszó(megtekintés)✅
* \[X] Sorba rendezés admin felületen✅
* \[X] Admin oldalak alsó oldalakra bontása a számos cucc✅
* \[X] Admin oldal blogok javítása✅
* \[X] kicsit akad az animáció a belépés oldalon a váltásnál✅
* \[X] resend ki cserélésre gmailre✅
* \[X] verifikáld az emailed felszólitás✅
* \[X] különböző roleok hozzá adása✅
* \[X] Admin site✅
* \[X] Elfeljtette a jelszót + email✅
* \[X] Tesztek:
  - Mintakészitő✅
  - regisztráció✅
  - regisztráció rossz adattal✅
  - bejelentekezés✅
  - bejelentekezés rossz adattal✅
  - jelszó reset (egy része done)✅
  - új felhasználó admin siteon✅
  - új item admin siteon✅
  - rendelés✅
  - bankkártya✅
  - poszthozáadása profilról + modósítás✅
  - profil modositás✅
- \[X] kosár eltárolása✅
- \[X] áruház alsó oldalak számok átírni (12, 24, 48)✅
- \[X] rendelés pending✅



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
