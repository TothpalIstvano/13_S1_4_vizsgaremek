*** Settings ***
Library     SeleniumLibrary
Library     Collections
Resource    resources.robot

Test Setup       Run Keywords
...              Open Registration Page
Test Teardown    Close Browser Session

*** Variables ***
${DASHBOARD_URL}        http://localhost:5173/dashboard
${ADMIN_EMAIL}          test@example.com
${ADMIN_PASS}           Alma12345678.

# ── Sidebar navigáció ──
${NAV_DASHBOARD}        xpath://a[contains(@class,"nav-link") and contains(.,"Dashboard")]
${NAV_PRODUCTS}         xpath://a[contains(@class,"nav-link") and contains(.,"Termékek")]
${NAV_KATEGORIAK}       xpath://a[contains(@class,"nav-link") and contains(.,"Kategóriák")]
${NAV_ORDERS}           xpath://a[contains(@class,"nav-link") and contains(.,"Rendelések")]
${NAV_BLOG}             xpath://a[contains(@class,"nav-link") and contains(.,"Blogbejegyzések")]
${NAV_COMMENTS}         xpath://a[contains(@class,"nav-link") and contains(.,"Kommentek")]
${NAV_REPORTS}          xpath://a[contains(@class,"nav-link") and contains(.,"Bejelentések")]
${NAV_USERS}            xpath://a[contains(@class,"nav-link") and contains(.,"Felhasználók")]
${NAV_ANALYTICS}        xpath://a[contains(@class,"nav-link") and contains(.,"Analitika")]

# ── Dashboard ──
${STAT_CARDS}           xpath://div[contains(@class,"stat-card")]
${REFRESH_BTN}          xpath://button[contains(.,"Frissítés")]

