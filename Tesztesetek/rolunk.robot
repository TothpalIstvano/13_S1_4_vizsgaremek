*** Settings ***
Library     SeleniumLibrary
Resource    resources.robot

Test Setup       Run Keywords
...              Open Registration Page
Test Teardown    Close Browser Session

*** Variables ***
${ROLUNK_URL}       http://localhost:5173/rolunk
${ROLUNK_NAV}       xpath://header//nav//a[contains(.,"Rólunk")]
${GYIK_ITEMS}       xpath://details[contains(@class,"gyik-elem")]
${GYIK_SUMMARY}     xpath://summary[contains(@class,"gyik-kerdes")]
${ARUHAZ_BTN}       xpath://a[contains(@class,"gomb") and contains(.,"áruházunkat")]

*** Test Cases ***

TC-R01 Rólunk oldal betöltése
    [Documentation]    Az oldal betöltődik és a főcím látható
    [Tags]    rolunk    smoke
    Go To    ${ROLUNK_URL}
    Wait Until Element Is Visible    xpath://h1[@id="cim"]    timeout=10s
    Element Should Contain    xpath://h1[@id="cim"]    Rólunk

TC-R02 Navigációs linkből elérhető
    [Documentation]    A nav menüből a Rólunk link az oldalra navigál
    [Tags]    rolunk    navigation
    Go To    http://localhost:5173
    Wait Until Element Is Visible    ${ROLUNK_NAV}    timeout=10s
    Click Element    ${ROLUNK_NAV}
    Wait Until Element Is Visible    xpath://h1[@id="cim"]    timeout=10s
    Location Should Contain    rolunk

TC-R03 Bevezető kép és szöveg megjelenik
    [Documentation]    A felső szekcióban a kép és a leírás látható
    [Tags]    rolunk    content
    Go To    ${ROLUNK_URL}
    Wait Until Element Is Visible    xpath://h1[@id="cim"]    timeout=10s
    Element Should Be Visible    xpath://img[contains(@class,"kep")]
    Element Should Be Visible    xpath://p[contains(@class,"leiras")]

TC-R04 Piros doboz szövege látható
    [Documentation]    A képen lévő piros kiemelő doboz szövege nem üres
    [Tags]    rolunk    content
    Go To    ${ROLUNK_URL}
    Wait Until Element Is Visible    xpath://div[contains(@class,"piros-doboz")]    timeout=10s
    ${text}=    Get Text    xpath://p[contains(@class,"piros-doboz-szoveg")]
    Should Not Be Empty    ${text}

TC-R05 Áruház gomb az áruházra navigál
    [Documentation]    A gombra kattintva az áruház oldal töltődik be
    [Tags]    rolunk    navigation
    Go To    ${ROLUNK_URL}
    Wait Until Element Is Visible    ${ARUHAZ_BTN}    timeout=10s
    Click Element    ${ARUHAZ_BTN}
    Wait Until Element Is Visible    xpath://div[contains(@class,"product-card")]    timeout=15s
    Location Should Contain    aruhaz

TC-R06 GYIK szekció és kérdések megjelennek
    [Documentation]    A GYIK szekció látható és legalább 5 kérdés szerepel
    [Tags]    rolunk    gyik
    Go To    ${ROLUNK_URL}
    Wait Until Element Is Visible    id:gyik    timeout=10s
    ${count}=    Get Element Count    ${GYIK_ITEMS}
    Should Be True    ${count} >= 5    msg=Legalább 5 GYIK kérdés szükséges

TC-R07 GYIK elem kinyílik kattintásra
    Go To    ${ROLUNK_URL}
    Wait Until Element Is Visible    ${GYIK_ITEMS}    timeout=10s
    ${elotte}=    Execute JavaScript
    ...    return document.querySelectorAll('details.gyik-elem')[0].open
    Execute JavaScript    document.querySelectorAll('summary.gyik-kerdes')[0].click()
    Sleep    0.3s
    ${utana}=    Execute JavaScript
    ...    return document.querySelectorAll('details.gyik-elem')[0].open
    Should Not Be Equal    ${elotte}    ${utana}
    ...    msg=A GYIK elem állapota nem változott

TC-R08 GYIK elem bezárul második kattintásra
    Go To    ${ROLUNK_URL}
    Wait Until Element Is Visible    ${GYIK_ITEMS}    timeout=10s
    Execute JavaScript    document.querySelectorAll('summary.gyik-kerdes')[0].click()
    Sleep    0.3s
    ${nyitva}=    Execute JavaScript
    ...    return document.querySelectorAll('details.gyik-elem')[0].open
    Should Be True    ${nyitva}    msg=Az elem nem nyílt ki
    Execute JavaScript    document.querySelectorAll('summary.gyik-kerdes')[0].click()
    Sleep    0.3s
    ${zarva}=    Execute JavaScript
    ...    return document.querySelectorAll('details.gyik-elem')[0].open
    Should Not Be True    ${zarva}    msg=Az elem nem záródott be


