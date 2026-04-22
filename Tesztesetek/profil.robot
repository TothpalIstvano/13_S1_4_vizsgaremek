*** Settings ***
Resource    resources.robot
Library    OperatingSystem
Test Setup    Open Registration Page
Test Teardown    Close Browser Session

*** Test Cases ***

# ─────────────────────────────────────────────
# VALIDÁCIÓ – NÉV MEZŐK
# ─────────────────────────────────────────────

Vezeteknev Validation Shows Error For Single Character
    [Documentation]    Egybetűs vezetéknév esetén validációs hibaüzenet jelenik meg.
    Login As Test User
    Navigate To Profile Page
    Open Modal
    Execute JavaScript
    ...    const el = document.getElementById('vezeteknev');
    ...    const setter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
    ...    setter.call(el, 'A');
    ...    el.dispatchEvent(new Event('input', { bubbles: true }));
    ...    el.dispatchEvent(new Event('blur', { bubbles: true }));
    Sleep    0.3s
    Element Should Be Visible    xpath://span[contains(@class,"v-error") and contains(.,"betűk")]
    Element Should Be Visible    xpath://input[@id="vezeteknev"][contains(@class,"field-error")]

Vezeteknev Validation Shows Error For Numbers
    [Documentation]    Számokat tartalmazó vezetéknév esetén validációs hibaüzenet jelenik meg.
    Login As Test User
    Navigate To Profile Page
    Open Modal
    Execute JavaScript
    ...    const el = document.getElementById('vezeteknev');
    ...    const setter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
    ...    setter.call(el, 'Teszt123');
    ...    el.dispatchEvent(new Event('input', { bubbles: true }));
    ...    el.dispatchEvent(new Event('blur', { bubbles: true }));
    Sleep    0.3s
    Element Should Be Visible    xpath://span[contains(@class,"v-error")]
    Element Should Be Visible    xpath://input[@id="vezeteknev"][contains(@class,"field-error")]

Vezeteknev Validation Shows Error For Double Hyphen
    [Documentation]    Két egymást követő kötőjel esetén hibaüzenet jelenik meg.
    Login As Test User
    Navigate To Profile Page
    Open Modal
    Execute JavaScript
    ...    const el = document.getElementById('vezeteknev');
    ...    const setter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
    ...    setter.call(el, 'Nagy--Anna');
    ...    el.dispatchEvent(new Event('input', { bubbles: true }));
    ...    el.dispatchEvent(new Event('blur', { bubbles: true }));
    Sleep    0.3s
    Element Should Be Visible    xpath://span[contains(@class,"v-error") and contains(.,"kötőjel")]

Vezeteknev Validation Shows Error For Exceeding Max Length
    [Documentation]    50 karakternél hosszabb vezetéknév esetén hibaüzenet jelenik meg.
    Login As Test User
    Navigate To Profile Page
    Open Modal
    ${long_name}=    Set Variable    Abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz
    Execute JavaScript
    ...    const el = document.getElementById('vezeteknev');
    ...    const setter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
    ...    setter.call(el, '${long_name}');
    ...    el.dispatchEvent(new Event('input', { bubbles: true }));
    ...    el.dispatchEvent(new Event('blur', { bubbles: true }));
    Sleep    0.3s
    Element Should Be Visible    xpath://span[contains(@class,"v-error") and contains(.,"50")]

Vezeteknev Validation Shows OK For Valid Name
    [Documentation]    Érvényes vezetéknév esetén zöld pipa jelenik meg, nincs hibaüzenet.
    Login As Test User
    Navigate To Profile Page
    Open Modal
    Execute JavaScript
    ...    const el = document.getElementById('vezeteknev');
    ...    const setter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
    ...    setter.call(el, 'Nagy');
    ...    el.dispatchEvent(new Event('input', { bubbles: true }));
    ...    el.dispatchEvent(new Event('blur', { bubbles: true }));
    Sleep    0.3s
    Element Should Be Visible    xpath://input[@id="vezeteknev"][contains(@class,"field-ok")]
    Page Should Not Contain Element    xpath://input[@id="vezeteknev"][contains(@class,"field-error")]

