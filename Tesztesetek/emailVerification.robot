*** Settings ***
Library     SeleniumLibrary
Resource    resources.robot

Test Setup       Run Keywords
...              Open Registration Page
Test Teardown    Close Browser Session

*** Variables ***
${BASE_URL}                 http://localhost:5173
${EMAIL_VERIFIED_URL}       http://localhost:5173/email-verified
${EMAIL_ALREADY_URL}        http://localhost:5173/email-already-verified

*** Test Cases ***

# ════════════════════════════════════════════════════
# EMAIL VERIFIED
# ════════════════════════════════════════════════════

TC-EV01 Email megerősítve oldal betöltődik
    [Documentation]    Az /email-verified oldal betöltődik és a kártya látható
    [Tags]    email    verified    smoke
    Go To    ${EMAIL_VERIFIED_URL}
    Wait Until Element Is Visible
    ...    xpath://div[contains(@class,"card--visible")]    timeout=10s
    Element Should Be Visible    xpath://div[contains(@class,"card")]

TC-EV02 Status badge megjelenik
    Go To    ${EMAIL_VERIFIED_URL}
    Wait Until Element Is Visible
    ...    xpath://div[contains(@class,"status-badge")]    timeout=10s
    ${szoveg}=    Execute JavaScript
    ...    return document.querySelector('[class*="status-badge"]').textContent.trim().toLowerCase()
    Should Contain    ${szoveg}    megerősítve

TC-EV03 Főcím szövege helyes
    [Documentation]    Az oldal főcíme "Email cím" és "sikeresen megerősítve" szöveget tartalmaz
    [Tags]    email    verified    content
    Go To    ${EMAIL_VERIFIED_URL}
    Wait Until Element Is Visible    xpath://h1[contains(@class,"title")]    timeout=10s
    Element Should Contain    xpath://h1[contains(@class,"title")]    Email cím
    Element Should Contain    xpath://h1[contains(@class,"title")]    sikeresen megerősítve

TC-EV04 Leíró szöveg megjelenik
    [Documentation]    A megerősítés utáni tájékoztató szöveg látható
    [Tags]    email    verified    content
    Go To    ${EMAIL_VERIFIED_URL}
    Wait Until Element Is Visible    xpath://p[contains(@class,"body-text")]    timeout=10s
    ${szoveg}=    Get Text    xpath://p[contains(@class,"body-text")]
    Should Not Be Empty    ${szoveg}

TC-EV05 SVG animált pipa megjelenik
    Go To    ${EMAIL_VERIFIED_URL}
    Wait Until Element Is Visible
    ...    xpath://div[contains(@class,"card--visible")]    timeout=10s
    ${letezik}=    Execute JavaScript
    ...    return !!document.querySelector('svg.check-svg, .check-svg')
    Should Be True    ${letezik}    msg=A check-svg SVG elem nem található a DOM-ban

TC-EV06 CTA gomb látható ha nincs opener ablak
    [Documentation]    Normál böngészőben megnyitva a "Tovább a bejelentkezéshez" gomb látható
    [Tags]    email    verified    navigation
    Go To    ${EMAIL_VERIFIED_URL}
    Wait Until Element Is Visible
    ...    xpath://a[contains(.,"Tovább a bejelentkezéshez")]    timeout=10s
    Element Should Be Visible
    ...    xpath://a[contains(.,"Tovább a bejelentkezéshez")]

TC-EV07 CTA gomb a profil oldalra navigál
    [Documentation]    A "Tovább a bejelentkezéshez" gombra kattintva a profil oldal tölt be
    [Tags]    email    verified    navigation
    Go To    ${EMAIL_VERIFIED_URL}
    Wait Until Element Is Visible
    ...    xpath://a[contains(.,"Tovább a bejelentkezéshez")]    timeout=10s
    Click Element    xpath://a[contains(.,"Tovább a bejelentkezéshez")]
    Sleep    2s
    Location Should Contain    profil

TC-EV08 Elválasztó vonal megjelenik
    [Documentation]    A kártyán belüli díszítő elválasztó elem látható
    [Tags]    email    verified    layout
    Go To    ${EMAIL_VERIFIED_URL}
    Wait Until Element Is Visible
    ...    xpath://div[contains(@class,"divider")]    timeout=10s
    Element Should Be Visible    xpath://div[contains(@class,"divider")]

TC-EV09 Kártya megjelenik animáció után
    [Documentation]    A kártya kezdetben láthatatlan, majd card--visible class-szal megjelenik
    [Tags]    email    verified    ui
    Go To    ${EMAIL_VERIFIED_URL}
    Wait Until Element Is Visible
    ...    xpath://div[contains(@class,"card--visible")]    timeout=5s
    ${classes}=    Get Element Attribute
    ...    xpath://div[contains(@class,"card")]    class
    Should Contain    ${classes}    card--visible

# ════════════════════════════════════════════════════
# EMAIL ALREADY VERIFIED
# ════════════════════════════════════════════════════

TC-EA01 Email már megerősítve oldal betöltődik
    [Documentation]    Az /email-already-verified oldal betöltődik és a kártya látható
    [Tags]    email    already    smoke
    Go To    ${EMAIL_ALREADY_URL}
    Wait Until Element Is Visible
    ...    xpath://div[contains(@class,"card--visible")]    timeout=10s
    Element Should Be Visible    xpath://div[contains(@class,"card")]

TC-EA02 Status badge megjelenik
    Go To    ${EMAIL_ALREADY_URL}
    Wait Until Element Is Visible
    ...    xpath://div[contains(@class,"status-badge")]    timeout=10s
    ${szoveg}=    Execute JavaScript
    ...    return document.querySelector('[class*="status-badge"]').textContent.trim().toLowerCase()
    Should Contain    ${szoveg}    már megerősítve

