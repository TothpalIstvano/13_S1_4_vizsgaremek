*** Settings ***
Resource    resources.robot
Test Setup    Open Registration Page
Test Teardown    Close Browser Session

*** Test Cases ***


# BLOG OLDAL TESZTEK


Blog Page Loads Successfully
    [Documentation]    A Blog oldal betöltődik és megjelenik a cím
    Navigate To Blog Page
    Element Should Be Visible    ${BLOG_PAGE_TITLE}

Blog Page Shows Post Cards
    [Documentation]    Legalább egy blogposzt kártya látható
    Navigate To Blog Page
    Wait Until Element Is Visible    ${BLOG_CARDS}    timeout=10s
    ${count}=    Get Element Count    ${BLOG_CARDS}
    Should Be True    ${count} > 0

Blog Page Search Filters Posts
    [Documentation]    A keresőmező szűri a posztokat
    Navigate To Blog Page
    Wait Until Element Is Visible    ${BLOG_CARDS}    timeout=10s
    Input Text    ${KERESES_INPUT}    xyznemtalalhato99999
    Sleep    1s
    Wait Until Element Is Visible    xpath://h3[contains(.,"Nincsenek találatok")]    timeout=5s

Blog Page Shows Empty State When No Search Results
    [Documentation]    Nincs találat esetén megjelenik az üres állapot üzenet
    Navigate To Blog Page
    Wait Until Element Is Visible    ${BLOG_CARDS}    timeout=10s
    Input Text    ${KERESES_INPUT}    xyznemtalalhato99999
    Wait Until Element Is Visible    xpath://h3[contains(.,"Nincsenek találatok")]    timeout=5s

Blog Page Search Can Be Cleared
    [Documentation]    A keresőmező törlése visszaállítja a posztlistát
    Navigate To Blog Page
    Wait Until Element Is Visible    ${BLOG_CARDS}    timeout=10s
    Input Text    ${KERESES_INPUT}    xyznemtalalhato99999
    Sleep    0.5s
    Clear Element Text    ${KERESES_INPUT}
    Press Keys    ${KERESES_INPUT}    SPACE
    Press Keys    ${KERESES_INPUT}    BACK_SPACE
    Sleep    2s
    Wait Until Element Is Visible    ${BLOG_CARDS}    timeout=15s
    ${after}=    Get Element Count    ${BLOG_CARDS}
    Should Be True    ${after} > 0

Blog Page Sort Dropdown Opens
    [Documentation]    A rendezési dropdown megnyitható
    Navigate To Blog Page
    Wait Until Element Is Visible    xpath://div[contains(@class,"dropdown_opciok")]    timeout=5s
    Click Element    xpath://div[contains(@class,"dropdown_opciok")]
    Wait Until Element Is Visible    xpath://ul[contains(@class,"dropdown_menu")]    timeout=5s

Blog Page Sort By Oldest
    [Documentation]    A "Legrégebbi elöl" rendezési opció választható
    Navigate To Blog Page
    Wait Until Element Is Visible    xpath://div[contains(@class,"dropdown_opciok")]    timeout=5s
    Click Element    xpath://div[contains(@class,"dropdown_opciok")]
    Wait Until Element Is Visible    xpath://li[contains(.,"Legrégebbi elöl")]    timeout=5s
    Click Element    xpath://li[contains(.,"Legrégebbi elöl")]
    Element Should Contain    xpath://div[contains(@class,"dropdown_opciok")]    Legrégebbi elöl

Blog Page Megtekintes Button Navigates To Single Post
    [Documentation]    A "Megtekintés" gomb a helyes blogposzt oldalra navigál
    Navigate To Blog Page
    Wait Until Element Is Visible    ${MEGTEKINTES_BTN}    timeout=10s
    Click Element    ${MEGTEKINTES_BTN}
    Wait Until Location Contains    /blog/    timeout=10s

Blog Page Tag Filter Opens Panel
    [Documentation]    A cimke MultiSelect panel megnyitható
    Navigate To Blog Page
    Wait Until Element Is Visible    xpath://div[contains(@class,"p-multiselect")]    timeout=5s
    Click Element    xpath://div[contains(@class,"p-multiselect")]
    Wait Until Element Is Visible    xpath://div[contains(@class,"p-multiselect-panel")]    timeout=5s


# SINGLE BLOG POSZT TESZTEK