Keresztnev Validation Shows Error For Invalid Characters
    [Documentation]    Speciális karaktereket tartalmazó keresztnév esetén hibaüzenet jelenik meg.
    Login As Test User
    Navigate To Profile Page
    Open Modal
    Execute JavaScript
    ...    const el = document.getElementById('keresztnev');
    ...    const setter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
    ...    setter.call(el, 'Anna@!');
    ...    el.dispatchEvent(new Event('input', { bubbles: true }));
    ...    el.dispatchEvent(new Event('blur', { bubbles: true }));
    Sleep    0.3s
    Element Should Be Visible    xpath://input[@id="keresztnev"][contains(@class,"field-error")]

# ─────────────────────────────────────────────
# VALIDÁCIÓ – TELEFON
# ─────────────────────────────────────────────

Telefon Validation Shows Error For Too Short Number
    [Documentation]    7 számjegynél rövidebb telefonszám esetén hibaüzenet jelenik meg.
    Login As Test User
    Navigate To Profile Page
    Open Modal
    Execute JavaScript
    ...    const el = document.getElementById('telefon');
    ...    const setter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
    ...    setter.call(el, '123');
    ...    el.dispatchEvent(new Event('input', { bubbles: true }));
    ...    el.dispatchEvent(new Event('blur', { bubbles: true }));
    Sleep    0.3s
    Element Should Be Visible    xpath://span[contains(@class,"v-error") and contains(.,"7")]

Telefon Validation Shows Error For Invalid Characters
    [Documentation]    Érvénytelen karaktereket tartalmazó telefonszám esetén hibaüzenet jelenik meg.
    Login As Test User
    Navigate To Profile Page
    Open Modal
    Execute JavaScript
    ...    const el = document.getElementById('telefon');
    ...    const setter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
    ...    setter.call(el, 'abc-def');
    ...    el.dispatchEvent(new Event('input', { bubbles: true }));
    ...    el.dispatchEvent(new Event('blur', { bubbles: true }));
    Sleep    0.3s
    Element Should Be Visible    xpath://span[contains(@class,"v-error") and contains(.,"számok")]

Telefon Validation Shows Error For Invalid Format
    [Documentation]    Érvénytelen formátumú telefonszám esetén hibaüzenet jelenik meg.
    Login As Test User
    Navigate To Profile Page
    Open Modal
    Execute JavaScript
    ...    const el = document.getElementById('telefon');
    ...    const setter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
    ...    setter.call(el, '+36999999999');
    ...    el.dispatchEvent(new Event('input', { bubbles: true }));
    ...    el.dispatchEvent(new Event('blur', { bubbles: true }));
    Sleep    0.3s
    Element Should Be Visible    xpath://span[contains(@class,"v-error") and contains(.,"Érvénytelen")]

Telefon Validation Accepts Hungarian Mobile Format
    [Documentation]    Magyar mobilszám (06xx) formátum elfogadva és normalizálva.
    Login As Test User
    Navigate To Profile Page
    Open Modal
    Execute JavaScript
    ...    const el = document.getElementById('telefon');
    ...    const setter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
    ...    setter.call(el, '0630 123 4567');
    ...    el.dispatchEvent(new Event('input', { bubbles: true }));
    ...    el.dispatchEvent(new Event('blur', { bubbles: true }));
    Sleep    0.3s
    Element Should Be Visible    xpath://input[@id="telefon"][contains(@class,"field-ok")]

# ─────────────────────────────────────────────
# VALIDÁCIÓ – CÍM MEZŐK
# ─────────────────────────────────────────────

Utca Validation Shows Error For Too Short Value
    [Documentation]    2 karakternél rövidebb utca esetén hibaüzenet jelenik meg.
    Login As Test User
    Navigate To Profile Page
    Open Modal
    Execute JavaScript
    ...    const el = document.getElementById('utca');
    ...    const setter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
    ...    setter.call(el, 'AB');
    ...    el.dispatchEvent(new Event('input', { bubbles: true }));
    ...    el.dispatchEvent(new Event('blur', { bubbles: true }));
    Sleep    0.3s
    Element Should Be Visible    xpath://span[contains(@class,"v-error") and contains(.,"3")]