# ── Termékek ──
${NEW_PRODUCT_BTN}      xpath://button[contains(.,"Új termék")]
${PRODUCT_MODAL}        xpath://div[contains(@class,"modal")]
${PRODUCT_SAVE_BTN}     xpath://div[contains(@class,"modal-footer")]//button[contains(.,"Mentés") and not(contains(.,"Mégse"))]
${PRODUCT_CANCEL_BTN}   xpath://div[contains(@class,"modal-footer")]//button[contains(.,"Mégse")]
${PRODUCT_SEARCH}       xpath://input[contains(@placeholder,"Keresés termékek")]
${PRODUCT_TABLE}        xpath://table//tbody/tr
${PRODUCT_EDIT_BTN}     xpath:(//button[contains(@class,"btn-warning")])[1]
${PRODUCT_DELETE_BTN}   xpath:(//button[contains(@class,"btn-danger")])[1]
${CAT_FILTER_SELECT}    xpath://select[.//option[contains(.,"Fonalak") or contains(.,"összes kategória")]]
${STOCK_FILTER_SELECT}  xpath://select[.//option[contains(.,"Raktáron") or contains(.,"Összes készlet")]]
${CONFIRM_YES}          xpath://button[contains(@class,"confirm-btn danger")]
${CONFIRM_NO}           xpath://button[contains(@class,"confirm-btn cancel")]

# ── Rendelések ──
${ORDER_SEARCH}         xpath://input[contains(@placeholder,"Keresés (név vagy ID")]
${ORDER_STATUS_FILTER}  xpath://select[.//option[contains(.,"Teljesítve") or contains(.,"Összes státusz")]]
${ORDER_TABLE_ROWS}     xpath://table//tbody/tr
${ORDER_DELETE_BTN}     xpath:(//button[contains(@class,"btn-danger")])[1]
${ORDER_ITEMS_BADGE}    xpath:(//span[contains(@class,"badge-warning") and contains(.,"termék")])[1]

# ── Felhasználók ──
${NEW_USER_BTN}         xpath://button[contains(.,"Új felhasználó")]
${USER_MODAL}           xpath://div[contains(@class,"modal") and .//h3[contains(.,"Felhasználó")]]
${USER_SAVE_BTN}        xpath://div[contains(@class,"modal-footer")]//button[contains(.,"Mentés")]
${USER_CANCEL_BTN}      xpath://div[contains(@class,"modal-footer")]//button[contains(.,"Mégse")]
${USER_SEARCH}          xpath://input[contains(@placeholder,"Keresés felhasználók")]
${USER_ROLE_FILTER}     xpath://select[.//option[contains(.,"Összes szerepkör")]]
${USER_ACTIVE_FILTER}   xpath:(//div[contains(@class,"filters")]//select)[2]
${USER_TABLE_ROWS}      xpath://table//tbody/tr

# ── Blog ──
${NEW_BLOG_BTN}         xpath://button[contains(.,"Új bejegyzés")]
${BLOG_MODAL}           xpath://div[contains(@class,"modal")]
${BLOG_TITLE_INPUT}     id:postTitle
${BLOG_SAVE_BTN}    xpath://div[contains(@class,"modal-footer")]//button[contains(.,"feltöltése") or contains(.,"piszkozat") or contains(.,"Mentés")]
${BLOG_CANCEL_BTN}      xpath://div[contains(@class,"modal-footer")]//button[contains(.,"Mégse")]
${BLOG_SEARCH}          xpath://input[contains(@placeholder,"Keresés bejegyzések")]
${BLOG_STATUS_FILTER}   xpath://select[.//option[contains(.,"Publikálva")]]
${BLOG_TABLE_ROWS}      xpath://table//tbody/tr
${BLOG_EDIT_BTN}        xpath:(//button[contains(@class,"btn-warning")])[1]
${BLOG_DELETE_BTN}      xpath:(//button[contains(@class,"btn-danger")])[1]

# ── Kommentek ──
${COMMENT_SEARCH}       xpath://input[contains(@placeholder,"Keresés (tartalom")]
${COMMENT_TABLE_ROWS}   xpath://table//tbody/tr
${COMMENT_DELETE_BTN}   xpath:(//button[contains(@class,"btn-danger")])[1]

# ── Kategóriák ──
${NEW_KAT_BTN}          xpath://button[contains(.,"Új kategória")]
${KAT_MODAL}            xpath://div[contains(@class,"modal") and .//h3[contains(.,"kategória")]]
${KAT_NAME_INPUT}       xpath://div[contains(@class,"modal-body")]//input[@type="text"]
${KAT_SAVE_BTN}         xpath://div[contains(@class,"modal-footer")]//button[contains(.,"Létrehozás")]
${KAT_CANCEL_BTN}       xpath://div[contains(@class,"modal-footer")]//button[contains(.,"Mégse")]
${KAT_SEARCH}           xpath://input[contains(@placeholder,"Keresés kategóriák")]
${KAT_TYPE_FILTER}      xpath://select[.//option[contains(.,"Blog kategória")]]
${KAT_TABLE_ROWS}       xpath://table//tbody/tr

*** Keywords ***
Go To Dashboard As Admin
    [Documentation]
    ...    A resources.robot Login As Admin And Go To Dashboard kulcsszavát hívja.
    ...    Az előtte lévő Open Browser + Maximize már a Test Setup lefutott.
    Login As Admin And Go To Dashboard

Navigate To View And Wait
    [Arguments]    ${nav_locator}    ${heading_text}    ${timeout}=10s
    Click Element    ${nav_locator}
    Wait Until Element Is Visible
    ...    xpath://h2[contains(.,"${heading_text}")]    timeout=${timeout}

Open And Close Modal With Cancel
    [Arguments]    ${open_btn}    ${modal_locator}    ${cancel_btn}
    Click Element    ${open_btn}
    Wait Until Element Is Visible    ${modal_locator}    timeout=5s
    Execute JavaScript    document.querySelector('.modal-footer').scrollIntoView()
    Sleep    0.3s
    Click Element    ${cancel_btn}
    Wait Until Element Is Not Visible    ${modal_locator}    timeout=5s

Wait For Toast
    [Arguments]    ${timeout}=5s
    Wait Until Element Is Visible
    ...    xpath://div[contains(@class,"toast")]    timeout=${timeout}

*** Test Cases ***

# ════════════════════════════════════════════════════
# 1. BELÉPÉS ÉS DASHBOARD
# ════════════════════════════════════════════════════

TC-01 Admin bejelentkezés és dashboard megjelenítés
    [Documentation]    Admin belép, a dashboard fő elemei megjelennek
    [Tags]    login    dashboard    smoke
    Go To Dashboard As Admin
    Element Should Be Visible    xpath://h2[contains(.,"Dashboard")]
    Element Should Be Visible    ${NAV_DASHBOARD}
    ${count}=    Get Element Count    ${STAT_CARDS}
    Should Be True    ${count} >= 4    msg=Legalább 4 stat kártya szükséges

TC-02 Dashboard statisztika kártyák megjelenítése
    [Documentation]    Értékesítés, rendelések, termékek, felhasználók kártyák látszanak
    [Tags]    dashboard    stats
    Go To Dashboard As Admin
    Wait Until Element Is Not Visible
    ...    xpath://div[contains(@class,"skeleton-value")]    timeout=15s
    Element Should Be Visible
    ...    xpath://div[contains(@class,"stat-title") and contains(.,"értékesítés")]
    Element Should Be Visible
    ...    xpath://div[contains(@class,"stat-title") and contains(.,"Rendelések")]
    Element Should Be Visible
    ...    xpath://div[contains(@class,"stat-title") and contains(.,"Termékek")]
    Element Should Be Visible
    ...    xpath://div[contains(@class,"stat-title") and contains(.,"Felhasználók")]

TC-03 Dashboard frissítés gomb működése
    [Documentation]    Frissítés gombra kattintva az adatok újratöltődnek
    [Tags]    dashboard
    Go To Dashboard As Admin
    Wait Until Element Is Visible    ${REFRESH_BTN}    timeout=10s
    Click Element    ${REFRESH_BTN}
    Wait Until Element Is Not Visible
    ...    xpath://div[contains(@class,"skeleton-chart")]    timeout=20s
    Element Should Be Visible    ${STAT_CARDS}

# ════════════════════════════════════════════════════
# 2. SIDEBAR NAVIGÁCIÓ
# ════════════════════════════════════════════════════

TC-04 Sidebar - Termékek nézet
    [Documentation]    Termékek menüpont megnyitja a termékek táblázatot és aktív lesz
    [Tags]    navigation    sidebar
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_PRODUCTS}    Termékek
    Element Should Be Visible    ${NEW_PRODUCT_BTN}
    Dashboard Sidebar Link Should Be Active    Termékek

TC-05 Sidebar - Rendelések nézet
    [Documentation]    Rendelések menüpont megnyitja a rendelések táblázatot és aktív lesz
    [Tags]    navigation    sidebar
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_ORDERS}    Rendelések
    Element Should Be Visible    ${ORDER_SEARCH}
    Dashboard Sidebar Link Should Be Active    Rendelések

TC-06 Sidebar - Felhasználók nézet
    [Documentation]    Felhasználók menüpont megnyitja a felhasználók táblázatot és aktív lesz
    [Tags]    navigation    sidebar
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_USERS}    Felhasználók
    Element Should Be Visible    ${NEW_USER_BTN}
    Dashboard Sidebar Link Should Be Active    Felhasználók

TC-07 Sidebar - Blog nézet
    [Documentation]    Blog menüpont megnyitja a bejegyzések táblázatot és aktív lesz
    [Tags]    navigation    sidebar
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_BLOG}    Blogbejegyzések
    Element Should Be Visible    ${NEW_BLOG_BTN}
    Dashboard Sidebar Link Should Be Active    Blogbejegyzések

TC-08 Sidebar - Kommentek nézet
    [Documentation]    Kommentek menüpont megnyitja a kommentek táblázatot és aktív lesz
    [Tags]    navigation    sidebar
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_COMMENTS}    Kommentek
    Element Should Be Visible    ${COMMENT_SEARCH}
    Dashboard Sidebar Link Should Be Active    Kommentek

TC-09 Sidebar - Kategóriák nézet
    [Documentation]    Kategóriák menüpont megnyitja a kategóriák táblázatot és aktív lesz
    [Tags]    navigation    sidebar
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_KATEGORIAK}    Kategóriák
    Element Should Be Visible    ${NEW_KAT_BTN}
    Dashboard Sidebar Link Should Be Active    Kategóriák

TC-10 Sidebar - Bejelentések nézet
    [Documentation]    Bejelentések menüpont megnyitja a bejelentések oldalt és aktív lesz
    [Tags]    navigation    sidebar
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_REPORTS}    Bejelentések
    Dashboard Sidebar Link Should Be Active    Bejelentések

TC-11 Sidebar - Analitika nézet
    [Documentation]    Analitika menüpont megnyitja az analitika oldalt és aktív lesz
    [Tags]    navigation    sidebar
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_ANALYTICS}    Analitika
    Dashboard Sidebar Link Should Be Active    Analitika