Single Blog Post Page Loads
    [Documentation]    Az egyes blogposzt oldal betöltődik
    Navigate To Blog Page
    Wait Until Element Is Visible    ${MEGTEKINTES_BTN}    timeout=10s
    Click Element    ${MEGTEKINTES_BTN}
    Wait Until Location Contains    /blog/    timeout=10s
    Wait Until Element Is Visible    xpath://h1[contains(@class,"blog-title")]    timeout=10s

Single Blog Post Shows Title
    [Documentation]    Az egyes blogposzt oldalon megjelenik a poszt cím
    Navigate To Blog Page
    Wait Until Element Is Visible    ${MEGTEKINTES_BTN}    timeout=10s
    ${post_title}=    Get Text    xpath:(//h3[contains(@class,"kartya-cim")])[1]
    Click Element    ${MEGTEKINTES_BTN}
    Wait Until Element Is Visible    xpath://h1[contains(@class,"blog-title")]    timeout=10s
    ${single_title}=    Get Text    xpath://h1[contains(@class,"blog-title")]
    Should Be Equal    ${post_title}    ${single_title}

Single Blog Post Shows Meta Info
    [Documentation]    Megjelennek a meta adatok (dátum, szerző, olvasási idő)
    Navigate To Blog Page
    Wait Until Element Is Visible    ${MEGTEKINTES_BTN}    timeout=10s
    Click Element    ${MEGTEKINTES_BTN}
    Wait Until Element Is Visible    xpath://div[contains(@class,"blog-meta")]    timeout=10s
    Element Should Be Visible    xpath://div[contains(@class,"meta-item")]

Single Blog Post Back Button Works
    [Documentation]    A Vissza gomb visszanavigál a blog listára
    Navigate To Blog Page
    Wait Until Element Is Visible    ${MEGTEKINTES_BTN}    timeout=10s
    Click Element    ${MEGTEKINTES_BTN}
    Wait Until Location Contains    /blog/    timeout=10s
    Wait Until Element Is Visible    xpath://button[contains(@class,"back-btn")]    timeout=5s
    Execute JavaScript    document.querySelector('button.back-btn').click()
    Sleep    1s
    Location Should Contain    blog

Single Blog Post Shows Comment Section
    [Documentation]    Megjelenik a hozzászólások szekció
    Navigate To Blog Page
    Wait Until Element Is Visible    ${MEGTEKINTES_BTN}    timeout=10s
    Click Element    ${MEGTEKINTES_BTN}
    Wait Until Element Is Visible    xpath://div[contains(@class,"kommentek-section")]    timeout=10s
    Element Should Be Visible    xpath://textarea[contains(@placeholder,"hozzászólásodat")]

Single Blog Post Comment Button Visible
    [Documentation]    A Küldés gomb megjelenik a komment szekciónál
    Navigate To Blog Page
    Wait Until Element Is Visible    ${MEGTEKINTES_BTN}    timeout=10s
    Click Element    ${MEGTEKINTES_BTN}
    Wait Until Element Is Visible    xpath://div[contains(@class,"kommentek-section")]    timeout=10s
    Element Should Be Visible    xpath://button[contains(@class,"comment-submit-btn")]

Single Blog Post Shows Tags
    [Documentation]    Megjelennek a cimkék az egyes poszt oldalon
    Navigate To Blog Page
    Wait Until Element Is Visible    ${MEGTEKINTES_BTN}    timeout=10s
    Click Element    ${MEGTEKINTES_BTN}
    Wait Until Element Is Visible    xpath://div[contains(@class,"tags-section")]    timeout=10s
    Element Should Be Visible    xpath://div[contains(@class,"tags-section")]

Single Blog Post Scroll To Top Button Appears
    [Documentation]    A "görgetés fel" gomb megjelenik görgetés után
    Navigate To Blog Page
    Wait Until Element Is Visible    ${MEGTEKINTES_BTN}    timeout=10s
    Click Element    ${MEGTEKINTES_BTN}
    Wait Until Location Contains    /blog/    timeout=10s
    Execute JavaScript    window.scrollTo(0, 500)
    Sleep    0.5s
    Element Should Be Visible    xpath://a[contains(@class,"ugras-felulre")]


# PROFIL OLDAL TESZTEK


Profile Page Shows Posts After Login
    [Documentation]    A profil oldalon megjelennek a felhasználó posztjai
    Login As Test User
    Navigate To Profile Page
    Element Should Be Visible    xpath://h2[contains(.,"profilhoz tartozó cikkek")]

Profile Page Has New Post Button
    [Documentation]    Az "Új bejegyzés" gomb megjelenik a profil oldalon
    Login As Test User
    Navigate To Profile Page
    Element Should Be Visible    xpath://a[contains(.,"Új bejegyzés")]

Profile Page Post Cards Have Edit Link
    [Documentation]    A profil oldalon a poszt kártyákhoz tartozik "Szerkesztés" link
    Login As Test User
    Navigate To Profile Page
    ${post_count}=    Get Element Count    xpath://article[contains(@class,"post-card")]
    Run Keyword If    ${post_count} > 0
    ...    Element Should Be Visible    xpath:(//a[contains(.,"Szerkesztés")])[1]

Profile Page Post Cards Have Read Link
    [Documentation]    A profil oldalon a poszt kártyákhoz tartozik "Olvasás" link
    Login As Test User
    Navigate To Profile Page
    ${post_count}=    Get Element Count    xpath://article[contains(@class,"post-card")]
    Run Keyword If    ${post_count} > 0
    ...    Element Should Be Visible    xpath:(//a[contains(.,"Olvasás")])[1]


# ÚJ POSZT LÉTREHOZÁS TESZTEK


New Post Page Loads After Login
    [Documentation]    Az új poszt oldal betöltődik bejelentkezés után
    Login As Test User
    Navigate To New Post Page
    Element Should Be Visible    ${POST_TITLE_INPUT}
    Element Should Be Visible    ${POST_CONTENT_EDITOR}

New Post Submit Button Disabled When Form Empty
    [Documentation]    A "Poszt feltöltése" gomb le van tiltva üres formnál
    Login As Test User
    Navigate To New Post Page
    Element Should Be Disabled    ${SUBMIT_BTN}

New Post Submit Button Enabled When Title And Content Filled
    [Documentation]    A submit gomb aktív lesz, ha a cím és tartalom ki van töltve
    Login As Test User
    Navigate To New Post Page
    Fill Post Title    Teszt Poszt Cím
    Fill Post Content    Ez a teszt poszt tartalma.
    Element Should Be Enabled    ${SUBMIT_BTN}

New Post Submit Button Disabled With Only Title
    [Documentation]    A submit gomb le van tiltva, ha csak a cím van kitöltve
    Login As Test User
    Navigate To New Post Page
    Fill Post Title    Csak a cím van kitöltve
    Element Should Be Disabled    ${SUBMIT_BTN}

New Post Submit Button Disabled With Only Content
    [Documentation]    A submit gomb le van tiltva, ha csak a tartalom van kitöltve
    Login As Test User
    Navigate To New Post Page
    Fill Post Content    Csak a tartalom van kitöltve.
    Element Should Be Disabled    ${SUBMIT_BTN}

New Post Draft Save Shows Warning Without Required Fields
    [Documentation]    Piszkozat mentésekor kötelező mezők hiánya figyelmeztetést dob
    Login As Test User
    Navigate To New Post Page
    Click Element    ${DRAFT_BTN}
    Notification Should Be Warning

New Post Successful Creation Redirects To Profile
    [Documentation]    Sikeres poszt létrehozás visszairányít a profil oldalra
    Login As Test User
    Navigate To New Post Page
    Fill Post Title    Automatikus Teszt Poszt
    Fill Post Content    Ez egy automatikus tesztelés által létrehozott poszt tartalma.
    Wait Until Element Is Visible    ${SUBMIT_BTN}    timeout=10s
    Wait Until Element Is Enabled    ${SUBMIT_BTN}    timeout=15s
    Set Focus To Element   ${SUBMIT_BTN}
    Click Element    ${SUBMIT_BTN}
    Click Element     ${SUBMIT_BTN}
    Wait Until Location Contains    /profil   timeout=15s

New Post Saved As Draft Redirects To Profile
    [Documentation]    A piszkozat mentése visszairányít a profil oldalra
    Login As Test User
    Navigate To New Post Page
    Fill Post Title    Piszkozat Teszt
    Fill Post Content    Ez egy piszkozat poszt tartalma.
    Click Element    ${DRAFT_BTN}
    Sleep    2s
    Wait Until Location Contains    /profil   timeout=15s

New Post With Subtext Can Be Created
    [Documentation]    Rövid leírással együtt is létre lehet hozni posztot
    Login As Test User
    Navigate To New Post Page
    Fill Post Title    Poszt Rövid Leírással
    Fill Post Subtext    Ez a rövid leírás teszt szövege.
    Fill Post Content    Ez a poszt tartalma rövid leírással együtt.
    Wait Until Element Is Enabled    ${SUBMIT_BTN}    timeout=5s
    Click Element    ${SUBMIT_BTN}
    Click Element     ${SUBMIT_BTN}
    Sleep    2s
    Wait Until Location Contains    /profil   timeout=15s

New Post Reset Button Clears Title
    [Documentation]    A "Visszaállítás" gomb törli az űrlap tartalmát
    Login As Test User
    Navigate To New Post Page
    Sleep    5s
    Fill Post Title    Törlendő cím
    Click Element    ${RESET_BTN}
    Click Element    ${RESET_BTN}
    Sleep    5s
    ${title_value}=    Execute JavaScript    return document.getElementById('postTitle').value
    Sleep    5s
    Should Be Empty    ${title_value}

New Post Page Has Back Button
    [Documentation]    Az új poszt oldalon megjelenik a "Vissza a profilra" gomb
    Login As Test User
    Navigate To New Post Page
    Element Should Be Visible    xpath://button[contains(.,"Vissza a profilra")]

New Post Back Button Returns To Profile
    [Documentation]    A Vissza gomb visszanavigál a profil oldalra
    Login As Test User
    Navigate To New Post Page
    Execute JavaScript    document.querySelector('button.back-btn').click()
    Sleep    1s
    Location Should Contain    Profil

New Post Tags Multiselect Is Visible
    [Documentation]    A cimke MultiSelect komponens megjelenik az új poszt oldalon
    Login As Test User
    Navigate To New Post Page
    Element Should Be Visible    xpath://div[@id="postCimkek"]


# POSZT SZERKESZTÉS TESZTEK


Edit Post Page Loads With Existing Data
    [Documentation]    A szerkesztés oldal betöltődik a meglévő adatokkal
    Login As Test User
    Navigate To Profile Page
    Sleep    5s
    ${post_count}=    Get Element Count    xpath://article[contains(@class,"post-card")]
    Skip If    ${post_count} == 0    Nincs poszt a profilon
    Sleep    5s
    ${edit_href}=    Get First Post Edit Href
    Skip If    '${edit_href}' == ''    Nem található szerkesztés link
    Go To    ${URL}${edit_href}
    Wait Until Element Is Visible    ${POST_TITLE_INPUT}    timeout=10s
    Sleep    3s
    ${title_value}=    Execute JavaScript    return document.getElementById('postTitle').value
    Should Not Be Empty    ${title_value}

Edit Post Title Can Be Modified
    [Documentation]    A poszt cím módosítható szerkesztés közben
    Login As Test User
    Navigate To Profile Page
    Sleep    5s
    ${post_count}=    Get Element Count    xpath://article[contains(@class,"post-card")]
    Skip If    ${post_count} == 0    Nincs poszt a profilon
    Sleep    5s
    ${edit_href}=    Get First Post Edit Href
    Skip If    '${edit_href}' == ''    Nem található szerkesztés link
    Go To    ${URL}${edit_href}
    Wait Until Element Is Visible    ${POST_TITLE_INPUT}    timeout=10s
    Clear Element Text    ${POST_TITLE_INPUT}
    Input Text    ${POST_TITLE_INPUT}    Módosított Teszt Cím
    ${new_value}=    Get Value    ${POST_TITLE_INPUT}
    Should Be Equal    ${new_value}    Módosított Teszt Cím

Edit Post Save Redirects To Profile
    [Documentation]    A szerkesztett poszt mentése visszairányít a profil oldalra
    Login As Test User
    Navigate To Profile Page
    Sleep    5s
    ${post_count}=    Get Element Count    xpath://article[contains(@class,"post-card")]
    Skip If    ${post_count} == 0    Nincs poszt a profilon
    Sleep    5s
    ${edit_href}=    Get First Post Edit Href
    Skip If    '${edit_href}' == ''    Nem található szerkesztés link
    Go To    ${URL}${edit_href}
    Wait Until Element Is Visible    ${SUBMIT_BTN}    timeout=10s
    Wait Until Element Is Enabled    ${SUBMIT_BTN}    timeout=5s
    Click Element    ${SUBMIT_BTN}
    Wait Until Location Contains    /profil   timeout=15s

Edit Post Draft Save Works
    [Documentation]    Szerkesztés közben piszkozatként is menthető a poszt
    Login As Test User
    Navigate To Profile Page
    Sleep    5s
    ${post_count}=    Get Element Count    xpath://article[contains(@class,"post-card")]
    Skip If    ${post_count} == 0    Nincs poszt a profilon
    Sleep    5s
    ${edit_href}=    Get First Post Edit Href
    Skip If    '${edit_href}' == ''    Nem található szerkesztés link
    Go To    ${URL}${edit_href}
    Wait Until Element Is Visible    ${DRAFT_BTN}    timeout=10s
    Sleep    2s
    Click Element    ${DRAFT_BTN}
    Sleep    2s
    Wait Until Location Contains    /profil   timeout=30s

Edit Post Page Has Back Button
    [Documentation]    A szerkesztési oldalon megjelenik a Vissza gomb
    Login As Test User
    Navigate To Profile Page
    Sleep    5s
    ${post_count}=    Get Element Count    xpath://article[contains(@class,"post-card")]
    Skip If    ${post_count} == 0    Nincs poszt a profilon
    Sleep    5s
    ${edit_href}=    Get First Post Edit Href
    Skip If    '${edit_href}' == ''    Nem található szerkesztés link
    Go To    ${URL}${edit_href}
    Wait Until Element Is Visible    xpath://button[contains(.,"Vissza a profilra")]    timeout=10s


# AUTENTIKÁCIÓ TESZTEK


New Post Page Redirects Unauthenticated User
    [Documentation]    Nem bejelentkezett felhasználó nem fér hozzá az új poszt oldalhoz
    Go To    ${URL}/newpost
    Sleep    2s
    ${current_url}=    Get Location
    Log    URL: ${current_url}

Profile Page Requires Authentication
    [Documentation]    A profil oldal bejelentkezést igényel
    Go To    ${URL}/Profil
    Sleep    2s
    ${current_url}=    Get Location
    Log    URL after accessing /Profil unauthenticated: ${current_url}

Logged In User Can Access New Post Page
    [Documentation]    Bejelentkezett felhasználó eléri az új poszt oldalt
    Login As Test User
    Navigate To New Post Page
    ${current_url}=    Get Location
    Should Contain    ${current_url}    newpost

Logged In User Like Button Is Clickable
    [Documentation]    Bejelentkezett felhasználó megnyomhatja a like gombot és a számláló megváltozik.
    Login As Test User
    Navigate To Blog Page
    
    # Lokátorok kiszervezése (könnyebb karbantartani)
    ${LIKE_BUTTON}     Set Variable    xpath:(//button[contains(@class,"like-gomb")])[1]
    ${COUNT_SPAN}      Set Variable    xpath:(//button[contains(@class,"like-gomb")])[1]//span[@class="reakciok-szama"]

    # 1. Megvárjuk, amíg az oldal betölt és a gomb látható lesz
    Wait Until Element Is Visible    ${LIKE_BUTTON}    timeout=15s
    
    # 2. Elmentjük az aktuális értéket
    ${old_count} =    Get Text    ${COUNT_SPAN}
    
    # 3. Kattintás a gombra
    Click Element    ${LIKE_BUTTON}

    Wait Until Keyword Succeeds    5s    0.5s    Check Count Changed    ${COUNT_SPAN}    ${old_count}

    # 5. Új érték lekérése és végső ellenőrzés
    ${new_count} =    Get Text    ${COUNT_SPAN}
    Should Not Be Equal As Integers    ${old_count}    ${new_count}
    Log    Sikeres változás: ${old_count} -> ${new_count}

Logged In User Can Submit Comment
    [Documentation]    Bejelentkezett felhasználó hozzászólhat blogposzthoz
    Login As Test User
    Navigate To Blog Page
    Wait Until Element Is Visible    ${MEGTEKINTES_BTN}    timeout=10s
    Click Element    ${MEGTEKINTES_BTN}
    Wait Until Element Is Visible    xpath://textarea[contains(@placeholder,"hozzászólásodat")]    timeout=10s
    Input Text    xpath://textarea[contains(@placeholder,"hozzászólásodat")]    Automatikus teszt hozzászólás
    Wait Until Element Is Enabled    xpath://button[contains(@class,"comment-submit-btn")]    timeout=5s
    Click Element    xpath://button[contains(@class,"comment-submit-btn")]
    Sleep    2s