TC-R09 Több GYIK elem egyszerre nyitható
    Go To    ${ROLUNK_URL}
    Wait Until Element Is Visible    ${GYIK_ITEMS}    timeout=10s
    Execute JavaScript    document.querySelectorAll('summary.gyik-kerdes')[0].click()
    Sleep    0.3s
    Execute JavaScript    document.querySelectorAll('summary.gyik-kerdes')[1].click()
    Sleep    0.3s
    ${nyitva1}=    Execute JavaScript
    ...    return document.querySelectorAll('details.gyik-elem')[0].open
    ${nyitva2}=    Execute JavaScript
    ...    return document.querySelectorAll('details.gyik-elem')[1].open
    Should Be True    ${nyitva1}    msg=Az első elem bezárult
    Should Be True    ${nyitva2}    msg=A második elem nem nyílt ki

TC-R10 GYIK válasz szövege nem üres
    Go To    ${ROLUNK_URL}
    Wait Until Element Is Visible    ${GYIK_ITEMS}    timeout=10s
    Execute JavaScript    document.querySelectorAll('summary.gyik-kerdes')[0].click()
    Sleep    0.3s
    ${valasz}=    Get Text    xpath:(//div[contains(@class,"gyik-valasz")])[1]
    Should Not Be Empty    ${valasz}    msg=A válasz szövege üres

TC-R11 GYIK kérdés szövege nem üres
    [Documentation]    Minden GYIK kérdés szövege nem üres
    [Tags]    rolunk    gyik
    Go To    ${ROLUNK_URL}
    Wait Until Element Is Visible    ${GYIK_ITEMS}    timeout=10s
    @{kerdesek}=    Get WebElements    ${GYIK_SUMMARY}
    FOR    ${kerdes}    IN    @{kerdesek}
        ${szoveg}=    Get Text    ${kerdes}
        Should Not Be Empty    ${szoveg}    msg=Egy GYIK kérdés szövege üres
    END

TC-R12 Csapatkártyák megjelennek
    [Documentation]    A csapat szekcióban legalább 2 kártya látható
    [Tags]    rolunk    csapat
    Go To    ${ROLUNK_URL}
    Wait Until Element Is Visible
    ...    xpath://div[contains(@class,"cardscontainer")]    timeout=10s
    ${count}=    Get Element Count
    ...    xpath://div[contains(@class,"cardscontainer")]//*[contains(@class,"card") or contains(@class,"kártya")]
    Should Be True    ${count} >= 2    msg=Legalább 2 csapatkártyának kell lennie

TC-R13 Csapattag neve nem üres
    Go To    ${ROLUNK_URL}
    Wait Until Element Is Visible
    ...    xpath://div[contains(@class,"cardscontainer")]    timeout=10s
    ${nev1}=    Execute JavaScript
    ...    return document.querySelectorAll('span.name')[0].textContent.trim()
    Should Not Be Empty    ${nev1}    msg=Az első csapattag neve üres
    ${nev2}=    Execute JavaScript
    ...    return document.querySelectorAll('span.name')[1].textContent.trim()
    Should Not Be Empty    ${nev2}    msg=A második csapattag neve üres

TC-R14 Csapattag bemutatkozó szövege nem üres
    Go To    ${ROLUNK_URL}
    Wait Until Element Is Visible
    ...    xpath://div[contains(@class,"cardscontainer")]    timeout=10s
    ${leiras1}=    Execute JavaScript
    ...    return document.querySelectorAll('span.about-me')[0].textContent.trim()
    Should Not Be Empty    ${leiras1}    msg=Az első csapattag leírása üres
    ${leiras2}=    Execute JavaScript
    ...    return document.querySelectorAll('span.about-me')[1].textContent.trim()
    Should Not Be Empty    ${leiras2}    msg=A második csapattag leírása üres

TC-R15 Kapcsolatfelvétel gomb látható a kártyákon
    [Documentation]    A "Lépj kapcsolatba" gomb mindkét kártyán megjelenik
    [Tags]    rolunk    csapat
    Go To    ${ROLUNK_URL}
    Wait Until Element Is Visible
    ...    xpath://div[contains(@class,"cardscontainer")]    timeout=10s
    ${count}=    Get Element Count
    ...    xpath://button[contains(.,"Lépj kapcsolatba")]
    Should Be True    ${count} >= 2
    ...    msg=A kapcsolatfelvétel gomb nem jelenik meg minden kártyán

TC-R16 Elválasztó vonalak megjelennek
    [Documentation]    A szekciók között hr elemek láthatók
    [Tags]    rolunk    layout
    Go To    ${ROLUNK_URL}
    Wait Until Element Is Visible    xpath://h1[@id="cim"]    timeout=10s
    ${count}=    Get Element Count    xpath://hr
    Should Be True    ${count} >= 2    msg=Legalább 2 elválasztó szükséges

TC-R17 Csapat szekció fejléce látható
    [Documentation]    A "Csapatunk" felirat megjelenik
    [Tags]    rolunk    csapat
    Go To    ${ROLUNK_URL}
    Wait Until Element Is Visible
    ...    xpath://h1[contains(.,"Csapatunk")]    timeout=10s
    Element Should Be Visible    xpath://h1[contains(.,"Csapatunk")]

TC-R18 GYIK szekció fejléce látható
    [Documentation]    A "Gyakran ismételt kérdések" felirat megjelenik
    [Tags]    rolunk    gyik
    Go To    ${ROLUNK_URL}
    Wait Until Element Is Visible    id:gyik    timeout=10s
    Element Should Be Visible
    ...    xpath://h1[contains(.,"Gyakran ismételt kérdések")]