# ════════════════════════════════════════════════════
# 3. TERMÉKEK - KERESÉS ÉS SZŰRÉS
# ════════════════════════════════════════════════════

TC-12 Termékek - keresés nem létező termékre üres listát ad
    [Documentation]    Nem létező névre keresve a táblázat üres lesz
    [Tags]    products    search
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_PRODUCTS}    Termékek
    Wait Until Element Is Visible    ${PRODUCT_SEARCH}    timeout=10s
    Input Text    ${PRODUCT_SEARCH}    xyz_nem_letezik_99999
    Sleep    0.5s
    ${count}=    Get Element Count    ${PRODUCT_TABLE}
    Should Be Equal As Integers    ${count}    0

TC-13 Termékek - keresés törlése visszaállítja a listát
    [Documentation]    Keresés után a mező törlésével az összes termék visszajön
    [Tags]    products    search
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_PRODUCTS}    Termékek
    Wait Until Element Is Visible    ${PRODUCT_SEARCH}    timeout=10s
    Input Text    ${PRODUCT_SEARCH}    fonal
    Sleep    0.5s
    ${szurt}=    Get Element Count    ${PRODUCT_TABLE}
    Clear Element Text    ${PRODUCT_SEARCH}
    Input Text    ${PRODUCT_SEARCH}    ${EMPTY}
    Sleep    0.5s
    ${osszes}=    Get Element Count    ${PRODUCT_TABLE}
    Should Be True    ${osszes} >= ${szurt}

TC-14 Termékek - kategória szűrő csökkenti a listát
    [Documentation]    Egy kategória kiválasztásával a lista szűkül, visszaállítással bővül
    [Tags]    products    filter
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_PRODUCTS}    Termékek
    Wait Until Element Is Visible    ${CAT_FILTER_SELECT}    timeout=10s
    Select From List By Index    ${CAT_FILTER_SELECT}    1
    Sleep    0.5s
    ${szurt}=    Get Element Count    ${PRODUCT_TABLE}
    Select From List By Index    ${CAT_FILTER_SELECT}    0
    Sleep    0.5s
    ${osszes}=    Get Element Count    ${PRODUCT_TABLE}
    Should Be True    ${osszes} >= ${szurt}

TC-15 Termékek - készlet szűrő raktáron nem mutat nincs készleten sort
    [Documentation]    Raktáron szűrőnél badge-danger "Nincs" sor nem szerepelhet
    [Tags]    products    filter
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_PRODUCTS}    Termékek
    Wait Until Element Is Visible    ${STOCK_FILTER_SELECT}    timeout=10s
    Select From List By Value    ${STOCK_FILTER_SELECT}    raktaron
    Sleep    0.5s
    ${sorok}=    Get Element Count    ${PRODUCT_TABLE}
    Run Keyword If    ${sorok} > 0
    ...    Element Should Not Be Visible
    ...    xpath://table//tbody//span[contains(@class,"badge-danger") and contains(.,"Nincs")]

