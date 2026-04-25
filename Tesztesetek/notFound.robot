*** Settings ***
Library     SeleniumLibrary
Resource    resources.robot

Test Setup       Run Keywords
...              Open Registration Page
Test Teardown    Close Browser Session

*** Variables ***
${BASE_URL}         http://localhost:5173
${NOT_FOUND_URL}    http://localhost:5173/ez-az-oldal-nem-letezik

*** Test Cases ***

TC-NF01 Nem létező URL 404 oldalt tölt be
    Go To    ${NOT_FOUND_URL}
    Wait Until Element Is Visible    xpath://div[contains(@class,"container")]//h1[contains(.,"404")]    timeout=10s
    Element Should Be Visible    xpath://div[contains(@class,"container")]//h1[contains(.,"404")]

TC-NF02 Hibaüzenet szövege megjelenik
    [Documentation]    A "page you're looking for doesn't exist" szöveg látható
    [Tags]    notfound    content
    Go To    ${NOT_FOUND_URL}
    Wait Until Element Is Visible    xpath://h1[contains(.,"404")]    timeout=10s
    Element Should Be Visible    xpath://p[contains(.,"doesn't exist")]

TC-NF03 Főoldalra mutató gomb megjelenik
    [Documentation]    A "Go Home" gomb látható
    [Tags]    notfound    content
    Go To    ${NOT_FOUND_URL}
    Wait Until Element Is Visible    xpath://a[contains(.,"Go Home")]    timeout=10s
    Element Should Be Visible    xpath://a[contains(.,"Go Home")]

TC-NF04 Go Home gomb a főoldalra navigál
    [Documentation]    A gombra kattintva a főoldal töltődik be
    [Tags]    notfound    navigation
    Go To    ${NOT_FOUND_URL}
    Wait Until Element Is Visible    xpath://a[contains(.,"Go Home")]    timeout=10s
    Click Element    xpath://a[contains(.,"Go Home")]
    Wait Until Element Is Visible
    ...    xpath://header    timeout=10s
    Location Should Be    ${BASE_URL}/

TC-NF05 Mélyen beágyazott útvonal is 404-et ad
    Go To    ${BASE_URL}/valami/ami/nem/letezik
    Wait Until Element Is Visible    xpath://div[contains(@class,"container")]//h1[contains(.,"404")]    timeout=10s
    Element Should Be Visible    xpath://div[contains(@class,"container")]//h1[contains(.,"404")]

TC-NF06 404 oldal nem tartalmaz navigációs hibát
    [Documentation]    A 404 oldal betöltése nem dob JavaScript hibát
    [Tags]    notfound
    Go To    ${NOT_FOUND_URL}
    Wait Until Element Is Visible    xpath://h1[contains(.,"404")]    timeout=10s
    ${logs}=    Execute JavaScript
    ...    return window.__errors__ ? window.__errors__.join(',') : ''
    Should Be Empty    ${logs}

TC-NF07 Védett útvonalra nem bejelentkezett felhasználó átirányítódik
    Go To    ${BASE_URL}/profil
    Wait Until Location Contains    belepes    timeout=10s

TC-NF08 Admin útvonal nem admin felhasználónak átirányít vagy 404-et ad
    Go To    ${BASE_URL}/dashboard
    Sleep    3s
    ${loc}=    Get Location
    ${is_notfound}=    Run Keyword And Return Status
    ...    Element Should Be Visible    xpath://div[contains(@class,"container")]//h1[contains(.,"404")]
    ${is_login}=    Run Keyword And Return Status
    ...    Location Should Contain    belepes
    ${is_index}=    Run Keyword And Return Status
    ...    Location Should Be    ${BASE_URL}/
    Should Be True    ${is_notfound} or ${is_login} or ${is_index}
    ...    msg=Nem bejelentkezett felhasználónak a dashboard nem elérhető

TC-NF09 Vendég-only útvonal bejelentkezett felhasználónak átirányít
    [Documentation]    A /belepes útvonal bejelentkezett usernek a főoldalra irányít
    [Tags]    notfound    routing    auth
    Go To    ${BASE_URL}
    Wait Until Element Is Visible
    ...    //*[@id="app"]/div/header/nav/a[8]/p    timeout=10s
    Click Element    //*[@id="app"]/div/header/nav/a[8]/p
    Switch To Login
    Fill Login Form    ${ADMIN_EMAIL}    ${ADMIN_PASS}
    Submit Login
    Login Should Succeed
    Go To    ${BASE_URL}/belepes
    Sleep    1s
    Location Should Be    ${BASE_URL}/

TC-NF10 Reset jelszó token nélkül főoldalra irányít
    Go To    ${BASE_URL}/reset-password
    Sleep    3s
    ${loc}=    Get Location
    Should Be Equal    ${loc}    ${BASE_URL}/
    ...    msg=Token nélküli reset-password nem irányított a főoldalra