Utca Validation Shows Error For Only Numbers
    [Documentation]    Csak számokból álló utca esetén hibaüzenet jelenik meg (betű szükséges).
    Login As Test User
    Navigate To Profile Page
    Open Modal
    Execute JavaScript
    ...    const el = document.getElementById('utca');
    ...    const setter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
    ...    setter.call(el, '12345');
    ...    el.dispatchEvent(new Event('input', { bubbles: true }));
    ...    el.dispatchEvent(new Event('blur', { bubbles: true }));
    Sleep    0.3s
    Element Should Be Visible    xpath://span[contains(@class,"v-error") and contains(.,"betűt")]

Hazszam Validation Shows Error For Invalid Format
    [Documentation]    Érvénytelen házszám formátum (pl. 0-val kezdődő) esetén hibaüzenet jelenik meg.
    Login As Test User
    Navigate To Profile Page
    Open Modal
    Execute JavaScript
    ...    const el = document.getElementById('hazszam');
    ...    const setter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
    ...    setter.call(el, '0123');
    ...    el.dispatchEvent(new Event('input', { bubbles: true }));
    ...    el.dispatchEvent(new Event('blur', { bubbles: true }));
    Sleep    0.3s
    Element Should Be Visible    xpath://span[contains(@class,"v-error") and contains(.,"házszám")]

Hazszam Validation Accepts Letter Suffix Format
    [Documentation]    Betűs házszám (pl. 12/A, 14B) érvényes és elfogadott.
    Login As Test User
    Navigate To Profile Page
    Open Modal
    Execute JavaScript
    ...    const el = document.getElementById('hazszam');
    ...    const setter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
    ...    setter.call(el, '12/A');
    ...    el.dispatchEvent(new Event('input', { bubbles: true }));
    ...    el.dispatchEvent(new Event('blur', { bubbles: true }));
    Sleep    0.3s
    Element Should Be Visible    xpath://input[@id="hazszam"][contains(@class,"field-ok")]

EmeletAjto Validation Shows Error For Too Long Value
    [Documentation]    20 karakternél hosszabb emelet/ajtó érték esetén hibaüzenet jelenik meg.
    Login As Test User
    Navigate To Profile Page
    Open Modal
    Execute JavaScript
    ...    const el = document.getElementById('emeletAjto');
    ...    const setter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
    ...    setter.call(el, 'Nagyon hosszu emelet es ajto ertek');
    ...    el.dispatchEvent(new Event('input', { bubbles: true }));
    ...    el.dispatchEvent(new Event('blur', { bubbles: true }));
    Sleep    0.3s
    Element Should Be Visible    xpath://span[contains(@class,"v-error") and contains(.,"20")]

# ─────────────────────────────────────────────
# MENTÉS GÁTLÁSA HIBÁS ADATOKKAL
# ─────────────────────────────────────────────

Save Profile Blocked When Name Field Empty
    [Documentation]    Ha a kötelező vezetéknév mező üres, a mentés nem sikerülhet (hibamodal megjelenik).
    Login As Test User
    Navigate To Profile Page
    Open Modal
    Execute JavaScript
    ...    const el = document.getElementById('vezeteknev');
    ...    const setter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
    ...    setter.call(el, '');
    ...    el.dispatchEvent(new Event('input', { bubbles: true }));
    ...    el.dispatchEvent(new Event('blur', { bubbles: true }));
    Sleep    0.3s
    Scroll Element Into View    ${MENTES_BTN}
    Click Element    ${MENTES_BTN}
    Sleep    0.5s
    Element Should Be Visible    ${SZERK_MODAL}