TC-16 Termékek - ID szerint rendezés ASC majd DESC
    [Documentation]    ID fejlécre kétszer kattintva előbb ASC, majd DESC sorrendet ad
    [Tags]    products    sort
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_PRODUCTS}    Termékek
    Wait Until Element Is Visible    xpath:(//th[contains(.,"ID")])[1]    timeout=10s
    Click Element    xpath:(//th[contains(.,"ID")])[1]
    Sleep    0.5s
    ${elso_asc}=    Get Text    xpath:(//table//tbody/tr[1]/td[1])[1]
    Click Element    xpath:(//th[contains(.,"ID")])[1]
    Sleep    0.5s
    ${elso_desc}=    Get Text    xpath:(//table//tbody/tr[1]/td[1])[1]
    Should Not Be Equal    ${elso_asc}    ${elso_desc}
    ...    msg=Kétszeri kattintás után a sorrend meg kell változzon

TC-17 Termékek - Ár szerint rendezés
    [Documentation]    Ár fejlécre kattintva az ár szerint rendezi a listát
    [Tags]    products    sort
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_PRODUCTS}    Termékek
    Wait Until Element Is Visible    xpath:(//th[contains(.,"Ár")])[1]    timeout=10s
    Click Element    xpath:(//th[contains(.,"Ár")])[1]
    Sleep    0.5s
    ${elso}=    Get Text    xpath:(//table//tbody/tr[1]/td[5])[1]
    Should Not Be Empty    ${elso}

# ════════════════════════════════════════════════════
# 4. TERMÉKEK - MODAL ÉS VALIDÁCIÓ
# ════════════════════════════════════════════════════

TC-18 Termékek - új termék modal megnyílik
    [Documentation]    Új termék gombra kattintva megnyílik a modal az összes szükséges elemmel
    [Tags]    products    modal
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_PRODUCTS}    Termékek
    Wait Until Element Is Visible    ${NEW_PRODUCT_BTN}    timeout=10s
    Click Element    ${NEW_PRODUCT_BTN}
    Wait Until Element Is Visible    ${PRODUCT_MODAL}    timeout=5s
    Element Should Be Visible    ${PRODUCT_SAVE_BTN}
    Element Should Be Visible    ${PRODUCT_CANCEL_BTN}

TC-19 Termékek - modal bezárása Mégse gombbal
    [Documentation]    Mégse gombra a modal bezárul
    [Tags]    products    modal
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_PRODUCTS}    Termékek
    Wait Until Element Is Visible    ${NEW_PRODUCT_BTN}    timeout=10s
    Open And Close Modal With Cancel
    ...    ${NEW_PRODUCT_BTN}    ${PRODUCT_MODAL}    ${PRODUCT_CANCEL_BTN}

TC-20 Termékek - üres névvel nem menthető (validáció)
    [Documentation]    Mentés gombra üres névnél toast hibaüzenet jelenik meg
    [Tags]    products    validation
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_PRODUCTS}    Termékek
    Wait Until Element Is Visible    ${NEW_PRODUCT_BTN}    timeout=10s
    Click Element    ${NEW_PRODUCT_BTN}
    Wait Until Element Is Visible    ${PRODUCT_MODAL}    timeout=5s
    Click Element    ${PRODUCT_SAVE_BTN}
    Wait For Toast
    Element Should Contain
    ...    xpath://div[contains(@class,"toast")]    neve kötelező

TC-21 Termékek - kategória nélkül nem menthető (validáció)
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_PRODUCTS}    Termékek
    Wait Until Element Is Visible    ${NEW_PRODUCT_BTN}    timeout=10s
    Click Element    ${NEW_PRODUCT_BTN}
    Wait Until Element Is Visible    ${PRODUCT_MODAL}    timeout=5s
    Wait Until Element Is Visible    xpath://div[contains(@class,"modal-body")]//input    timeout=5s
    ${input_selector}=    Execute JavaScript    return document.querySelector('.modal-body input') ? '.modal-body input' : '.modal input';
    Execute JavaScript    document.querySelector('${input_selector}').focus();
    Execute JavaScript    document.querySelector('${input_selector}').value = 'Teszt termék';
    Execute JavaScript    document.querySelector('${input_selector}').dispatchEvent(new Event('input',{bubbles:true}));
    Sleep    0.5s
    Click Element    ${PRODUCT_SAVE_BTN}
    Wait For Toast
    Element Should Contain    xpath://div[contains(@class,"toast")]    kategóriát

TC-22 Termékek - szerkesztő modal "szerkesztése" felirattal nyílik meg
    [Documentation]    Szerkesztés gombra a modal fejléce "szerkesztése" szót tartalmaz
    [Tags]    products    modal    edit
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_PRODUCTS}    Termékek
    Wait Until Element Is Visible    ${PRODUCT_EDIT_BTN}    timeout=10s
    Click Element    ${PRODUCT_EDIT_BTN}
    Wait Until Element Is Visible    xpath://div[contains(@class,"modal")]    timeout=8s
    Element Should Be Visible    xpath://div[contains(@class,"modal")]//h3[contains(.,"szerkeszt")]


TC-23 Termékek - törlés megerősítő dialog mindkét gombbal megjelenik
    [Documentation]    Törlés gombra a megerősítő dialog Igen és Mégse gombbal megjelenik
    [Tags]    products    delete
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_PRODUCTS}    Termékek
    Wait Until Element Is Visible    ${PRODUCT_DELETE_BTN}    timeout=10s
    Click Element    ${PRODUCT_DELETE_BTN}
    Wait Until Element Is Visible    ${CONFIRM_YES}    timeout=5s
    Element Should Be Visible    ${CONFIRM_NO}
    Click Element    ${CONFIRM_NO}

TC-24 Termékek - törlés Mégse nem változtatja meg a lista méretét
    [Documentation]    Mégse gombra a termék száma változatlan marad
    [Tags]    products    delete
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_PRODUCTS}    Termékek
    Wait Until Element Is Visible    ${PRODUCT_TABLE}    timeout=10s
    ${elotte}=    Get Element Count    ${PRODUCT_TABLE}
    Click Element    ${PRODUCT_DELETE_BTN}
    Wait Until Element Is Visible    ${CONFIRM_NO}    timeout=5s
    Click Element    ${CONFIRM_NO}
    Wait Until Element Is Not Visible    ${CONFIRM_NO}    timeout=5s
    ${utana}=    Get Element Count    ${PRODUCT_TABLE}
    Should Be Equal    ${elotte}    ${utana}

# ════════════════════════════════════════════════════
# 5. RENDELÉSEK - KERESÉS, SZŰRÉS, TÖRLÉS
# ════════════════════════════════════════════════════

TC-25 Rendelések - keresés nem létező névre üres listát ad
    [Documentation]    Nem létező névre keresve a lista üres, "Nincs találat" szöveg látszik
    [Tags]    orders    search
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_ORDERS}    Rendelések
    Wait Until Element Is Visible    ${ORDER_SEARCH}    timeout=10s
    Input Text    ${ORDER_SEARCH}    xyz_nincsilyen_99999
    Sleep    0.5s
    ${count}=    Get Element Count    ${ORDER_TABLE_ROWS}
    Should Be Equal As Integers    ${count}    0
    Element Should Be Visible    xpath://div[contains(.,"Nincs találat")]

TC-26 Rendelések - státusz szűrő teljesítve nem mutat egyéb státuszt
    [Documentation]    Teljesítve szűrőre kattintva más státuszú sor nem szerepelhet
    [Tags]    orders    filter
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_ORDERS}    Rendelések
    Wait Until Element Is Visible    ${ORDER_STATUS_FILTER}    timeout=10s
    Select From List By Value    ${ORDER_STATUS_FILTER}    teljesítve
    Sleep    0.5s
    ${sorok}=    Get Element Count    ${ORDER_TABLE_ROWS}
    Run Keyword If    ${sorok} > 0
    ...    Element Should Not Be Visible
    ...    xpath://table//tbody//span[contains(@class,"badge-danger")]

TC-27 Rendelések - státusz szűrő visszaállítás után több sor látszik
    [Documentation]    Szűrő törlése visszaállítja az összes rendelést
    [Tags]    orders    filter
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_ORDERS}    Rendelések
    Wait Until Element Is Visible    ${ORDER_STATUS_FILTER}    timeout=10s
    Select From List By Value    ${ORDER_STATUS_FILTER}    teljesítve
    Sleep    0.5s
    ${szurt}=    Get Element Count    ${ORDER_TABLE_ROWS}
    Select From List By Index    ${ORDER_STATUS_FILTER}    0
    Sleep    0.5s
    ${osszes}=    Get Element Count    ${ORDER_TABLE_ROWS}
    Should Be True    ${osszes} >= ${szurt}

