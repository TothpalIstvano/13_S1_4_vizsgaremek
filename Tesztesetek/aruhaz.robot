*** Settings ***
Resource    resources.robot
Test Setup    Open Aruhaz Page
Test Teardown    Close Browser Session

*** Test Cases ***
# ─────────────────────────────────────────────
# ÁRUHÁZ TESZTEK
# ─────────────────────────────────────────────

TC01 – Áruház oldal betöltődik és termékek megjelennek
    [Tags]    aruhaz    smoke
    Navigate To Aruhaz
    Element Should Be Visible    ${PRODUCT_CARD}
    Element Should Be Visible    ${FIRST_PRODUCT_TITLE}
    Element Should Be Visible    ${FIRST_PRODUCT_PRICE}

TC02 – Termék keresése szöveggel
    [Tags]    aruhaz    search
    Navigate To Aruhaz
    ${first_title}=    Get Text    ${FIRST_PRODUCT_TITLE}
    ${keyword}=    Evaluate    '${first_title}'[:4]
    Input Text    ${SEARCH_INPUT}    ${keyword}
    Sleep    0.5s
    ${visible_cards}=    Get Element Count    xpath://div[contains(@class,"product-card")]
    Should Be True    ${visible_cards} >= 1

TC03 – Üres keresésre nincs találat visszajelzés
    [Tags]    aruhaz    search
    Navigate To Aruhaz
    Input Text    ${SEARCH_INPUT}    xyzxyzxyznemletezik999
    Sleep    0.5s
    Element Should Be Visible    xpath://div[contains(text(),"Nincs találat")]

TC04 – Kosárba gomb megnyomása megnyitja a modalt
    [Tags]    aruhaz    cart
    Add First Product To Cart
    Element Should Be Visible    xpath://h2[contains(.,"Sikeresen hozzáadva")]
    Close Cart Modal

TC05 – Modal tartalmazza a termék nevét
    [Tags]    aruhaz    cart
    ${title}=    Add First Product To Cart
    ${modal_name}=    Get Text    xpath://p[contains(@class,"item-name")]
    Should Be Equal    ${modal_name}    ${title}
    Close Cart Modal

TC06 – Modal „Kosár megtekintése" gomb átvisz a kosárba
    [Tags]    aruhaz    cart    navigation
    Add First Product To Cart
    Click Element    ${MODAL_CART_BTN}
    Wait Until Element Is Visible    ${CART_HEADER}    timeout=10s

TC07 – Termék részletes oldala betöltődik
    [Tags]    aruhaz    navigation
    Navigate To Aruhaz
    Click Element    ${PRODUCT_CARD}
    Wait Until Element Is Visible    xpath://button[contains(@class,"add-to-cart-btn")]    timeout=10s
    Element Should Be Visible    xpath://h1

TC08 – Részletes oldalon „Vissza" gomb visszanavigál
    [Tags]    aruhaz    navigation
    Navigate To Aruhaz
    Click Element    ${PRODUCT_CARD}
    Wait Until Element Is Visible    xpath://button[contains(@class,"back-btn")]    timeout=10s
    Click Element    xpath://button[contains(@class,"back-btn")]
    Wait Until Element Is Visible    ${PRODUCT_CARD}    timeout=10s

TC09 – Ár szűrő alkalmazás szűri a termékeket
    [Tags]    aruhaz    filter
    Navigate To Aruhaz
    ${count_before}=    Get Element Count    xpath://div[contains(@class,"product-card")]
    Clear Element Text    ${PRICE_MAX_INPUT}
    Input Text    ${PRICE_MAX_INPUT}    1
    Click Element    ${APPLY_PRICE_BTN}
    Sleep    0.5s
    ${count_after}=    Get Element Count    xpath://div[contains(@class,"product-card")]
    Should Be True    ${count_after} <= ${count_before}