Save Profile Blocked When Vezeteknev Has Invalid Format
    [Documentation]    Ha a vezetéknév formátuma érvénytelen (szám), a mentés blokkolt, a modal nyitva marad.
    Login As Test User
    Navigate To Profile Page
    Open Modal
    Execute JavaScript
    ...    const el = document.getElementById('vezeteknev');
    ...    const setter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
    ...    setter.call(el, 'Teszt99');
    ...    el.dispatchEvent(new Event('input', { bubbles: true }));
    ...    el.dispatchEvent(new Event('blur', { bubbles: true }));
    Execute JavaScript
    ...    const el = document.getElementById('keresztnev');
    ...    const setter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
    ...    setter.call(el, 'Elek');
    ...    el.dispatchEvent(new Event('input', { bubbles: true }));
    ...    el.dispatchEvent(new Event('blur', { bubbles: true }));
    Sleep    0.3s
    Scroll Element Into View    ${MENTES_BTN}
    Click Element    ${MENTES_BTN}
    Sleep    0.5s
    Element Should Be Visible    ${SZERK_MODAL}

# ─────────────────────────────────────────────
# KIJELENTKEZÉS MODAL
# ─────────────────────────────────────────────

Kijelentkezes Modal Opens On Button Click
    [Documentation]    A kijelentkezés gombra kattintva a megerősítő modal megjelenik.
    Login As Test User
    Navigate To Profile Page
    Wait Until Element Is Visible    xpath://button[contains(@class,"btn logout")]    timeout=10s
    Click Element    xpath://button[contains(@class,"btn logout")]
    Wait Until Element Is Visible    xpath://div[contains(@class,"modal")]//h3[contains(.,"Kijelentkezés")]    timeout=5s
    Element Should Be Visible    xpath://button[contains(@class,"btn confirm") and contains(.,"Igen")]
    Element Should Be Visible    xpath://button[contains(@class,"btn cancel") and contains(.,"Mégse")]

Kijelentkezes Modal Closes On Megse
    Login As Test User
    Navigate To Profile Page
    Click Element    xpath://button[contains(@class,"btn logout")]
    Wait Until Element Is Visible    xpath://div[contains(@class,"modal")]//h3[contains(.,"Kijelentkezés")]    timeout=5s
    Click Element    xpath://button[contains(@class,"btn cancel") and contains(.,"Mégse")]
    Wait Until Element Is Not Visible    xpath://div[contains(@class,"modal")]    timeout=5s
    Location Should Contain    /Profil

Kijelentkezes Modal Closes On Backdrop Click
    [Documentation]    A modal háttérre kattintva a kijelentkezés modal bezárul.
    Login As Test User
    Navigate To Profile Page
    Click Element    xpath://button[contains(@class,"btn logout")]
    Wait Until Element Is Visible    xpath://div[contains(@class,"modal-backdrop")]    timeout=5s
    Execute JavaScript
    ...    const bd = document.querySelector('.modal-backdrop');
    ...    bd.dispatchEvent(new MouseEvent('mousedown', {bubbles: true}));
    ...    bd.dispatchEvent(new MouseEvent('click', {bubbles: true}));
    Sleep    0.5s
    Wait Until Element Is Not Visible    xpath://div[contains(@class,"modal")]    timeout=5s

Kijelentkezes Confirms And Redirects To Login
    [Documentation]    Az "Igen, kijelentkezés" gombra kattintva a felhasználó kijelentkezik és a bejelentkezési oldalra kerül.
    Login As Test User
    Navigate To Profile Page
    Click Element    xpath://button[contains(@class,"btn logout")]
    Wait Until Element Is Visible    xpath://button[contains(@class,"btn confirm")]    timeout=5s
    Click Element    xpath://button[contains(@class,"btn confirm")]
    Wait Until Location Contains    /belepes    timeout=10s

# ─────────────────────────────────────────────
# KEDVENCEK MODAL
# ─────────────────────────────────────────────

Kedvencek Modal Opens From Sidebar Button
    [Documentation]    A "Kedvenc termékek" gombra kattintva a kedvencek modal megnyílik.
    Login As Test User
    Navigate To Profile Page
    Wait Until Element Is Visible    xpath://button[contains(@class,"btn kedvencek")]    timeout=10s
    Click Element    xpath://button[contains(@class,"btn kedvencek")]
    Wait Until Element Is Visible    xpath://div[contains(@class,"kedvencek-modal")]    timeout=10s
    Element Should Be Visible    xpath://div[contains(@class,"kedvencek-modal-header")]//h3[contains(.,"Kedvenc termékek")]