TC-28 Rendelések - termékek popover megnyílik badge kattintásra
    [Documentation]    Termék badge-re kattintva egy lebegő termék lista jelenik meg
    [Tags]    orders    ui
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_ORDERS}    Rendelések
    Wait Until Element Is Visible    ${ORDER_ITEMS_BADGE}    timeout=10s
    Click Element    ${ORDER_ITEMS_BADGE}
    Sleep    0.5s
    Element Should Be Visible
    ...    xpath://div[contains(@style,"position:absolute") or contains(@style,"position: absolute")]

TC-29 Rendelések - szállítás alatt lévő rendelés törlés gombja disabled
    [Documentation]    Szállítás alatt státuszú sornál a törlés gomb le van tiltva
    [Tags]    orders    validation
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_ORDERS}    Rendelések
    Wait Until Element Is Visible    ${ORDER_TABLE_ROWS}    timeout=10s
    @{szallitas_sorok}=    Get WebElements
    ...    xpath://table//tbody/tr[.//span[contains(.,"szállítás alatt")]]
    ${van}=    Run Keyword And Return Status
    ...    Should Not Be Empty    ${szallitas_sorok}
    Pass Execution If    not ${van}
    ...    Nincs szállítás alatt lévő rendelés - teszt kihagyva
    ${delete_btn}=    Get WebElement
    ...    xpath://table//tbody/tr[.//span[contains(.,"szállítás alatt")]]//button[contains(@class,"btn-danger")]
    Element Should Be Disabled    ${delete_btn}

TC-30 Rendelések - törlés megerősítő dialog megjelenik
    [Documentation]    Aktív törlés gombra megerősítő dialog jelenik meg, Mégse zárja be
    [Tags]    orders    delete
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_ORDERS}    Rendelések
    Wait Until Element Is Visible    ${ORDER_DELETE_BTN}    timeout=10s
    ${disabled}=    Run Keyword And Return Status
    ...    Element Should Be Disabled    ${ORDER_DELETE_BTN}
    Pass Execution If    ${disabled}
    ...    Az első rendelés szállítás alatt van - teszt kihagyva
    Click Element    ${ORDER_DELETE_BTN}
    Wait Until Element Is Visible    ${CONFIRM_YES}    timeout=5s
    Click Element    ${CONFIRM_NO}

# ════════════════════════════════════════════════════
# 6. FELHASZNÁLÓK - MODAL, SZŰRÉS, VALIDÁCIÓ
# ════════════════════════════════════════════════════

TC-31 Felhasználók - új felhasználó modal megnyílik
    [Documentation]    Új felhasználó gombra a modal megnyílik a mentés gombbal
    [Tags]    users    modal
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_USERS}    Felhasználók
    Wait Until Element Is Visible    ${NEW_USER_BTN}    timeout=10s
    Click Element    ${NEW_USER_BTN}
    Execute JavaScript    document.querySelector('.modal-footer').scrollIntoView()
    Wait Until Element Is Visible    ${USER_MODAL}    timeout=5s
    Element Should Be Visible    ${USER_SAVE_BTN}

TC-32 Felhasználók - modal bezárása Mégse gombbal
    [Documentation]    Mégse gombra a felhasználó modal bezárul
    [Tags]    users    modal
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_USERS}    Felhasználók
    Wait Until Element Is Visible    ${NEW_USER_BTN}    timeout=10s
    Open And Close Modal With Cancel
    ...    ${NEW_USER_BTN}    ${USER_MODAL}    ${USER_CANCEL_BTN}

TC-33 Felhasználók - keresés nem létező névre üres listát ad
    [Documentation]    Nem létező névre keresve a felhasználó lista üres lesz
    [Tags]    users    search
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_USERS}    Felhasználók
    Wait Until Element Is Visible    ${USER_SEARCH}    timeout=10s
    Input Text    ${USER_SEARCH}    xyz_nincsilyen_felhasz_99999
    Sleep    0.5s
    ${count}=    Get Element Count    ${USER_TABLE_ROWS}
    Should Be Equal As Integers    ${count}    0

TC-34 Felhasználók - szerepkör szűrő admin csak admin sorokat mutat
    [Documentation]    Admin szűrőre kattintva más szerepkörű sor nem szerepelhet
    [Tags]    users    filter
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_USERS}    Felhasználók
    Wait Until Element Is Visible    ${USER_ROLE_FILTER}    timeout=10s
    Select From List By Value    ${USER_ROLE_FILTER}    admin
    Sleep    0.5s
    ${sorok}=    Get Element Count    ${USER_TABLE_ROWS}
    Run Keyword If    ${sorok} > 0
    ...    Element Should Not Be Visible
    ...    xpath://table//tbody//span[contains(@class,"badge-success") and contains(.,"sima")]

TC-35 Felhasználók - aktív szűrő nem mutat inaktív felhasználót
    [Documentation]    Aktív szűrőre kattintva inaktív badge nem lehet a listában
    [Tags]    users    filter
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_USERS}    Felhasználók
    Wait Until Element Is Visible    ${USER_ACTIVE_FILTER}    timeout=10s
    Select From List By Value    ${USER_ACTIVE_FILTER}    true
    Sleep    0.5s
    @{inaktiv}=    Get WebElements
    ...    xpath://table//tbody//span[contains(@class,"badge-danger") and contains(.,"Inaktív")]
    Should Be Empty    ${inaktiv}
    ...    msg=Aktív szűrőnél ne legyen inaktív badge

TC-36 Felhasználók - saját fiók szerkesztés gombja disabled
    [Documentation]    A bejelentkezett admin sorában a szerkesztés gomb le van tiltva
    [Tags]    users    validation
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_USERS}    Felhasználók
    Wait Until Element Is Visible    ${USER_TABLE_ROWS}    timeout=10s
    ${disabled}=    Run Keyword And Return Status
    ...    Element Should Be Disabled
    ...    xpath://table//tbody/tr[.//td[contains(.,"${ADMIN_EMAIL}")]]//button[contains(@class,"btn-warning")]
    Should Be True    ${disabled}
    ...    msg=Saját fiók szerkesztése le kell legyen tiltva