TC-EA03 Főcím szövege helyes
    [Documentation]    Az oldal főcíme "Email cím" és "már megerősítve" szöveget tartalmaz
    [Tags]    email    already    content
    Go To    ${EMAIL_ALREADY_URL}
    Wait Until Element Is Visible    xpath://h1[contains(@class,"title")]    timeout=10s
    Element Should Contain    xpath://h1[contains(@class,"title")]    Email cím
    Element Should Contain    xpath://h1[contains(@class,"title")]    már megerősítve

TC-EA04 Leíró szöveg megjelenik
    [Documentation]    A tájékoztató szöveg látható és nem üres
    [Tags]    email    already    content
    Go To    ${EMAIL_ALREADY_URL}
    Wait Until Element Is Visible    xpath://p[contains(@class,"body-text")]    timeout=10s
    ${szoveg}=    Get Text    xpath://p[contains(@class,"body-text")]
    Should Not Be Empty    ${szoveg}
    Should Contain    ${szoveg}    korábban már aktiválásra került

TC-EA05 SVG animált pipa megjelenik
    Go To    ${EMAIL_ALREADY_URL}
    Wait Until Element Is Visible
    ...    xpath://div[contains(@class,"card--visible")]    timeout=10s
    ${letezik}=    Execute JavaScript
    ...    return !!document.querySelector('svg.check-svg, .check-svg')
    Should Be True    ${letezik}    msg=A check-svg SVG elem nem található a DOM-ban

TC-EA06 Bejelentkezés gomb látható
    Go To    ${EMAIL_ALREADY_URL}
    Wait Until Element Is Visible
    ...    xpath://div[contains(@class,"card--visible")]    timeout=10s
    Element Should Be Visible    xpath://a[contains(@class,"cta-btn")]

TC-EA07 Bejelentkezés gomb a profil oldalra navigál
    Go To    ${EMAIL_ALREADY_URL}
    Wait Until Element Is Visible
    ...    xpath://div[contains(@class,"card--visible")]    timeout=10s
    Execute JavaScript    document.querySelector('a.cta-btn').click()
    Sleep    2s
    Location Should Contain    profil

TC-EA08 Vissza a főoldalra link látható
    [Documentation]    A "vissza a főoldalra" szövegű link látható az oldalon
    [Tags]    email    already    navigation
    Go To    ${EMAIL_ALREADY_URL}
    Wait Until Element Is Visible
    ...    xpath://a[contains(.,"vissza a főoldalra")]    timeout=10s
    Element Should Be Visible    xpath://a[contains(.,"vissza a főoldalra")]

TC-EA09 Vissza a főoldalra link a főoldalra navigál
    Go To    ${EMAIL_ALREADY_URL}
    Wait Until Element Is Visible
    ...    xpath://div[contains(@class,"card--visible")]    timeout=10s
    Execute JavaScript    document.querySelector('a.hint__link').click()
    Wait Until Element Is Visible    xpath://header    timeout=10s
    Location Should Be    ${BASE_URL}/

TC-EA10 Kártya megjelenik animáció után
    [Documentation]    A kártya kezdetben láthatatlan, majd card--visible class-szal megjelenik
    [Tags]    email    already    ui
    Go To    ${EMAIL_ALREADY_URL}
    Wait Until Element Is Visible
    ...    xpath://div[contains(@class,"card--visible")]    timeout=5s
    ${classes}=    Get Element Attribute
    ...    xpath://div[contains(@class,"card")]    class
    Should Contain    ${classes}    card--visible

TC-EA11 Elválasztó vonal megjelenik
    [Documentation]    A kártyán belüli díszítő elválasztó elem látható
    [Tags]    email    already    layout
    Go To    ${EMAIL_ALREADY_URL}
    Wait Until Element Is Visible
    ...    xpath://div[contains(@class,"divider")]    timeout=10s
    Element Should Be Visible    xpath://div[contains(@class,"divider")]

# ════════════════════════════════════════════════════
# KÖZÖS - KÉT OLDAL ÖSSZEHASONLÍTÁSA
# ════════════════════════════════════════════════════

TC-EC01 A két oldal különböző főcímet mutat
    [Documentation]    A verified és already-verified oldalak eltérő szöveget tartalmaznak
    [Tags]    email    compare
    Go To    ${EMAIL_VERIFIED_URL}
    Wait Until Element Is Visible    xpath://h1[contains(@class,"title")]    timeout=10s
    ${cim_verified}=    Get Text    xpath://h1[contains(@class,"title")]
    Go To    ${EMAIL_ALREADY_URL}
    Wait Until Element Is Visible    xpath://h1[contains(@class,"title")]    timeout=10s
    ${cim_already}=    Get Text    xpath://h1[contains(@class,"title")]
    Should Not Be Equal    ${cim_verified}    ${cim_already}
    ...    msg=A két oldalnak különböző főcímet kell mutatnia

TC-EC02 A két oldal különböző badge szöveget mutat
    [Documentation]    Az állapot badge szövege eltér a két oldalon
    [Tags]    email    compare
    Go To    ${EMAIL_VERIFIED_URL}
    Wait Until Element Is Visible
    ...    xpath://div[contains(@class,"status-badge")]    timeout=10s
    ${badge_verified}=    Get Text
    ...    xpath://div[contains(@class,"status-badge")]
    Go To    ${EMAIL_ALREADY_URL}
    Wait Until Element Is Visible
    ...    xpath://div[contains(@class,"status-badge")]    timeout=10s
    ${badge_already}=    Get Text
    ...    xpath://div[contains(@class,"status-badge")]
    Should Not Be Equal    ${badge_verified}    ${badge_already}
    ...    msg=A badge szövegnek eltérőnek kell lennie a két oldalon