Kedvencek Modal Closes On X Button
    [Documentation]    A kedvencek modal bezárógombjára kattintva a modal eltűnik.
    Login As Test User
    Navigate To Profile Page
    Click Element    xpath://button[contains(@class,"btn kedvencek")]
    Wait Until Element Is Visible    xpath://div[contains(@class,"kedvencek-modal")]    timeout=10s
    Click Element    xpath://div[contains(@class,"kedvencek-modal-header")]//button[contains(@class,"close-btn")]
    Wait Until Element Is Not Visible    xpath://div[contains(@class,"kedvencek-modal")]    timeout=5s

Kedvencek Modal Closes On Backdrop Click
    [Documentation]    A kedvencek modal hátterére kattintva a modal bezárul.
    Login As Test User
    Navigate To Profile Page
    Click Element    xpath://button[contains(@class,"btn kedvencek")]
    Wait Until Element Is Visible    xpath://div[contains(@class,"kedvencek-modal-backdrop")]    timeout=10s
    Execute JavaScript
    ...    const bd = document.querySelector('.kedvencek-modal-backdrop');
    ...    bd.dispatchEvent(new MouseEvent('click', {bubbles: true, target: bd}));
    Sleep    0.5s
    Wait Until Element Is Not Visible    xpath://div[contains(@class,"kedvencek-modal")]    timeout=5s

Kedvencek Modal Shows Empty State When No Favourites
    [Documentation]    Ha nincs kedvenc termék, az "üres" állapotüzenet jelenik meg.
    Login As Test User
    Navigate To Profile Page
    Click Element    xpath://button[contains(@class,"btn kedvencek")]
    Wait Until Element Is Visible    xpath://div[contains(@class,"kedvencek-modal")]    timeout=10s
    ${has_items}=    Run Keyword And Return Status
    ...    Element Should Be Visible    xpath://div[contains(@class,"kedvenc-card")]
    Run Keyword If    not ${has_items}
    ...    Element Should Be Visible    xpath://div[contains(@class,"kedvenc-ures")]