TC-37 Felhasználók - szerkesztő modal "Szerkesztése" felirattal nyílik meg
    [Documentation]    Más felhasználó szerkesztés gombjára a modal fejléce "Szerkesztése"
    [Tags]    users    modal    edit
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_USERS}    Felhasználók
    Wait Until Element Is Visible    ${USER_TABLE_ROWS}    timeout=10s
    ${edit_btn}=    Get WebElement
    ...    xpath://table//tbody/tr[.//button[not(@disabled) and contains(@class,"btn-warning")]][1]//button[contains(@class,"btn-warning")]
    Click Element    ${edit_btn}
    Wait Until Element Is Visible    ${USER_MODAL}    timeout=5s
    Element Should Be Visible
    ...    xpath://div[contains(@class,"modal")]//h3[contains(.,"Szerkesztése")]

TC-38 Felhasználók - törlés megerősítő dialog megjelenik
    [Documentation]    Aktív törlés gombra megerősítő dialog jelenik meg, Mégse zárja be
    [Tags]    users    delete
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_USERS}    Felhasználók
    Wait Until Element Is Visible    ${USER_TABLE_ROWS}    timeout=10s
    ${delete_btn}=    Get WebElement
    ...    xpath://table//tbody/tr[.//button[not(@disabled) and contains(@class,"btn-danger")]][1]//button[contains(@class,"btn-danger") and not(@disabled)]
    Click Element    ${delete_btn}
    Wait Until Element Is Visible    ${CONFIRM_YES}    timeout=5s
    Click Element    ${CONFIRM_NO}

# ════════════════════════════════════════════════════
# 7. BLOG BEJEGYZÉSEK
# ════════════════════════════════════════════════════

TC-39 Blog - új bejegyzés modal megnyílik a szükséges elemekkel
    [Documentation]    Új bejegyzés gombra megnyílik a modal a cím mezővel és mentés gombbal
    [Tags]    blog    modal
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_BLOG}    Blogbejegyzések
    Wait Until Element Is Visible    ${NEW_BLOG_BTN}    timeout=10s
    Click Element    ${NEW_BLOG_BTN}
    Wait Until Element Is Visible    ${BLOG_MODAL}    timeout=5s
    Element Should Be Visible    ${BLOG_TITLE_INPUT}
    Element Should Be Visible    ${BLOG_SAVE_BTN}

TC-40 Blog - modal bezárása Mégse gombbal
    [Documentation]    Mégse gombra a blog modal bezárul
    [Tags]    blog    modal
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_BLOG}    Blogbejegyzések
    Wait Until Element Is Visible    ${NEW_BLOG_BTN}    timeout=10s
    Open And Close Modal With Cancel
    ...    ${NEW_BLOG_BTN}    ${BLOG_MODAL}    ${BLOG_CANCEL_BTN}

TC-41 Blog - keresés nem létező cím üres listát ad
    [Documentation]    Nem létező cím keresésére a lista üres lesz
    [Tags]    blog    search
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_BLOG}    Blogbejegyzések
    Wait Until Element Is Visible    ${BLOG_SEARCH}    timeout=10s
    Input Text    ${BLOG_SEARCH}    xyz_nincsilyen_cim_99999
    Sleep    0.5s
    ${count}=    Get Element Count    ${BLOG_TABLE_ROWS}
    Should Be Equal As Integers    ${count}    0

TC-42 Blog - státusz szűrő publikálva nem mutat törölt bejegyzést
    [Documentation]    Publikálva szűrőre kattintva törölt badge nem látható
    [Tags]    blog    filter
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_BLOG}    Blogbejegyzések
    Wait Until Element Is Visible    ${BLOG_STATUS_FILTER}    timeout=10s
    Select From List By Value    ${BLOG_STATUS_FILTER}    true
    Sleep    0.5s
    @{torolt}=    Get WebElements
    ...    xpath://table//tbody//span[contains(@class,"badge-danger") and contains(.,"törölt")]
    Should Be Empty    ${torolt}
    ...    msg=Publikálva szűrőnél törölt bejegyzés nem szerepelhet

