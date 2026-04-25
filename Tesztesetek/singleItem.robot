*** Settings ***
Library           SeleniumLibrary
Resource          resources.robot

Suite Setup       Open Browser    ${URL}    ${BROWSER}
Suite Teardown    Close Browser

*** Variables ***
${BACK_BTN}                 xpath://button[contains(@class,"back-btn")]
${MAIN_IMAGE}               xpath://img[contains(@class,"main-image")]
${GALLERY_LEFT}             xpath://button[contains(@class,"gallery-arrow left")]
${GALLERY_RIGHT}            xpath://button[contains(@class,"gallery-arrow right")]
${THUMBNAILS}               xpath://div[contains(@class,"thumbnails")]
${COLOR_BTN_FIRST}          xpath:(//button[contains(@class,"color-btn")])[1]
${COLOR_BTN_SECOND}         xpath:(//button[contains(@class,"color-btn")])[2]
${QTY_MINUS_ITEM}           xpath://div[contains(@class,"qty-control")]//button[contains(.,"−")]
${QTY_PLUS_ITEM}            xpath://div[contains(@class,"qty-control")]//button[contains(.,"+")] 
${QTY_INPUT_ITEM}           xpath://input[contains(@class,"qty-input")]
${ADD_TO_CART_BTN}          xpath://button[contains(@class,"add-to-cart-btn")]
${SELECTED_COLOR_NAME}      xpath://span[contains(@class,"selected-color-name")]
${PRODUCT_PRICE_DETAIL}     xpath://p[contains(@class,"price")]
${PRODUCT_TITLE_H1}         xpath://div[contains(@class,"product-info")]//h1


*** Keywords ***
Navigate To First Product
    Navigate To Aruhaz
    Click Element    ${PRODUCT_CARD}
    Wait Until Location Contains    /aruhaz/    timeout=10s


*** Test Cases ***

# ═══════════════════════════════════════════════════
#  ALAP MEGJELENÉS
# ═══════════════════════════════════════════════════

Termék neve, ára és leírása megjelenik
    Navigate To First Product
    Wait Until Element Is Visible    ${PRODUCT_TITLE_H1}    timeout=5s
    Element Should Be Visible    ${PRODUCT_TITLE_H1}
    Element Should Be Visible    ${PRODUCT_PRICE_DETAIL}
    Element Should Be Visible    xpath://div[contains(@class,"description")]

Vissza gomb visszanavigál az áruházba
    Navigate To First Product
    Wait Until Element Is Visible    ${BACK_BTN}    timeout=5s
    Click Element    ${BACK_BTN}
    Wait Until Location Contains    /aruhaz    timeout=10s
    ${url}=    Get Location
    Should Match Regexp    ${url}    .*/aruhaz/?$

# ═══════════════════════════════════════════════════
#  GALÉRIA
# ═══════════════════════════════════════════════════

Főkép látható és src nem üres
    Navigate To First Product
    Wait Until Element Is Visible    ${MAIN_IMAGE}    timeout=8s
    ${src}=    Get Element Attribute    ${MAIN_IMAGE}    src
    Should Not Be Empty    ${src}

Jobb nyíl megváltoztatja a főképet
    Navigate To First Product
    ${has_arrows}=    Run Keyword And Return Status
    ...    Element Should Be Visible    ${GALLERY_RIGHT}
    Pass Execution If    not ${has_arrows}    Csak egy kép van
    ${src_before}=    Get Element Attribute    ${MAIN_IMAGE}    src
    Click Element    ${GALLERY_RIGHT}
    Sleep    0.4s
    ${src_after}=    Get Element Attribute    ${MAIN_IMAGE}    src
    Should Not Be Equal    ${src_before}    ${src_after}

Bal nyíl visszalép az előző képre
    Navigate To First Product
    ${has_arrows}=    Run Keyword And Return Status
    ...    Element Should Be Visible    ${GALLERY_LEFT}
    Pass Execution If    not ${has_arrows}    Csak egy kép van
    Click Element    ${GALLERY_RIGHT}
    Sleep    0.4s
    ${src_after_right}=    Get Element Attribute    ${MAIN_IMAGE}    src
    Click Element    ${GALLERY_LEFT}
    Sleep    0.4s
    ${src_after_left}=    Get Element Attribute    ${MAIN_IMAGE}    src
    Should Not Be Equal    ${src_after_right}    ${src_after_left}

Thumbnail kattintásra frissíti a főképet
    Navigate To First Product
    ${has_thumbs}=    Run Keyword And Return Status
    ...    Element Should Be Visible    ${THUMBNAILS}
    Pass Execution If    not ${has_thumbs}    Csak egy kép van
    ${expected_src}=    Get Element Attribute    xpath:(//div[contains(@class,"thumb-wrap")])[2]//img    src
    Click Element    xpath:(//div[contains(@class,"thumb-wrap")])[2]
    Sleep    0.4s
    ${main_src}=    Get Element Attribute    ${MAIN_IMAGE}    src
    Should Be Equal    ${main_src}    ${expected_src}

Aktív thumbnail „active" osztályt kap
    Navigate To First Product
    ${has_thumbs}=    Run Keyword And Return Status
    ...    Element Should Be Visible    ${THUMBNAILS}
    Pass Execution If    not ${has_thumbs}    Csak egy kép van
    Click Element    xpath:(//div[contains(@class,"thumb-wrap")])[2]
    Sleep    0.3s
    ${classes}=    Get Element Attribute    xpath:(//div[contains(@class,"thumb-wrap")])[2]    class
    Should Contain    ${classes}    active

# ═══════════════════════════════════════════════════
#  SZÍN VÁLASZTÓ
# ═══════════════════════════════════════════════════

Szín kiválasztása frissíti a feliratot
    Navigate To First Product
    ${has_colors}=    Run Keyword And Return Status
    ...    Element Should Be Visible    ${COLOR_BTN_SECOND}
    Pass Execution If    not ${has_colors}    Kevesebb mint két szín opció van
    ${name_before}=    Get Text    ${SELECTED_COLOR_NAME}
    Click Element    ${COLOR_BTN_SECOND}
    Sleep    0.2s
    ${name_after}=    Get Text    ${SELECTED_COLOR_NAME}
    Should Not Be Equal    ${name_before}    ${name_after}

Aktív szín gomb „active" osztályt kap
    Navigate To First Product
    ${has_colors}=    Run Keyword And Return Status
    ...    Element Should Be Visible    ${COLOR_BTN_FIRST}
    Pass Execution If    not ${has_colors}    Nincs szín opció
    Click Element    ${COLOR_BTN_FIRST}
    Sleep    0.2s
    ${classes}=    Get Element Attribute    ${COLOR_BTN_FIRST}    class
    Should Contain    ${classes}    active

# ═══════════════════════════════════════════════════
#  MENNYISÉG
# ═══════════════════════════════════════════════════

Plusz gomb növeli a mennyiséget
    Navigate To First Product
    Wait Until Element Is Visible    ${QTY_PLUS_ITEM}    timeout=5s
    ${before}=    Get Value    ${QTY_INPUT_ITEM}
    Click Element    ${QTY_PLUS_ITEM}
    Sleep    0.2s
    ${after}=    Get Value    ${QTY_INPUT_ITEM}
    Should Be True    int('${after}') == int('${before}') + 1

Mínusz gomb nem csökkent 1 alá
    Navigate To First Product
    Wait Until Element Is Visible    ${QTY_MINUS_ITEM}    timeout=5s
    Execute JavaScript
    ...    const el = document.querySelector('.qty-input');
    ...    const s = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype,'value').set;
    ...    s.call(el, '1'); el.dispatchEvent(new Event('input',{bubbles:true}));
    Click Element    ${QTY_MINUS_ITEM}
    Sleep    0.2s
    ${val}=    Get Value    ${QTY_INPUT_ITEM}
    Should Be Equal As Integers    ${val}    1

Plusz gomb nem lép a raktárkészlet fölé
    Navigate To First Product
    Wait Until Element Is Visible    ${QTY_INPUT_ITEM}    timeout=5s
    ${max}=    Get Element Attribute    ${QTY_INPUT_ITEM}    max
    Pass Execution If    '${max}' == 'None' or '${max}' == ''    Nincs max attribútum
    Execute JavaScript
    ...    const el = document.querySelector('.qty-input');
    ...    const s = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype,'value').set;
    ...    s.call(el, '${max}'); el.dispatchEvent(new Event('input',{bubbles:true}));
    Click Element    ${QTY_PLUS_ITEM}
    Sleep    0.2s
    ${val}=    Get Value    ${QTY_INPUT_ITEM}
    Should Be Equal As Integers    ${val}    ${max}

# ═══════════════════════════════════════════════════
#  KOSÁRBA GOMB
# ═══════════════════════════════════════════════════

Kosárba teszem gomb megnyitja a CartModalt
    Navigate To First Product
    Wait Until Element Is Visible    ${ADD_TO_CART_BTN}    timeout=5s
    ${disabled}=    Get Element Attribute    ${ADD_TO_CART_BTN}    disabled
    Pass Execution If    '${disabled}' == 'true'    A termék elfogyott
    Click Element    ${ADD_TO_CART_BTN}
    Wait Until Element Is Visible    ${CART_MODAL}    timeout=8s

Kosárba adás után a mennyiség visszaáll 1-re
    Navigate To First Product
    Wait Until Element Is Visible    ${QTY_PLUS_ITEM}    timeout=5s
    Click Element    ${QTY_PLUS_ITEM}
    Click Element    ${QTY_PLUS_ITEM}
    ${disabled}=    Get Element Attribute    ${ADD_TO_CART_BTN}    disabled
    Pass Execution If    '${disabled}' == 'true'    A termék elfogyott
    Click Element    ${ADD_TO_CART_BTN}
    Wait Until Element Is Visible    ${CART_MODAL}    timeout=8s
    Click Element    ${MODAL_CONTINUE_BTN}
    Wait Until Element Is Not Visible    ${CART_MODAL}    timeout=5s
    ${val}=    Get Value    ${QTY_INPUT_ITEM}
    Should Be Equal As Integers    ${val}    1

Elfogyott terméknél a gomb disabled
    Navigate To Aruhaz
    ${out_of_stock}=    Run Keyword And Return Status
    ...    Element Should Be Visible    xpath://p[contains(@class,"stock-info out")]
    Pass Execution If    not ${out_of_stock}    Nincs elfogyott termék az áruházban
    Click Element    xpath:(//p[contains(@class,"stock-info out")])[1]/ancestor::div[contains(@class,"product-card")]
    Wait Until Location Contains    /aruhaz/    timeout=10s
    Element Should Be Disabled    ${ADD_TO_CART_BTN}