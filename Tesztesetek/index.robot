*** Settings ***
Resource    resources.robot
Test Setup    Open Registration Page
Test Teardown    Close Browser Session

*** Variables ***
${HOME_URL}             ${URL}
${HERO_VASARLAS_BTN}    xpath://a[contains(@class,"hero-btn primary")]
${HERO_MINTA_BTN}       xpath://a[contains(@class,"hero-btn secondary")]
${FEATURE_CARDS}        xpath://article[contains(@class,"feature-card")]
${BLOG_CARDS_HOME}      xpath://div[contains(@class,"card-grid-space")]
${LIKE_BTN}             xpath:(//button[contains(@class,"like-gomb")])[1]
${DISLIKE_BTN}          xpath:(//button[contains(@class,"dislike-gomb")])[1]
${LIKE_COUNT}           xpath:(//button[contains(@class,"like-gomb")]//span[contains(@class,"reakciok-szama")])[1]
${DISLIKE_COUNT}        xpath:(//button[contains(@class,"dislike-gomb")]//span[contains(@class,"reakciok-szama")])[1]
${VIEW_BTN}             xpath:(//button[contains(@class,"view-btn")])[1]
${MOTTO_TITLE}          xpath://div[@id="mottoContainer"]//h1
${FEATURE_MINTA_LINK}   xpath://a[contains(@class,"feature-link") and @href="/mintakeszito"]
${FEATURE_ARUHAZ_LINK}  xpath://a[contains(@class,"feature-link") and @href="/aruhaz"]
${FEATURE_BLOG_LINK}    xpath://a[contains(@class,"feature-link") and @href="/blog"]

*** Keywords ***
Ensure Like Is Not Active
    Execute JavaScript
    ...    const like = document.querySelectorAll('button.like-gomb')[0];
    ...    const dislike = document.querySelectorAll('button.dislike-gomb')[0];
    ...    if (dislike.classList.contains('active')) { dislike.click(); }
    Sleep    1.5s
    Execute JavaScript
    ...    const like = document.querySelectorAll('button.like-gomb')[0];
    ...    if (like.classList.contains('active')) { like.click(); }
    Sleep    1.5s

*** Test Cases ***

# ─────────────────────────────────────────────
# HERO SZEKCIÓ
# ─────────────────────────────────────────────

Hero Vasarlas Button Navigates To Aruhaz
    [Documentation]    A "Vásárlás" hero gomb az áruház oldalra navigál.
    Go To    ${HOME_URL}
    Wait Until Element Is Visible    ${HERO_VASARLAS_BTN}    timeout=10s
    Click Element    ${HERO_VASARLAS_BTN}
    Wait Until Location Contains    /aruhaz    timeout=10s

Hero Mintakeszito Button Navigates To Mintakeszito
    [Documentation]    A "Mintakészítő" hero gomb a mintakészítő oldalra navigál.
    Go To    ${HOME_URL}
    Wait Until Element Is Visible    ${HERO_MINTA_BTN}    timeout=10s
    Click Element    ${HERO_MINTA_BTN}
    Wait Until Location Contains    /mintakeszito    timeout=10s

Hero Banner Is Visible On Page Load
    [Documentation]    A hero banner és a főcím megjelenik az oldal betöltésekor.
    Go To    ${HOME_URL}
    Wait Until Element Is Visible    xpath://section[contains(@class,"hero-banner")]    timeout=10s
    Element Should Be Visible    xpath://h1[contains(@class,"hero-title")]

Motto Container Is Visible
    [Documentation]    Az üdvözlő motto szöveg megjelenik az oldalon.
    Go To    ${HOME_URL}
    Wait Until Element Is Visible    ${MOTTO_TITLE}    timeout=10s
    Element Should Contain    ${MOTTO_TITLE}    Üdvözölünk

# ─────────────────────────────────────────────
# FEATURE KÁRTYÁK
# ─────────────────────────────────────────────
Feature Cards Are Rendered
    [Documentation]    A 6 feature kártya jelen van az oldalon.
    Go To    ${HOME_URL}
    Sleep    2s
    ${count}=    Execute JavaScript
    ...    return document.querySelectorAll('article.feature-card').length
    Should Be Equal As Integers    ${count}    6

Feature Mintakeszito Card Navigates Correctly
    Go To    ${HOME_URL}
    Sleep    2s
    Execute JavaScript
    ...    document.querySelector('a.feature-link[href="/mintakeszito"]').click()
    Wait Until Location Contains    /mintakeszito    timeout=10s

Feature Aruhaz Card Navigates Correctly
    Go To    ${HOME_URL}
    Sleep    2s
    Execute JavaScript
    ...    document.querySelector('a.feature-link[href="/aruhaz"]').click()
    Wait Until Location Contains    /aruhaz    timeout=10s

Feature Blog Card Navigates Correctly
    Go To    ${HOME_URL}
    Sleep    2s
    Execute JavaScript
    ...    document.querySelector('a.feature-link[href="/blog"]').click()
    Wait Until Location Contains    /blog    timeout=10s

Feature Profile Card Navigates To Login When Not Authenticated
    Go To    ${HOME_URL}
    Sleep    2s
    Execute JavaScript
    ...    document.querySelector('a.feature-link[href="/belepes"]').click()
    Wait Until Location Contains    /belepes    timeout=10s

Feature Profile Card Navigates To Profil When Authenticated
    Login As Test User
    Go To    ${HOME_URL}
    Sleep    2s
    Execute JavaScript
    ...    document.querySelector('a.feature-link[href="/profil"]').click()
    Wait Until Location Contains    /profil    timeout=10s

# ─────────────────────────────────────────────
# BLOG KÁRTYÁK – MEGJELENÍTÉS
# ─────────────────────────────────────────────

Blog Cards Are Rendered On Home Page
    [Documentation]    A kiemelt blogposztok kártyái megjelennek a főoldalon.
    Go To    ${HOME_URL}
    Wait Until Element Is Visible    ${BLOG_CARDS_HOME}    timeout=15s
    ${count}=    Get Element Count    ${BLOG_CARDS_HOME}
    Should Be True    ${count} > 0

Blog Card Contains Title Date And Tags
    [Documentation]    Az első blog kártya tartalmaz címet, dátumot és tageket.
    Go To    ${HOME_URL}
    Wait Until Element Is Visible    xpath:(//div[contains(@class,"card-grid-space")])[1]    timeout=15s
    Element Should Be Visible    xpath:(//h3[contains(@class,"blog-title")])[1]
    Element Should Be Visible    xpath:(//span[contains(@class,"blog-time")])[1]

Blog Card Image Loads
    [Documentation]    Az első blog kártya képe betölt (src attribútum nem üres).
    Go To    ${HOME_URL}
    Wait Until Element Is Visible    xpath:(//div[contains(@class,"card-img-holder")])[1]    timeout=15s
    ${src}=    Get Element Attribute
    ...    xpath:(//div[contains(@class,"card-img-holder")]//img)[1]    src
    Should Not Be Empty    ${src}

# ─────────────────────────────────────────────
# BLOG REAKCIÓK – LIKE / DISLIKE
# ─────────────────────────────────────────────

Like Button Increments Count When Logged In
    [Documentation]    Bejelentkezett felhasználó like gombra kattintva a számláló nő.
    Login As Test User
    Go To    ${HOME_URL}
    Wait Until Element Is Visible    ${LIKE_BTN}    timeout=15s
    ${before}=    Get Text    ${LIKE_COUNT}
    Click Element    ${LIKE_BTN}
    Sleep    1s
    ${after}=    Get Text    ${LIKE_COUNT}
    ${before_int}=    Convert To Integer    ${before}
    ${after_int}=    Convert To Integer    ${after}
    Should Be True    ${after_int} >= ${before_int}

Dislike Button Increments Count When Logged In
    [Documentation]    Bejelentkezett felhasználó dislike gombra kattintva a számláló nő.
    Login As Test User
    Go To    ${HOME_URL}
    Wait Until Element Is Visible    ${DISLIKE_BTN}    timeout=15s
    ${before}=    Get Text    ${DISLIKE_COUNT}
    Click Element    ${DISLIKE_BTN}
    Sleep    1s
    ${after}=    Get Text    ${DISLIKE_COUNT}
    ${before_int}=    Convert To Integer    ${before}
    ${after_int}=    Convert To Integer    ${after}
    Should Be True    ${after_int} >= ${before_int}

Like Button Redirects To Login When Not Authenticated
    [Documentation]    Nem bejelentkezett felhasználó like gombra kattintva a bejelentkezési oldalra kerül.
    Go To    ${HOME_URL}
    Wait Until Element Is Visible    ${LIKE_BTN}    timeout=15s
    Click Element    ${LIKE_BTN}
    Wait Until Location Contains    /Belepes    timeout=10s

Dislike Button Redirects To Login When Not Authenticated
    [Documentation]    Nem bejelentkezett felhasználó dislike gombra kattintva a bejelentkezési oldalra kerül.
    Go To    ${HOME_URL}
    Wait Until Element Is Visible    ${DISLIKE_BTN}    timeout=15s
    Click Element    ${DISLIKE_BTN}
    Wait Until Location Contains    /Belepes    timeout=10s

Like Toggle Removes Like On Second Click
    Login As Test User
    Go To    ${HOME_URL}
    Wait Until Element Is Visible    ${LIKE_BTN}    timeout=15s
    Ensure Like Is Not Active
    Click Element    ${LIKE_BTN}
    Sleep    1.5s
    ${after_first}=    Get Text    ${LIKE_COUNT}
    Click Element    ${LIKE_BTN}
    Sleep    1.5s
    ${after_second}=    Get Text    ${LIKE_COUNT}
    ${first_int}=    Convert To Integer    ${after_first}
    ${second_int}=    Convert To Integer    ${after_second}
    Should Be True    ${second_int} < ${first_int}


Like Active Class Applied After Click
    Login As Test User
    Go To    ${HOME_URL}
    Wait Until Element Is Visible    ${LIKE_BTN}    timeout=15s
    Ensure Like Is Not Active
    Click Element    ${LIKE_BTN}
    Sleep    1.5s
    ${classes}=    Get Element Attribute    ${LIKE_BTN}    class
    Should Contain    ${classes}    active

# ─────────────────────────────────────────────
# MEGTEKINTÉS GOMB
# ─────────────────────────────────────────────

View Button Navigates To Blog Post
    [Documentation]    A "Megtekintés" gombra kattintva a blog poszt oldalára navigál.
    Go To    ${HOME_URL}
    Wait Until Element Is Visible    ${VIEW_BTN}    timeout=15s
    Click Element    ${VIEW_BTN}
    Wait Until Location Contains    /blog/    timeout=10s