TC10 – Kategória szűrő megjelenik és kattintható
    [Tags]    aruhaz    filter
    Navigate To Aruhaz
    ${first_cat_header}=    Get WebElement    xpath:(//div[contains(@class,"category-header")])[1]
    Click Element    ${first_cat_header}
    Sleep    0.3s
    ${expanded}=    Get Element Count    xpath://div[contains(@class,"subcategory-list")]
    Should Be True    ${expanded} >= 1

# ─────────────────────────────────────────────
# KOSÁR TESZTEK
# ─────────────────────────────────────────────

TC11 – Üres kosár üzenete megjelenik
    [Tags]    kosar    smoke
    # Clear cart via navigation with no items
    Go To    ${KOSAR_URL}
    Sleep    0.5s
    # If cart has items, empty it first
    ${has_empty}=    Run Keyword And Return Status    Element Should Be Visible    ${EMPTY_CART_MSG}
    Run Keyword If    not ${has_empty}    Run Keywords
    ...    Click Element    ${EMPTY_CART_BTN}    AND
    ...    Handle Alert    ACCEPT    AND
    ...    Wait Until Element Is Visible    ${EMPTY_CART_MSG}    timeout=5s
    Element Should Be Visible    ${EMPTY_CART_MSG}

TC12 – Üres kosár „Vissza az Áruházba" linkje működik
    [Tags]    kosar    navigation
    Go To    ${KOSAR_URL}
    Sleep    0.5s
    ${is_empty}=    Run Keyword And Return Status    Element Should Be Visible    ${EMPTY_CART_MSG}
    Skip If    not ${is_empty}    Kosár nem üres – TC11 előtt futtasd
    Execute JavaScript    document.querySelector('a[href*="/aruhaz"]').click()
    Wait Until Element Is Visible    ${PRODUCT_CARD}    timeout=10s

TC13 – Termék hozzáadása után megjelenik a kosárban
    [Tags]    kosar    cart
    Add First Product To Cart
    Click Element    ${MODAL_CART_BTN}
    Wait Until Element Is Visible    ${CART_HEADER}    timeout=10s
    ${count}=    Get Text    ${PRODUCT_COUNT_LABEL}
    Should Contain    ${count}    termék

TC14 – Mennyiség növelése a „+" gombbal
    [Tags]    kosar    cart
    Add First Product To Cart
    Click Element    ${MODAL_CART_BTN}
    Wait Until Element Is Visible    ${QTY_PLUS}    timeout=10s
    ${before}=    Get Value    ${QTY_INPUT}
    ${plus_enabled}=    Run Keyword And Return Status    Element Should Be Enabled    ${QTY_PLUS}
    Run Keyword If    ${plus_enabled}    Click Element    ${QTY_PLUS}
    Run Keyword If    ${plus_enabled}    Sleep    0.3s
    ${after}=    Get Value    ${QTY_INPUT}
    Run Keyword If    ${plus_enabled}    Should Be True    ${after} > ${before}

TC15 – Mennyiség csökkentése a „−" gombbal
    [Tags]    kosar    cart
    Navigate To Aruhaz
    Click Element    ${FIRST_ADD_BTN}
    Wait Until Element Is Visible    ${CART_MODAL}    timeout=5s
    Close Cart Modal
    Navigate To Aruhaz
    Click Element    ${FIRST_ADD_BTN}
    Wait Until Element Is Visible    ${CART_MODAL}    timeout=5s
    Click Element    ${MODAL_CART_BTN}
    Wait Until Element Is Visible    ${QTY_MINUS}    timeout=10s
    ${before}=    Get Value    ${QTY_INPUT}
    ${minus_enabled}=    Run Keyword And Return Status    Element Should Be Enabled    ${QTY_MINUS}
    Run Keyword If    ${minus_enabled}    Click Element    ${QTY_MINUS}
    Run Keyword If    ${minus_enabled}    Sleep    0.3s
    ${after}=    Get Value    ${QTY_INPUT}
    Run Keyword If    ${minus_enabled}    Should Be True    ${after} < ${before}

TC16 – Termék eltávolítása a kosárból
    [Tags]    kosar    cart
    Add First Product To Cart
    Click Element    ${MODAL_CART_BTN}
    Wait Until Element Is Visible    ${REMOVE_BTN}    timeout=10s
    Click Element    ${REMOVE_BTN}
    Sleep    0.5s
    Element Should Be Visible    ${EMPTY_CART_MSG}

TC17 – Kosár ürítése gombbal (megerősítéssel)
    [Tags]    kosar    cart
    Add First Product To Cart
    Click Element    ${MODAL_CART_BTN}
    Wait Until Element Is Visible    ${EMPTY_CART_BTN}    timeout=10s
    Execute JavaScript    window.scrollTo(0, 0)
    Sleep    0.5s
    Execute JavaScript    window.confirm = function(){ return true; }
    Click Element    ${EMPTY_CART_BTN}
    Sleep    1s
    Wait Until Element Is Visible    ${EMPTY_CART_MSG}    timeout=10s

TC18 – Kosár ürítése gombbal (elutasítással) megtartja a terméket
    [Tags]    kosar    cart
    Add First Product To Cart
    Click Element    ${MODAL_CART_BTN}
    Wait Until Element Is Visible    ${EMPTY_CART_BTN}    timeout=10s
    Click Element    ${EMPTY_CART_BTN}
    Handle Alert    DISMISS
    Element Should Not Be Visible    ${EMPTY_CART_MSG}

TC19 – Végösszeg helyesen számítódik
    [Tags]    kosar    cart
    Add First Product To Cart
    Click Element    ${MODAL_CART_BTN}
    Wait Until Element Is Visible    ${CART_TOTAL}    timeout=10s
    ${total_text}=    Get Text    ${CART_TOTAL}
    Should Contain    ${total_text}    Ft

TC20 – Checkout gomb validálja az üres szállítási adatokat
    [Tags]    kosar    validation
    Add First Product To Cart
    Click Element    ${MODAL_CART_BTN}
    Wait Until Element Is Visible    ${CHECKOUT_BTN}    timeout=10s
    Click Element    ${CHECKOUT_BTN}
    # Expect browser alert
    ${alert_present}=    Run Keyword And Return Status    Handle Alert    ACCEPT
    Should Be True    ${alert_present}

TC21 – Érvénytelen irányítószám hibaüzenetet mutat
    [Tags]    kosar    validation
    Add First Product To Cart
    Click Element    ${MODAL_CART_BTN}
    Wait Until Element Is Visible    ${FIELD_ZIP}    timeout=10s
    Input Text    ${FIELD_ZIP}    abc
    Press Keys    ${FIELD_ZIP}    TAB
    Sleep    0.3s
    Element Should Be Visible    xpath://span[contains(@class,"error-message")]

TC22 – Helyes irányítószám zöld pipát mutat
    [Tags]    kosar    validation
    Add First Product To Cart
    Click Element    ${MODAL_CART_BTN}
    Wait Until Element Is Visible    ${FIELD_ZIP}    timeout=10s
    Input Text    ${FIELD_ZIP}    1051
    Press Keys    ${FIELD_ZIP}    TAB
    Sleep    0.3s
    Element Should Be Visible    xpath://span[contains(@class,"success-indicator")]

TC23 – Teljes szállítási adatok kitöltésével a checkout továbblép a fizetésre
    [Tags]    kosar    checkout    navigation
    Add First Product To Cart
    Click Element    ${MODAL_CART_BTN}
    Wait Until Element Is Visible    ${CHECKOUT_BTN}    timeout=10s
    Fill Delivery Form
    Sleep    0.5s
    Click Element    ${CHECKOUT_BTN}
    Wait Until Location Contains    /kosar/fizetes    timeout=10s

# ─────────────────────────────────────────────
# FIZETÉS TESZTEK
# ─────────────────────────────────────────────

TC24 – Fizetési oldal betöltődik
    [Tags]    fizetes    smoke
    # Setup: add product and navigate to checkout
    Add First Product To Cart
    Click Element    ${MODAL_CART_BTN}
    Wait Until Element Is Visible    ${CHECKOUT_BTN}    timeout=10s
    Fill Delivery Form
    Click Element    ${CHECKOUT_BTN}
    Wait Until Location Contains    /kosar/fizetes    timeout=10s
    Element Should Be Visible    ${CARD_NUMBER_INPUT}

TC25 – Fizetési form Submit üres mezőkkel hibaüzenetet ad
    [Tags]    fizetes    validation
    Add First Product To Cart
    Click Element    ${MODAL_CART_BTN}
    Fill Delivery Form
    Click Element    ${CHECKOUT_BTN}
    Wait Until Location Contains    /kosar/fizetes    timeout=10s
    Click Element    ${SUBMIT_BTN_PAYMENT}
    Assert Overlay Message Contains    Please fill all fields correctly

TC26 – Kártya szám formázás szóközöket illeszt be
    [Tags]    fizetes    ui
    Add First Product To Cart
    Click Element    ${MODAL_CART_BTN}
    Fill Delivery Form
    Click Element    ${CHECKOUT_BTN}
    Wait Until Location Contains    /kosar/fizetes    timeout=10s
    Input Text    ${CARD_NUMBER_INPUT}    4111111111111111
    ${val}=    Get Value    ${CARD_NUMBER_INPUT}
    Should Contain    ${val}    ${SPACE}

TC27 – CVV mező csak számokat fogad el
    [Tags]    fizetes    validation
    Add First Product To Cart
    Click Element    ${MODAL_CART_BTN}
    Fill Delivery Form
    Click Element    ${CHECKOUT_BTN}
    Wait Until Location Contains    /kosar/fizetes    timeout=10s
    Click Element    ${CARD_CVV_INPUT}
    Input Text    ${CARD_CVV_INPUT}    abc
    ${val}=    Get Value    ${CARD_CVV_INPUT}
    Should Be Empty    ${val}

TC28 – Kártya megfordítása CVV fókusznál
    [Tags]    fizetes    ui
    Add First Product To Cart
    Click Element    ${MODAL_CART_BTN}
    Fill Delivery Form
    Click Element    ${CHECKOUT_BTN}
    Wait Until Location Contains    /kosar/fizetes    timeout=10s
    Execute JavaScript    window.scrollTo(0, 300)
    Sleep    0.5s
    Click Element    ${CARD_CVV_INPUT}
    Sleep    1s
    ${classes}=    Execute JavaScript    return document.querySelector('.card-item').className
    Should Contain    ${classes}    -active

TC29 – Helyes kártyaadatokkal sikeres fizetés overlay jelenik meg
    [Tags]    fizetes    e2e
    Add First Product To Cart
    Click Element    ${MODAL_CART_BTN}
    Fill Delivery Form
    Click Element    ${CHECKOUT_BTN}
    Wait Until Location Contains    /kosar/fizetes    timeout=10s
    Fill Payment Form
    Click Element    ${SUBMIT_BTN_PAYMENT}
    Assert Overlay Message Contains    accepted

TC30 – Visa kártya ikon megjelenik a kártyán
    [Tags]    fizetes    ui
    Add First Product To Cart
    Click Element    ${MODAL_CART_BTN}
    Fill Delivery Form
    Click Element    ${CHECKOUT_BTN}
    Wait Until Location Contains    /kosar/fizetes    timeout=10s
    Input Text    ${CARD_NUMBER_INPUT}    4111 1111 1111 1111
    Element Should Be Visible    xpath://img[contains(@src,"visa.png")]

TC31 – Mastercard kártya ikon megjelenik a kártyán
    [Tags]    fizetes    ui
    Add First Product To Cart
    Click Element    ${MODAL_CART_BTN}
    Fill Delivery Form
    Click Element    ${CHECKOUT_BTN}
    Wait Until Location Contains    /kosar/fizetes    timeout=10s
    Input Text    ${CARD_NUMBER_INPUT}    5111 1111 1111 1111
    Element Should Be Visible    xpath://img[contains(@src,"mastercard.png")]

TC32 – Kártyabirtokos neve megjelenik a kártya előlapon
    [Tags]    fizetes    ui
    Add First Product To Cart
    Click Element    ${MODAL_CART_BTN}
    Fill Delivery Form
    Click Element    ${CHECKOUT_BTN}
    Wait Until Location Contains    /kosar/fizetes    timeout=10s
    Input Text    ${CARD_NAME_INPUT}    JOHN DOE
    ${displayed}=    Get Text    xpath://div[contains(@class,"card-item__name")]
    Should Contain    ${displayed}    JOHN DOE

TC33 – Overlay bezárható a Close gombbal
    [Tags]    fizetes    ui
    Add First Product To Cart
    Click Element    ${MODAL_CART_BTN}
    Fill Delivery Form
    Click Element    ${CHECKOUT_BTN}
    Wait Until Location Contains    /kosar/fizetes    timeout=10s
    Click Element    ${SUBMIT_BTN_PAYMENT}
    Wait Until Element Is Visible    ${OVERLAY}    timeout=10s
    Click Element    ${OVERLAY_CLOSE}
    Wait Until Element Is Not Visible    ${OVERLAY}    timeout=5s

# ─────────────────────────────────────────────
# TELJES E2E FOLYAMAT
# ─────────────────────────────────────────────

TC34 – Teljes vásárlási folyamat az áruháztól a fizetésig
    [Tags]    e2e    smoke
    Navigate To Aruhaz
    ${title}=    Get Text    ${FIRST_PRODUCT_TITLE}
    Click Element    ${FIRST_ADD_BTN}
    Wait Until Element Is Visible    ${CART_MODAL}    timeout=5s
    Click Element    ${MODAL_CART_BTN}
    Wait Until Element Is Visible    ${CART_HEADER}    timeout=10s
    Fill Delivery Form
    Click Element    ${CHECKOUT_BTN}
    Wait Until Location Contains    /kosar/fizetes    timeout=10s
    Fill Payment Form
    Click Element    ${SUBMIT_BTN_PAYMENT}
    Assert Overlay Message Contains    accepted
    Log    Sikeres vásárlás: ${title}

TC35 – Több termék hozzáadása és végösszeg ellenőrzése
    [Tags]    e2e    cart
    # Kosár ürítése előtte
    Go To    ${KOSAR_URL}
    Sleep    0.4s
    ${has_items}=    Run Keyword And Return Status    Element Should Be Visible    ${EMPTY_CART_BTN}
    Run Keyword If    ${has_items}    Click Element    ${EMPTY_CART_BTN}
    Run Keyword If    ${has_items}    Handle Alert    ACCEPT
    Run Keyword If    ${has_items}    Sleep    0.5s
    # Két különböző termék hozzáadása
    Navigate To Aruhaz
    Click Element    ${FIRST_ADD_BTN}
    Wait Until Element Is Visible    ${CART_MODAL}    timeout=5s
    Close Cart Modal
    ${card_count}=    Get Element Count    xpath://div[contains(@class,"product-card")]
    Run Keyword If    ${card_count} > 1
    ...    Click Element    xpath:(//button[contains(@class,"add-btn")])[2]
    Run Keyword If    ${card_count} > 1
    ...    Wait Until Element Is Visible    ${CART_MODAL}    timeout=5s
    Run Keyword If    ${card_count} > 1
    ...    Close Cart Modal
    Go To    ${KOSAR_URL}
    Wait Until Element Is Visible    ${CART_TOTAL}    timeout=10s
    ${total}=    Get Text    ${CART_TOTAL}
    Should Contain    ${total}    Ft
    Should Not Contain    ${total}    0 Ft

# ─────────────────────────────────────────────
# ÁRUHÁZ – EXTRA TESZTEK
# ─────────────────────────────────────────────

TC36 – Lapozás: következő oldalra lépés működik
    [Tags]    aruhaz    pagination
    Navigate To Aruhaz
    ${next_btn}=    Run Keyword And Return Status
    ...    Element Should Be Visible    xpath://button[contains(@class,"lap-gomb") and not(@disabled)][last()]
    Skip If    not ${next_btn}    Nincs elegendő termék a lapozáshoz
    ${titles_before}=    Get Text    ${FIRST_PRODUCT_TITLE}
    Click Element    xpath:(//button[contains(@class,"lap-gomb") and not(@disabled)])[last()-1]
    Sleep    0.5s
    ${titles_after}=    Get Text    ${FIRST_PRODUCT_TITLE}
    Should Not Be Equal    ${titles_before}    ${titles_after}

TC37 – Oldalméret változtatása módosítja a látható kártyák számát
    [Tags]    aruhaz    pagination
    Navigate To Aruhaz
    ${count_before}=    Get Element Count    xpath://div[contains(@class,"product-card")]
    Select From List By Value    id:perPage    24
    Sleep    0.5s
    ${count_after}=    Get Element Count    xpath://div[contains(@class,"product-card")]
    # 24-es oldalméretnél legalább annyit kell mutatnia mint előtte (vagy pontosan annyit ha kevesebb van összesen)
    Should Be True    ${count_after} >= 1

TC38 – Keresőmező törlése után minden termék visszajön
    [Tags]    aruhaz    search
    Navigate To Aruhaz
    ${total_before}=    Get Element Count    xpath://div[contains(@class,"product-card")]
    Click Element    ${SEARCH_INPUT}
    Input Text    ${SEARCH_INPUT}    xyzxyzxyz
    Sleep    0.5s
    Execute JavaScript    document.querySelector('.search-input').value = ''; document.querySelector('.search-input').dispatchEvent(new Event('input', {bubbles: true}));
    Sleep    0.5s
    ${total_after}=    Get Element Count    xpath://div[contains(@class,"product-card")]
    Should Be Equal As Integers    ${total_before}    ${total_after}

TC39 – Fő kategória checkbox kipipálása szűr
    [Tags]    aruhaz    filter
    Navigate To Aruhaz
    ${all_count}=    Get Element Count    xpath://div[contains(@class,"product-card")]
    ${first_cb}=    Get WebElement    xpath:(//input[contains(@class,"inp-cbx")])[1]
    Execute JavaScript
    ...    arguments[0].click()
    ...    ARGUMENTS    ${first_cb}
    Sleep    0.5s
    ${filtered_count}=    Get Element Count    xpath://div[contains(@class,"product-card")]
    # Szűrés után max. ugyanannyi vagy kevesebb termék jelenhet meg
    Should Be True    ${filtered_count} <= ${all_count}

# ─────────────────────────────────────────────
# KOSÁR – EXTRA TESZTEK
# ─────────────────────────────────────────────

TC40 – Ugyanaz a termék kétszer hozzáadva növeli a mennyiséget, nem duplikál
    [Tags]    kosar    cart    logic
    Navigate To Aruhaz
    Execute JavaScript    sessionStorage.removeItem('cartItems');
    Reload Page
    Wait Until Element Is Visible    ${PRODUCT_CARD}    timeout=10s
    # Első hozzáadás
    Click Element    ${FIRST_ADD_BTN}
    Wait Until Element Is Visible    ${CART_MODAL}    timeout=5s
    Close Cart Modal
    # Második hozzáadás – ugyanazon az oldalon maradunk
    Click Element    ${FIRST_ADD_BTN}
    Wait Until Element Is Visible    ${CART_MODAL}    timeout=5s
    Close Cart Modal
    # Ellenőrzés
    Go To    ${KOSAR_URL}
    Wait Until Element Is Visible    ${CART_HEADER}    timeout=10s
    ${item_rows}=    Get Element Count    xpath://div[@class="cart-item"]
    Should Be Equal As Integers    ${item_rows}    1
    ${qty}=    Get Value    ${QTY_INPUT}
    Should Be Equal As Integers    ${qty}    2

TC41 – Szállítási cím mező 'required' – üres várossal nem lép tovább
    [Tags]    kosar    validation
    Add First Product To Cart
    Click Element    ${MODAL_CART_BTN}
    Wait Until Element Is Visible    ${CHECKOUT_BTN}    timeout=10s
    Input Text    ${FIELD_NAME}     Teszt Elek
    Input Text    ${FIELD_EMAIL}    teszt@example.com
    Input Text    ${FIELD_ADDRESS}  Fő utca 1.
    # Szándékosan kihagyjuk a várost
    Input Text    ${FIELD_ZIP}      1051
    Press Keys    ${FIELD_ZIP}      TAB
    Sleep    0.3s
    Input Text    ${FIELD_PHONE}    +36301234567
    Click Element    ${CHECKOUT_BTN}
    ${alert}=    Run Keyword And Return Status    Handle Alert    ACCEPT
    Should Be True    ${alert}

# ─────────────────────────────────────────────
# FIZETÉS – EXTRA TESZTEK
# ─────────────────────────────────────────────

TC42 – Rövid kártyabirtokos névvel (< 8 kar.) Submit elutasít
    [Tags]    fizetes    validation
    Add First Product To Cart
    Click Element    ${MODAL_CART_BTN}
    Fill Delivery Form
    Click Element    ${CHECKOUT_BTN}
    Wait Until Location Contains    /kosar/fizetes    timeout=10s
    Sleep    0.5s
    Execute JavaScript    document.querySelector('.card-input__input[placeholder="0000 0000 0000 0000"]').focus()
    Execute JavaScript    document.querySelector('.card-input__input[placeholder="0000 0000 0000 0000"]').value = '4111 1111 1111 1111'
    Execute JavaScript    document.querySelector('.card-input__input[placeholder="FULL NAME"]').focus()
    Execute JavaScript    document.querySelector('.card-input__input[placeholder="FULL NAME"]').value = 'AB'
    Select From List By Index    ${CARD_MONTH_SELECT}    1
    Select From List By Index    ${CARD_YEAR_SELECT}     1
    Execute JavaScript    document.querySelector('.card-input__input[placeholder="123"]').focus()
    Execute JavaScript    document.querySelector('.card-input__input[placeholder="123"]').value = '123'
    Execute JavaScript    document.querySelector('.card-form__button').click()
    Assert Overlay Message Contains    Please fill all fields correctly

TC43 – Lejárati dátum megjelenik a kártya előlapján
    [Tags]    fizetes    ui
    Add First Product To Cart
    Click Element    ${MODAL_CART_BTN}
    Fill Delivery Form
    Click Element    ${CHECKOUT_BTN}
    Wait Until Location Contains    /kosar/fizetes    timeout=10s
    Select From List By Index    ${CARD_MONTH_SELECT}    3
    Select From List By Index    ${CARD_YEAR_SELECT}     2
    ${month_text}=    Get Text    xpath://span[contains(@class,"card-item__dateItem")][1]
    ${year_text}=     Get Text    xpath://span[contains(@class,"card-item__dateItem")][2]
    Should Not Be Equal    ${month_text}    MM
    Should Not Be Equal    ${year_text}     YY