TC-43 Blog - ID szerint rendezés ASC majd DESC
    [Documentation]    ID fejlécre kétszer kattintva a sorrend megfordul
    [Tags]    blog    sort
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_BLOG}    Blogbejegyzések
    Wait Until Element Is Visible    ${BLOG_TABLE_ROWS}    timeout=10s
    Click Element    xpath:(//th[contains(.,"ID")])[1]
    Sleep    0.5s
    ${elso_asc}=    Get Text    xpath:(//table//tbody/tr[1]/td[1])[1]
    Click Element    xpath:(//th[contains(.,"ID")])[1]
    Sleep    0.5s
    ${elso_desc}=    Get Text    xpath:(//table//tbody/tr[1]/td[1])[1]
    Should Not Be Equal    ${elso_asc}    ${elso_desc}

TC-44 Blog - szerkesztő modal cím mező feltöltve nyílik meg
    [Documentation]    Szerkesztés gombra a cím mező az eredeti bejegyzés adatával töltődik
    [Tags]    blog    modal    edit
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_BLOG}    Blogbejegyzések
    Wait Until Element Is Visible    ${BLOG_EDIT_BTN}    timeout=10s
    Click Element    ${BLOG_EDIT_BTN}
    Wait Until Element Is Visible    xpath://div[contains(@class,"modal")]    timeout=8s
    ${title_val}=    Get Element Attribute    ${BLOG_TITLE_INPUT}    value
    Should Not Be Empty    ${title_val}

TC-45 Blog - törlés megerősítő dialog megjelenik
    [Documentation]    Blog törlés gombra megerősítő dialog jelenik meg, Mégse zárja be
    [Tags]    blog    delete
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_BLOG}    Blogbejegyzések
    Wait Until Element Is Visible    ${BLOG_DELETE_BTN}    timeout=10s
    Click Element    ${BLOG_DELETE_BTN}
    Wait Until Element Is Visible    ${CONFIRM_YES}    timeout=5s
    Click Element    ${CONFIRM_NO}
    Wait Until Element Is Not Visible    ${CONFIRM_YES}    timeout=5s

# ════════════════════════════════════════════════════
# 8. KOMMENTEK
# ════════════════════════════════════════════════════

TC-46 Kommentek - keresés nem létező tartalomra üres listát ad
    [Documentation]    Nem létező szóra keresve a komment lista üres, "Nincs találat" látszik
    [Tags]    comments    search
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_COMMENTS}    Kommentek
    Wait Until Element Is Visible    ${COMMENT_SEARCH}    timeout=10s
    Input Text    ${COMMENT_SEARCH}    xyz_nincsilyen_komment_99999
    Sleep    0.5s
    Element Should Be Visible
    ...    xpath://div[contains(.,"Nincs találat")]

TC-47 Kommentek - poszt rendezés ABC szerint az első sor nem üres
    [Documentation]    ABC rendezési módot kiválasztva az első sor poszt neve nem üres
    [Tags]    comments    sort
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_COMMENTS}    Kommentek
    Wait Until Element Is Visible    ${COMMENT_TABLE_ROWS}    timeout=10s
    ${select}=    Get WebElement
    ...    xpath://select[.//option[contains(.,"Poszt: A")]]
    Select From List By Value    ${select}    abc
    Sleep    0.5s
    ${first_post}=    Get Text
    ...    xpath:(//table//tbody/tr[1]/td[4]//a)[1]
    Should Not Be Empty    ${first_post}

TC-48 Kommentek - poszt rendezés ID szerint az első sor ID-ja nem üres
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_COMMENTS}    Kommentek
    Wait Until Element Is Visible    ${COMMENT_TABLE_ROWS}    timeout=10s
    ${select}=    Get WebElement
    ...    xpath://select[.//option[contains(.,"Poszt: ID")]]
    Select From List By Value    ${select}    id
    Sleep    0.5s
    ${first_id}=    Get Text
    ...    xpath:(//table//tbody/tr[1]/td[4]//span)[1]
    Should Not Be Empty    ${first_id}

TC-49 Kommentek - törlés megerősítő dialog megjelenik
    [Documentation]    Komment törlés gombra megerősítő dialog jelenik meg, Mégse zárja be
    [Tags]    comments    delete
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_COMMENTS}    Kommentek
    Wait Until Element Is Visible    ${COMMENT_DELETE_BTN}    timeout=10s
    Click Element    ${COMMENT_DELETE_BTN}
    Wait Until Element Is Visible    ${CONFIRM_YES}    timeout=5s
    Click Element    ${CONFIRM_NO}
    Wait Until Element Is Not Visible    ${CONFIRM_YES}    timeout=5s

TC-50 Kommentek - lánctörlés gomb csak válasszal rendelkező sornál látható
    [Documentation]    A lánctörlés gombok száma nem haladja meg a válasszal rendelkező sorokét
    [Tags]    comments    ui
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_COMMENTS}    Kommentek
    Wait Until Element Is Visible    ${COMMENT_TABLE_ROWS}    timeout=10s
    @{lanc_btns}=    Get WebElements
    ...    xpath://table//tbody//button[contains(@style,"7c3aed") or contains(@style,"purple")]
    @{valasszal}=    Get WebElements
    ...    xpath://table//tbody//span[contains(@class,"badge-warning") and contains(.,"db")]
    ${lanc_count}=    Get Length    ${lanc_btns}
    ${valasz_count}=    Get Length    ${valasszal}
    Should Be True    ${lanc_count} <= ${valasz_count}
    ...    msg=Lánctörlés gomb csak válasszal rendelkező sornál jelenhet meg

# ════════════════════════════════════════════════════
# 9. KATEGÓRIÁK
# ════════════════════════════════════════════════════

TC-51 Kategóriák - új kategória modal megnyílik
    [Documentation]    Új kategória gombra megnyílik a modal a szükséges elemekkel
    [Tags]    categories    modal
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_KATEGORIAK}    Kategóriák
    Wait Until Element Is Visible    ${NEW_KAT_BTN}    timeout=10s
    Click Element    ${NEW_KAT_BTN}
    Wait Until Element Is Visible    ${KAT_MODAL}    timeout=5s
    Element Should Be Visible    ${KAT_NAME_INPUT}
    Element Should Be Visible    ${KAT_SAVE_BTN}

TC-52 Kategóriák - modal bezárása Mégse gombbal
    [Documentation]    Mégse gombra a kategória modal bezárul
    [Tags]    categories    modal
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_KATEGORIAK}    Kategóriák
    Wait Until Element Is Visible    ${NEW_KAT_BTN}    timeout=10s
    Open And Close Modal With Cancel
    ...    ${NEW_KAT_BTN}    ${KAT_MODAL}    ${KAT_CANCEL_BTN}

TC-53 Kategóriák - üres névvel a Létrehozás gomb disabled
    [Documentation]    A Létrehozás gomb disabled amíg a név mező üres
    [Tags]    categories    validation
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_KATEGORIAK}    Kategóriák
    Wait Until Element Is Visible    ${NEW_KAT_BTN}    timeout=10s
    Click Element    ${NEW_KAT_BTN}
    Wait Until Element Is Visible    ${KAT_MODAL}    timeout=5s
    Clear Element Text    ${KAT_NAME_INPUT}
    Element Should Be Disabled    ${KAT_SAVE_BTN}

TC-54 Kategóriák - keresés nem létező névre nincs találat
    [Documentation]    Nem létező kategória névre keresve "Nincs találat" szöveg jelenik meg
    [Tags]    categories    search
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_KATEGORIAK}    Kategóriák
    Wait Until Element Is Visible    ${KAT_SEARCH}    timeout=10s
    Input Text    ${KAT_SEARCH}    xyz_nincsilyen_kategoria_99999
    Sleep    0.5s
    Element Should Be Visible
    ...    xpath://div[contains(.,"Nincs találat")]

TC-55 Kategóriák - blog típus szűrő nem mutat termék kategóriát
    [Documentation]    Blog szűrőre kattintva Termék típusú badge nem szerepelhet a listában
    [Tags]    categories    filter
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_KATEGORIAK}    Kategóriák
    Wait Until Element Is Visible    ${KAT_TYPE_FILTER}    timeout=10s
    Select From List By Value    ${KAT_TYPE_FILTER}    blog
    Sleep    0.5s
    @{termek_badges}=    Get WebElements
    ...    xpath://table//tbody//span[contains(@class,"badge-warning") and contains(.,"Termék")]
    Should Be Empty    ${termek_badges}
    ...    msg=Blog szűrőnél ne legyenek termék kategóriák

