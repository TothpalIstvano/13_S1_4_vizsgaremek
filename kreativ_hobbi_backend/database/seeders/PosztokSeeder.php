<?php

namespace Database\Seeders;

use App\Models\Posztok;
use Illuminate\Database\Seeder;

class PosztokSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $yourPosts = [
            [
                'cim' => 'Horgolás kezdőknek',
                'kivonat' => 'Fedezd fel a fonalak világát az alábbi útmutatónk segítségével - tudj meg minden információt a horgolás tanulásának elkezdéséhez.',
                'tartalom' => '<h2>Horgolás kezdőknek: Fedezd fel a fonalak világát!</h2>
                <p>A horgolás az egyik legmegnyugtatóbb és legkreatívabb hobbi, amellyel gyönyörű, hasznos tárgyakat készíthetsz a saját kezeddel. Akár egy puha sálat, akár egy színes takarót vagy akár játékokat szeretnél alkotni, a horgolás végtelen lehetőségeket rejt. Sokan azt hiszik, hogy nehéz megtanulni, de valójában néhány alapöltés elsajátításával máris elindulhatsz a fonalas kalandok útján.</p>
                <h3>Milyen eszközökre lesz szükséged?</h3>
                <p>Kezdőként a legjobb, ha vastagabb fonalat és hozzá illő, nagyobb méretű horgolótűt választasz. A 4-es vagy 5-ös méretű alumínium vagy bambusz tűk kellemesen csúsznak a kézben, és a szemek is jól láthatóak lesznek rajta. A fonal legyen világos színű (pl. sárga vagy pasztell), mert azon jobban kivehetők a szemek, mint a sötéteken. Ne feledkezz meg egy éles ollóról és egy tompa végű gobelintűről sem, amellyel a fonalvégeket eldolgozhatod a munka végén.</p>
                <h3>Az első öltések</h3>
                <p>Minden horgolás alapja a kezdő hurok és a láncszem. Gyakorold ezt először: készíts egy hurkot a tűre, majd a fonalat áthúzva hozz létre egy laza láncszemsort. Ha ez már megy, jöhet az egyráhajtásos pálca, ami a leggyakoribb öltés. Ehhez ráhajtasz a tűre, beleszúrsz a láncszembe, felhúzod a fonalat, majd kétszer egymás után áthúzod a tűn lévő hurkokon. Ezt az öltést használva készítheted el az első "granny square" négyzetedet is.</p>
                <div><p><strong>☑️ Gyakorló projekt:</strong> Horgolj egy 20x20 cm-es négyzetet! Használd ezt később alátétként, vagy varrj össze több ilyen négyzetet egy színes takaróvá. A négyzetek remek módjai az új öltések kipróbálásának.</p></div>
                <p>A horgolás szépsége, hogy bárhol, bármikor előveheted – egy buszúton, tévézés közben vagy egy csésze tea mellett is. Adj időt magadnak, és ne aggódj, ha az első sorok nem tökéletesek. A gyakorlás hamar meghozza a rutint!</p>',
                'szerzo_id' => 1,
                'fo_kep_id' => 2,
                'letrehozas_datuma' => now(),
                'statusz' => 'közzétett'
            ],
            [
                'cim' => 'Alapszemek a kötéshez',
                'kivonat' => 'Ismerd meg a leghasznosabb dolgot ami a kötés elsajátításhoz szükséges - a sima és a fordított szemet. Ha ezt megtanulod, minden kötési minta piskóta lesz.',
                'tartalom' => '<h2>Kötés: A sima és fordított szemek varázsa</h2>
                <p>A kötés egy időtlen mesterség, amely generációk óta öröklődik a családokban. Ma már nemcsak a nagymamák hobbija, hanem egyre több fiatal is felfedezi a két tű és egy gombolyag terápiás hatását. A kötés közbeni ritmikus mozdulatok lelassítják a gondolatokat, és egyfajta meditatív állapotba kerülhetsz – miközben egyedi ruhadarabokat varázsolsz elő a semmiből.</p>
                <h3>Kezdő felszerelés</h3>
                <p>Induláshoz elegendő egy pár egyenes kötőtű (5-6 mm-es) és egy közepesen vastag, világos színű fonal. A fonal anyaga lehet akril, pamut vagy gyapjúkeverék – a lényeg, hogy ne legyen túl vékony, mert azt nehezebb kezelni. Később szükséged lehet még mérőszalagra, szemjelölőkre és egy tompa tűre a végek eldolgozásához.</p>
                <h3>Alapok: sima és fordított</h3>
                <p>Két alapvető szemléletmód létezik: a sima és a fordított. A sima szem a kötés "jobb oldala", a fordított pedig a bal. Ha minden sort simán kötsz, akkor lustakötést kapsz, ami egy rugalmas, hullámos felület. Ha váltogatod a sima és fordított sorokat, akkor harisnyakötés jön létre – az egyik oldal sima, a másik bordázott. Ha egy soron belül váltogatod a két szemet (pl. 2 sima, 2 fordított), akkor patentmintát kapsz, ami a pulóverek alján és a sálak szélén is remekül mutat.</p>
                <p>Kezdésnek tanuld meg a szemek felszedését – ez az egyik legnehezebb lépés, de rengeteg videó segít az interneten. Ne csüggedj, ha elsőre nem sikerül, próbáld újra!</p><div"><p><strong>☑️ Javaslat:</strong> Az első komolyabb projekted lehet egy egyszerű sál lustakötéssel. Válassz egy szép színű, vastag fonalat, és köss addig, amíg el nem éred a kívánt hosszt. A végén eldolgozod a szálakat, és már viselheted is a saját készítésű sáladat!</p></div>',
                'szerzo_id' => 1,
                'fo_kep_id' => 5,
                'letrehozas_datuma' => now()->subDays(3),
                'statusz' => 'közzétett'
            ],
            [
                'cim' => 'Március, napsütés - irány a kert',
                'kivonat' => '',
                'tartalom' => '<h2>Kertészkedés: Így neveld a növényeidet tavasztól őszig</h2>
                <p>A kertészkedés nemcsak a ház körüli munkáról szól, hanem a természet közelségéről és a megújulás öröméről. Akár egy nagy kerted van, akár csak egy erkélyed vagy ablakpárkányod, a növények gondozása feltölt és összekapcsol az évszakok körforgásával. A tavasz a legalkalmasabb időszak arra, hogy belekezdj: ilyenkor ébrednek a növények, és kezdenek újra növekedésbe.</p>
                <h3>Tavaszi teendők a balkonon</h3>
                <p>Ha van néhány cserepes növényed, érdemes tavasszal átültetni őket. Nézd meg, hogy a gyökerek nem nőttek-e ki a cserép alján – ha igen, válassz egy mérettel nagyobb edényt. Friss virágföldbe ültesd át, és óvatosan nyomkodd meg a földet a gyökerek körül. Az öntözést is fokozatosan növeld, ahogy melegszik az idő, de mindig kerüld a túlöntözést – a pangó víz gyökérrothadáshoz vezethet.</p>
                <h3>Növényajánló kezdőknek</h3>
                <p>Ha most ismerkedsz a kertészkedéssel, válassz olyan növényeket, amelyek "nehezen ölhetők meg":</p>
                <ul>
                <li><strong>Muskátli:</strong> Napos helyen bőségesen virágzik egész nyáron.</li>
                <li><strong>Levendula:</strong> Illatos, szárazságtűrő, és a méheket is vonzza.</li>
                <li><strong>Pozsgások (pl. kaktuszok, varjúháj):</strong> Szinte elfelejtheted őket öntözni, mégis díszlenek.</li>
                <li><strong>Fűszernövények:</strong> Bazsalikom, petrezselyem, snidling – a konyhában is hasznosak.</li>
                </ul>
                <div><p><strong>☑️ Ötlet:</strong> Készíts egy mini fűszernövénykertet egy hosszúkás balkonládába! Tedd ki a konyhaablakba, és szükség szerint csipkedd le a friss zöldeket a főzéshez. A bazsalikom, menta és rozmaring együtt is elfér, és csodás illatot árasztanak.</p></div>
                <p>Ne feledd: a kertészkedés türelemjáték. A növények nem nőnek egyik napról a másikra, de a gondoskodás meghozza gyümölcsét – szó szerint is, ha mondjuk epret vagy koktélparadicsomot ültetsz.</p>',
                'szerzo_id' => 1,
                'fo_kep_id' => 8,
                'letrehozas_datuma' => now()->subDays(5),
                'statusz' => 'közzétett'
            ],
            [
                'cim' => 'Egyszerű falipolc otthonra',
                'kivonat' => 'Szeretnél barkácsolni valamit de nincs fészered szerszámokkal megtömve? Ezt az egyszerű falipolc készítő útmutatót pont neked hoztuk!',
                'tartalom' => '<h2>Barkácsolás: Készíts egyszerű falipolcot magadnak!</h2>
                <p>A barkácsolás nem igényel feltétlenül profi műhelyt vagy drága szerszámokat. Egy kis leleményességgel és néhány alapvető eszközzel te is megalkothatod a saját bútorodat, vagy megjavíthatsz valamit a lakásban. Az alábbi útmutatóval egy egyszerű, mégis mutatós falipolcot készíthetsz, amely tökéletes könyvek, dísztárgyak vagy növények számára.</p>
                <h3>Amire szükséged lesz:</h3>
                <ul>
                <li>Egy előre vágott fadeszka (pl. fenyő vagy rétegelt lemez), kb. 60-80 cm hosszú és 20 cm széles</li>
                <li>Két darab háromszögletű polctartó konzol (fém vagy fa)</li>
                <li>Csavarok és tiplik (a fal anyagától függően)</li>
                <li>Fúrógép csavarhúzó fejjel</li>
                <li>Vízszintező</li>
                <li>Csiszolópapír, ecset, festék vagy lakk (opcionális)</li>
                </ul>
                <h3>A munka menete</h3>
                <p>Először is csiszold le a deszka felületét, hogy sima legyen, és ne okozzon szilánkot. Ha szeretnéd, le is festheted vagy lakkozhatod a fát – ehhez érdemes először alapozót használni, majd két rétegben felvinni a színt. Hagyd teljesen megszáradni.</p>
                <p>Következő lépés a konzolok felcsavarozása a polc aljára. Ügyelj arra, hogy a konzolok egymástól egyenlő távolságra legyenek, és a polc széleitől is hagyj 5-10 cm-t. Használd a vízszintezőt, hogy a konzolok párhuzamosak legyenek egymással.</p>
                <p>Most jön a legizgalmasabb rész: a falra szerelés. Tartsd a polcot a falhoz a kívánt magasságban, és vízszintezővel ellenőrizd. Jelöld meg ceruzával a furatok helyét a falon a konzolok lyukain keresztül. Fúrd ki a lyukakat a falba (ehhez használj fúrót, ami a fal anyagához illik – téglafalhoz ütvefúró, gipszkartonhoz sima fúró). Helyezd be a tipliket, majd csavard fel a konzolokat a falra. Végül helyezd rá a polcot a konzolokra, és ha szükséges, rögzítsd felülről is egy-egy apró csavarral.</p>
                <div><p><strong>☑️ Tipp:</strong> Mielőtt a falba fúrsz, ellenőrizd, hogy nem vezet-e a falban elektromos kábel vagy vízcső (használj kábelkeresőt)! Kezdésnek válassz egy kevésbé látványos helyet, például a kamrában vagy a műhelyben, hogy magabiztosan gyakorolj.</p></div>',
                'szerzo_id' => 1,
                'fo_kep_id' => 6,
                'letrehozas_datuma' => now(),
                'statusz' => 'közzétett'
            ],
            [
                'cim' => 'A legrágibb díszítő eljárás: a hímzés',
                'kivonat' => 'Ha rutinos vagy varrásban, akkor ez a kreatív elfoglaltság is biztos tetszeni fog; ha pedig nem, itt az idő hogy megismerkedj a szövetdíszítés titkaival.',
                'tartalom' => '<h2>Hímzés: Szálakból szőtt történetek</h2>
                <p>A hímzés az egyik legősibb textilművesség, amely lehetővé teszi, hogy egy egyszerű anyagdarabot művészi alkotássá varázsolj. Akár egy régi párnát szeretnél feldobni, akár egy egyedi ajándékot készítenél, a hímzés személyes és időtálló. Ráadásul nagyon kevés eszközzel elkezdhető, és bárhol űzhető.</p>
                <h3>Alapfelszerelés</h3>
                <ul>
                <li><strong>Hímzőtű:</strong> tompa végű, nagy lyukkal, hogy a fonal könnyen átférjen.</li>
                <li><strong>Hímzőfonal:</strong> klasszikus a hat szálból álló fonal, amit tetszés szerint szétszedhetsz.</li>
                <li><strong>Hímzőkeret:</strong> fából vagy műanyagból, amely feszesen tartja az anyagot és segít, hogy a minta ne torzuljon.</li>
                <li><strong>Alapanyag:</strong> vászon, pamut vagy lenvászon a legjobb kezdőknek.</li>
                <li><strong>Minta:</strong> kezdetben akár egy egyszerű vonalrajz is lehet.</li>
                </ul>
                <h3>Néhány alapöltés</h3>
                <p>Az előöltés a legegyszerűbb: csak szúrd ki a tűt, majd húzd vissza kis távolságra – olyan, mint a varrógép varrása. A száröltéssel vonalakat, szárakat, körvonalakat hímezel: a tűt mindig az előző öltés felénél szúrd vissza. A francia csomó egy apró, gömbölyű díszítés: tekerd a fonalat kétszer a tű köré, majd a textilbe szúrva húzd át – így keletkezik a kis csomó.</p>
                <p>A hímzésben nincsenek szigorú szabályok – nyugodtan kombináld az öltéseket, és alkoss szabadon. A legszebb darabok gyakran a "hibákból" születnek.</p>
                <div><p><strong>☑️ Első projekt:</strong> Vegyél egy egyszerű, egyszínű párnahuzatot, és hímezz rá egy nagy kezdőbetűt vagy egy apró virágot. Ez egy személyre szabott ajándék is lehet, és egy este alatt elkészül.</p></div>',
                'szerzo_id' => 1,
                'fo_kep_id' => 7,
                'letrehozas_datuma' => now(),
                'statusz' => 'közzétett'
            ],
            [
                'cim' => 'Ékszerkészítés egyszerűen - a gyöngyfűzés',
                'kivonat' => '',
                'tartalom' => '<h2>Gyöngyfűzés: Készíts saját ékszereket!</h2><p>A gyöngyfűzés egy rendkívül változatos és kreatív hobbi, amellyel egyedi ékszereket, kiegészítőket készíthetsz magadnak vagy ajándékba. Csak néhány alapvető eszközre van szükséged, és máris belevághatsz a színes gyöngyök világába. Akár egyszerű karkötőt, akár bonyolultabb nyakláncot szeretnél, a gyöngyfűzés végtelen mintázási lehetőséget kínál.</p>
                <h3>Milyen eszközökre lesz szükséged?</h3>
                <ul>
                <li><strong>Gyöngyök:</strong> Kezdésnek válassz nagyobb méretű (6-8 mm-es) műanyag vagy fa gyöngyöket, mert ezeket könnyebb felfűzni. Később jöhetnek az apróbb üveggyöngyök.</li>
                <li><strong>Fonal vagy zsinór:</strong> Használhatsz rugalmas damilt (karkötőkhöz), viaszolt pamutzsinórt, vagy ékszerzsinórt.</li>
                <li><strong>Tű:</strong> Ha vékony fonallal dolgozol, érdemes speciális gyöngyfűző tűt beszerezned.</li>
                <li><strong>Záróelemek:</strong> Kapocs, karabiner, gyűrűk a lezáráshoz (ha nem rugalmas a fonal).</li>
                <li><strong>Olló és fogó:</strong> A záróelemek rögzítéséhez.</li>
                </ul>
                <h3>Alapvető technikák</h3>
                <p>A legegyszerűbb technika az egyszerű fűzés: felfűzöd a gyöngyöket a zsinórra, majd mindkét végére csomót kötsz. Ha rugalmas damilt használsz, egyetlen csomó is elég, de érdemes dupla vagy háromszoros csomót kötni, és egy csepp ragasztót tenni rá a biztonság kedvéért.</p>
                <p>Következő lépés lehet a csomók közötti fűzés, ahol két gyöngy között csomót készítesz – így a gyöngyök nem csúszkálnak össze. Ehhez használj vékonyabb, de erős fonalat. A csomózásos technikával karkötőket, nyakláncokat készíthetsz, ahol a csomók díszítőelemként is szolgálnak.</p>
                <p>Ha szeretnéd kipróbálni a mintás fűzést, keress egyszerű gyöngymintákat (például virág vagy geometrikus formák), ahol több sorban, tű segítségével dolgozol.</p>
                <div><p><strong>☑️ Egyszerű projekt:</strong> Készíts egy rugalmas karkötőt! Válassz ki 5-6 féle színes gyöngyöt, fűzd fel tetszőleges sorrendben egy rugalmas damilra, majd kösd össze a végeket. Pár perc alatt elkészül, és remek kiegészítője lehet a mindennapi viseletednek.</p></div>
                <p>A gyöngyfűzés nemcsak szórakoztató, de fejleszti a finommotorikát és a kreativitást is. Ráadásul egyedi ékszereket készíthetsz, amelyeket senki más nem fog viselni. Próbáld ki, és hamar rákapsz az ízére!</p>',
                'szerzo_id' => 1,
                'fo_kep_id' => 9,
                'letrehozas_datuma' => now(),
                'statusz' => 'közzétett'
            ],
            [
                'cim' => 'Téli hónapok a kertben',
                'kivonat' => 'Fel szeretnéd készíteni a kertedet a hideg időre? Posztunkban minden hasznos információt megtalálsz.',
                'tartalom' => 'h2>Kertészkedés: Őszi teendők – Készítsd fel kerted a télre!</h2>
                <p>A nyár végét és az ősz beköszöntét sok kertész szomorúan éli meg, pedig ez az időszak legalább annyira fontos és szép, mint a tavasz. Ilyenkor a természet lassan visszavonul, a fák levelei színesednek, és a kert készülődik a téli pihenőre. Ha szeretnéd, hogy jövőre is egészséges növények fogadjanak, érdemes néhány óvintézkedést megtenned most, ősszel. Ráadásul ez az időszak a tervezésről és az előkészítésről szól – és még ilyenkor is bőven van tennivaló a kertben.</p>
                <h3>Levéltakarítás – de ne dobd ki!</h3>
                <p>Az őszi levélhullás természetes része a ciklusnak, de a vastag levéltakaró károsíthatja a gyepet, és a pázsit alatt párás, penészes környezet alakulhat ki. A lehullott leveleket érdemes összegyűjteni, de ne tekintsd hulladéknak! A levelekből kiváló komposzt készülhet, ha rétegezed őket más zöld hulladékkal. A felaprított levelekkel takarhatod az érzékenyebb növények tövét is – ez természetes fagyvédelmet nyújt, és a talajéletet is táplálja.</p>
                <h3>Évelők visszavágása és átültetése</h3>
                <p>Az évelő növények nagy részét ősszel visszavághatod, hogy tavasszal erőteljesebben induljanak. A medvehagyma, a liliomok és pünkösdirózsa levelei már sárgulnak, ezeket vágd vissza a föld közelébe. Ne feledkezz meg a fűfélékről sem: a díszfüveket kora tavasszal érdemes visszavágni, mert a téli fagyok károsíthatják a friss vágási felületet, de ha szereted a struktúrát, hagyd meg őket télre is, mert szépen díszítenek a dérben.</p>
                <p>Ősszel ültetheted át azokat az évelőket, amelyek kinőtték a helyüket. A hűvösebb idő és a gyakoribb csapadék segíti a begyökeresedést. Az átültetés után alaposan öntözd be a növényeket, és takard a tövüket komposzttal vagy fakéreggel.</p>
                <h3>Tavaszi hagymások – most ültesd!</h3>
                <p>Az ősz a legjobb időszak a tavaszi hagymások (tulipán, nárcisz, jácint, krókusz) ültetésére. Ezek a növényeknek szükségük van a téli hideghatásra, hogy tavasszal kihajtsanak. A hagymákat legalább kétszer olyan mélyre ültesd, mint amilyen magasak – általában 10-15 cm mélyre. Ügyelj a jó vízelvezetésre, mert a pangó vízben a hagymák elrohadnak. Ültetheted őket csoportokba a legnagyobb látványért, de keverheted más évelőkkel is.</p>
                <h3>Fák, cserjék és a téli védelem</h3>
                <p>A fiatal fák és a fagyérzékeny cserjék (pl. leander, gránátalma) védelmet igényelnek. A tövüket takard be vastag mulccsal, szalmával vagy fenyőkéreggel. A dézsás növényeket érdemes védett helyre húzni, vagy fóliával, nemszőtt textillel betekerni. Ne feledkezz meg az örökzöldekről sem: a téli kisütő nap és a fagy kombinációja károsíthatja a leveleket, ezért árnyékoldalra érdemes telepíteni, vagy takarással védeni.</p>
                <h3>Komposztálás – a természet körforgása</h3>
                <p>Az őszi kerti hulladék (lehullott levél, elszáradt szár, gyomok) kiváló alapanyag a komposztáláshoz. A komposztot rétegezd: egy rész zöld hulladék (pl. fűnyesedék, konyhai zöldségmaradék) és két rész barna hulladék (száraz levél, aprított ágak) ideális arányt ad. A komposztot időnként forgasd meg, hogy levegőzzön. A következő tavaszra kész komposztot kapsz, amivel a kerti talajt gazdagíthatod.</p>
                <h3>Gyepápolás ősszel</h3>
                <p>A gyepet érdemes még egyszer utoljára ősszel fűnyírni, de ne túl rövidre – kb. 5 cm-es magasság ideális. A lehullott leveleket szedd össze a gyepről, mert alattuk kipállhat a fű. Ha a talaj tömörödött, szellőztesd meg (pl. gereblyével vagy speciális szellőztetővel), majd szórj rá homokot vagy komposztot, hogy javítsd a vízelvezetést. Októberben még kiszórhatsz egy őszi gyep-trágyát, amely kevés nitrogént, de több káliumot és foszfort tartalmaz – ez segíti a gyep telelését.</p>
                <div><p><strong>☑️ Őszi projekt:</strong> Ültess el egy cserépbe többféle tavaszi hagymát rétegesen (lasagne-módszer)! Vegyél egy nagyobb cserepet, alulra tedd a legnagyobb hagymákat (pl. tulipán), majd egy vékony földréteg után közepeseket (nárcisz), legfelülre pedig aprókat (krókusz vagy sáfrány). Így tavasszal hosszabb ideig virágzó kompozíciót kapsz egyetlen cserépben.</p></div>
                <p>Az ősz a nyugalom és a készülődés időszaka. Végezd el ezeket a feladatokat most, hogy kerted tavasszal megköszönje. És közben élvezd a színes leveleket, a friss levegőt és a természet csodás átváltozását!</p>',
                'szerzo_id' => 1,
                'fo_kep_id' => 10,
                'letrehozas_datuma' => now(),
                'statusz' => 'közzétett'
            ]
        ];

        foreach ($yourPosts as $post) {
            Posztok::create($post);
        }

        Posztok::factory(5)->create();
        $this->command->info('Posztok table seeded successfully!');
    }
}