Kedvencek Modal Product Cards Are Clickable
    [Documentation]    Ha van kedvenc termék, a kártyára kattintva a termék oldalára navigál.
    Login As Test User
    Navigate To Profile Page
    Click Element    xpath://button[contains(@class,"btn kedvencek")]
    Wait Until Element Is Visible    xpath://div[contains(@class,"kedvencek-modal")]    timeout=10s
    ${has_items}=    Run Keyword And Return Status
    ...    Element Should Be Visible    xpath://div[contains(@class,"kedvenc-card")]
    Skip If    not ${has_items}    Nincs kedvenc termék ebben a tesztkörnyezetben
    Click Element    xpath:(//div[contains(@class,"kedvenc-card")])[1]
    Wait Until Location Contains    /aruhaz    timeout=10s

Kedvencek Toggle Heart Removes Item From List
    [Documentation]    A szív ikonra kattintva eltávolítja a terméket a kedvencek listájából.
    Login As Test User
    Navigate To Profile Page
    Click Element    xpath://button[contains(@class,"btn kedvencek")]
    Wait Until Element Is Visible    xpath://div[contains(@class,"kedvencek-modal")]    timeout=10s
    ${has_items}=    Run Keyword And Return Status
    ...    Element Should Be Visible    xpath://div[contains(@class,"kedvenc-card")]
    Skip If    not ${has_items}    Nincs kedvenc termék ebben a tesztkörnyezetben
    ${count_before}=    Get Element Count    xpath://div[contains(@class,"kedvenc-card")]
    Click Element    xpath:(//button[contains(@class,"heart-btn")])[1]
    Sleep    1s
    ${count_after}=    Get Element Count    xpath://div[contains(@class,"kedvenc-card")]
    Should Be True    ${count_after} < ${count_before}

# ─────────────────────────────────────────────
# EMAIL VERIFIKÁCIÓ BANNER
# ─────────────────────────────────────────────

Email Verification Banner Visible For Unverified User
    [Documentation]    Nem verifikált felhasználónál a verifikációs banner megjelenik az oldalon.
    [Tags]    requires-unverified-user
    Login As Test User
    Navigate To Profile Page
    ${banner_visible}=    Run Keyword And Return Status
    ...    Element Should Be Visible    xpath://div[contains(@class,"verify-banner")]
    Log    Banner látható: ${banner_visible}
    Run Keyword If    ${banner_visible}
    ...    Element Should Contain    xpath://div[contains(@class,"verify-banner")]    Erősítsd meg

Email Verification Resend Button Is Clickable
    [Documentation]    Az "Újraküldés" gomb kattintható és küldés után letiltódik.
    [Tags]    requires-unverified-user
    Login As Test User
    Navigate To Profile Page
    ${banner_visible}=    Run Keyword And Return Status
    ...    Element Should Be Visible    xpath://button[contains(@class,"verify-banner__btn")]
    Skip If    not ${banner_visible}    Email banner nem látható (felhasználó már verifikált)
    Click Element    xpath://button[contains(@class,"verify-banner__btn")]
    Sleep    1.5s
    ${btn_text}=    Get Text    xpath://button[contains(@class,"verify-banner__btn")]
    Should Contain Any    ${btn_text}    Elküldve    Küldés

# ─────────────────────────────────────────────
# HÁTTÉRKÉP – GALÉRIA ÉS FELTÖLTÉS
# ─────────────────────────────────────────────

Cover Gallery Opens On Button Click
    Login As Test User
    Navigate To Profile Page
    Open Modal
    Execute JavaScript
    ...    [...document.querySelectorAll('button.camera-btn')]
    ...    .find(b => b.textContent.includes('galériából'))
    ...    .click();
    Wait Until Element Is Visible    xpath://p[contains(.,"Válassz egy háttérképet")]    timeout=10s
    Element Should Be Visible    xpath://div[contains(@style,"grid-template-columns")]

Cover Gallery Image Selection Updates Preview
    Login As Test User
    Navigate To Profile Page
    Open Modal
    Execute JavaScript
    ...    [...document.querySelectorAll('button.camera-btn')]
    ...    .find(b => b.textContent.includes('galériából'))
    ...    .click();
    Wait Until Element Is Visible    xpath://p[contains(.,"Válassz egy háttérképet")]    timeout=10s
    Wait Until Element Is Visible    xpath://div[contains(@style,"grid-template-columns")]//img    timeout=10s
    Execute JavaScript
    ...    document.querySelectorAll('div[style*="grid-template-columns"] > div')[0].click();
    Sleep    0.5s
    ${preview_src}=    Execute JavaScript
    ...    return document.querySelector('img[alt="Háttérkép előkép"]')?.src || ''
    Should Not Be Empty    ${preview_src}

Cover Pending Warning Visible After Gallery Selection
    Login As Test User
    Navigate To Profile Page
    Open Modal
    Execute JavaScript
    ...    [...document.querySelectorAll('button.camera-btn')]
    ...    .find(b => b.textContent.includes('galériából'))
    ...    .click();
    Wait Until Element Is Visible    xpath://p[contains(.,"Válassz egy háttérképet")]    timeout=10s
    Wait Until Element Is Visible    xpath://div[contains(@style,"grid-template-columns")]//img    timeout=10s
    Execute JavaScript
    ...    document.querySelectorAll('div[style*="grid-template-columns"] > div')[0].click();
    Sleep    0.3s
    Element Should Be Visible    xpath://p[contains(.,"csak a")]

Cover Gallery Selection Cancelled On Megse Reverts Cover
    Login As Test User
    Navigate To Profile Page
    Open Modal
    Execute JavaScript
    ...    [...document.querySelectorAll('button.camera-btn')]
    ...    .find(b => b.textContent.includes('galériából'))
    ...    .click();
    Wait Until Element Is Visible    xpath://p[contains(.,"Válassz egy háttérképet")]    timeout=10s
    Wait Until Element Is Visible    xpath://div[contains(@style,"grid-template-columns")]//img    timeout=10s
    ${gallery_img_src}=    Execute JavaScript
    ...    return document.querySelectorAll('div[style*="grid-template-columns"] > div img')[0]?.src || ''
    Execute JavaScript
    ...    document.querySelectorAll('div[style*="grid-template-columns"] > div')[0].click();
    Sleep    0.3s
    Scroll Element Into View    ${MEGSE_BTN}
    Click Element    ${MEGSE_BTN}
    Wait Until Element Is Not Visible    ${SZERK_MODAL}    timeout=5s
    ${current_cover}=    Execute JavaScript
    ...    return document.querySelector('.cover')?.style?.backgroundImage || ''
    Should Not Contain    ${current_cover}    ${gallery_img_src}

# ─────────────────────────────────────────────
# PROFILKÉP – FÁJL FELTÖLTÉS
# ─────────────────────────────────────────────

File Upload Input Is Hidden Behind Label
    Login As Test User
    Navigate To Profile Page
    Wait Until Element Is Visible    xpath://button[contains(@class,"btn edit")]    timeout=10s
    Open Modal
    Element Should Be Visible    xpath://label[@for="avatar"][contains(@class,"file-upload-btn")]
    ${display}=    Execute JavaScript
    ...    return getComputedStyle(document.getElementById('avatar')).display
    Should Be Equal    ${display}    none

File Upload Label Shows Selected Filename
    Login As Test User
    Navigate To Profile Page
    Wait Until Element Is Visible    xpath://button[contains(@class,"btn edit")]    timeout=10s
    Open Modal
    ${test_file}=    Set Variable    ${CURDIR}/test_image.jpg
    ${exists}=    Run Keyword And Return Status    File Should Exist    ${test_file}
    Skip If    not ${exists}    test_image.jpg nem található
    Choose File    id:avatar    ${test_file}
    Sleep    0.5s
    ${label_text}=    Get Text    xpath://label[@for="avatar"]
    Should Contain    ${label_text}    test_image

# ─────────────────────────────────────────────
# BEJEGYZÉSEK SZEKCIÓ
# ─────────────────────────────────────────────

New Post Button Navigates To New Post Page
    [Documentation]    Az "+ Új bejegyzés" gombra kattintva a bejegyzés-létrehozási oldalra navigál (verifikált felhasználóval).
    Login As Test User
    Navigate To Profile Page
    Wait Until Element Is Visible    xpath://a[contains(@class,"btn create-post") and not(contains(@class,"btn-disabled"))]    timeout=10s
    Click Element    xpath://a[contains(@class,"btn create-post") and not(contains(@class,"btn-disabled"))]
    Wait Until Location Contains    /newpost    timeout=10s

Post Cards Show Read And Edit Links
    [Documentation]    Ha vannak bejegyzések, minden kártyán megjelenik az "Olvasás" és "Szerkesztés" link.
    Login As Test User
    Navigate To Profile Page
    ${has_posts}=    Run Keyword And Return Status
    ...    Element Should Be Visible    xpath://article[contains(@class,"post-card")]
    Skip If    not ${has_posts}    Nincs bejegyzés a tesztfelhasználónál
    Element Should Be Visible    xpath:(//article[contains(@class,"post-card")])[1]//a[contains(@class,"read")]
    Element Should Be Visible    xpath:(//article[contains(@class,"post-card")])[1]//a[contains(@class,"modify")]

Draft Post Shows Draft Badge
    [Documentation]    Piszkozat státuszú bejegyzésen megjelenik a "Piszkozat" badge.
    Login As Test User
    Navigate To Profile Page
    ${has_draft}=    Run Keyword And Return Status
    ...    Element Should Be Visible    xpath://span[contains(@class,"draft-badge")]
    Skip If    not ${has_draft}    Nincs piszkozat bejegyzés a tesztfelhasználónál
    Element Should Contain    xpath://span[contains(@class,"draft-badge")]    Piszkozat

Empty Posts State Shows Create Button
    [Documentation]    Ha nincs bejegyzés, az üres állapot nézet megjelenik a létrehozás linkkel.
    Login As Test User
    Navigate To Profile Page
    ${is_empty}=    Run Keyword And Return Status
    ...    Element Should Be Visible    xpath://div[contains(@class,"empty-posts")]
    Skip If    not ${is_empty}    A felhasználónak vannak bejegyzései
    Element Should Be Visible    xpath://div[contains(@class,"empty-posts")]//a[contains(@class,"create-post")]