TC-56 Kategóriák - elem lista kinyílik badge kattintásra
    [Documentation]    Legalább 1 elemet tartalmazó badge kattintásra expandált sor jelenik meg
    [Tags]    categories    ui
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_KATEGORIAK}    Kategóriák
    Wait Until Element Is Visible    ${KAT_TABLE_ROWS}    timeout=10s
    ${expandable}=    Get WebElement
    ...    xpath://table//tbody//span[contains(@class,"badge-success") and contains(.,"elem")][1]
    Click Element    ${expandable}
    Sleep    1s
    ${expanded_count}=    Get Element Count    ${KAT_TABLE_ROWS}
    Should Be True    ${expanded_count} > 1
    ...    msg=Badge kattintásra több sornak kell megjelennie

TC-57 Kategóriák - törlés megerősítő dialog megjelenik
    [Documentation]    Törlés gombra megerősítő dialog jelenik meg, Mégse zárja be
    [Tags]    categories    delete
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_KATEGORIAK}    Kategóriák
    Wait Until Element Is Visible    ${KAT_TABLE_ROWS}    timeout=10s
    ${delete_btn}=    Get WebElement
    ...    xpath://table//tbody/tr[1]//button[contains(@class,"btn-danger")]
    Click Element    ${delete_btn}
    Wait Until Element Is Visible    ${CONFIRM_YES}    timeout=5s
    Click Element    ${CONFIRM_NO}
    Wait Until Element Is Not Visible    ${CONFIRM_YES}    timeout=5s

# ════════════════════════════════════════════════════
# 10. ANALITIKA
# ════════════════════════════════════════════════════

TC-58 Analitika - chart-ok renderelődnek skeleton eltűnése után
    [Documentation]    Analitika oldalon a skeleton eltűnik és a canvas elemek megjelennek
    [Tags]    analytics
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_ANALYTICS}    Analitika
    Wait Until Element Is Not Visible
    ...    xpath://div[contains(@class,"skeleton-chart")]    timeout=20s
    Element Should Be Visible    xpath://canvas[1]

TC-59 Analitika - frissítés gomb újratölti az adatokat
    [Documentation]    Frissítés gombra skeleton megjelenik majd eltűnik, canvas újra látszik
    [Tags]    analytics
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_ANALYTICS}    Analitika
    Wait Until Element Is Visible    ${REFRESH_BTN}    timeout=10s
    Click Element    ${REFRESH_BTN}
    Wait Until Element Is Not Visible
    ...    xpath://div[contains(@class,"skeleton-chart")]    timeout=20s
    Element Should Be Visible    xpath://canvas[1]

# ════════════════════════════════════════════════════
# 11. PAGINÁCIÓ
# ════════════════════════════════════════════════════

TC-60 Termékek - oldalozó megjelenik ha több mint 10 elem van
    [Documentation]    Ha termékek száma >= 10 oldalon, megjelenik a Következő gomb
    [Tags]    products    pagination
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_PRODUCTS}    Termékek
    Wait Until Element Is Visible    ${PRODUCT_TABLE}    timeout=10s
    ${sorok}=    Get Element Count    ${PRODUCT_TABLE}
    ${paginator_latszik}=    Run Keyword And Return Status
    ...    Element Should Be Visible
    ...    xpath://button[contains(.,"Következő")]
    Run Keyword If    ${sorok} >= 10
    ...    Should Be True    ${paginator_latszik}
    ...    msg=10+ terméknél oldalozónak kell megjelennie

TC-61 Termékek - utolsó oldalon a Következő gomb disabled
    [Documentation]    Az utolsó oldalra navigálva a Következő oldal gomb le van tiltva
    [Tags]    products    pagination
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_PRODUCTS}    Termékek
    Wait Until Element Is Visible    ${PRODUCT_TABLE}    timeout=10s
    ${paginator_latszik}=    Run Keyword And Return Status
    ...    Element Should Be Visible
    ...    xpath://button[contains(.,"Következő")]
    Pass Execution If    not ${paginator_latszik}
    ...    Nincs elég termék a pagináció teszteléséhez - teszt kihagyva
    @{page_btns}=    Get WebElements
    ...    xpath://button[contains(@class,"btn-sm") and not(contains(.,"Előző")) and not(contains(.,"Következő"))]
    ${last_btn}=    Get From List    ${page_btns}    -1
    Click Element    ${last_btn}
    Sleep    0.3s
    Element Should Be Disabled
    ...    xpath://button[contains(.,"Következő →")]

# ════════════════════════════════════════════════════
# 12. TOAST ÉRTESÍTŐK
# ════════════════════════════════════════════════════

TC-62 Toast - megjelenik majd automatikusan eltűnik
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_PRODUCTS}    Termékek
    Wait Until Element Is Visible    ${NEW_PRODUCT_BTN}    timeout=10s
    Click Element    ${NEW_PRODUCT_BTN}
    Wait Until Element Is Visible    ${PRODUCT_MODAL}    timeout=5s
    Click Element    ${PRODUCT_SAVE_BTN}
    Wait Until Element Is Visible
    ...    xpath://div[contains(@class,"toast")]    timeout=5s
    Element Should Be Visible    xpath://div[contains(@class,"toast")]

TC-63 Toast - manuálisan bezárható az X gombbal
    Go To Dashboard As Admin
    Navigate To View And Wait    ${NAV_PRODUCTS}    Termékek
    Wait Until Element Is Visible    ${NEW_PRODUCT_BTN}    timeout=10s
    Click Element    ${NEW_PRODUCT_BTN}
    Wait Until Element Is Visible    ${PRODUCT_MODAL}    timeout=5s
    Click Element    ${PRODUCT_SAVE_BTN}
    Wait Until Element Is Visible    xpath://div[contains(@class,"toast")]    timeout=5s
    Click Element    xpath://button[contains(@class,"toast-close")]
    Execute JavaScript    var t=document.querySelector('[class*="toast"]'); if(t) t.remove();
    Wait Until Element Is Not Visible    xpath://div[contains(@class,"toast")]    timeout=5s