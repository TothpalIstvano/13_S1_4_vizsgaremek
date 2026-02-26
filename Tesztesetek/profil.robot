*** Settings ***
Resource    resources.robot
Test Setup    Open Registration Page
Test Teardown    Close Browser Session

*** Test Cases ***

Szerkesztes Modal Opens And Closes With Megse
    [Documentation]    A szerkesztés gomb megnyitja a modalt, a mégse gomb bezárja.
    Login As Test User
    Navigate To Profile Page
    Open Modal
    Click Element    ${MEGSE_BTN}
    Wait Until Element Is Not Visible    ${SZERK_MODAL}    timeout=5s

Szerkesztes Modal Closes On Backdrop Click
    [Documentation]    A modal háttérre kattintva bezárul.
    Login As Test User
    Navigate To Profile Page
    Open Modal
    Execute JavaScript
    ...    document.querySelector('.szerk-modal-backdrop').dispatchEvent(new MouseEvent('click', {bubbles: true, cancelable: true, clientX: 5, clientY: 5}))
    Wait Until Element Is Not Visible    ${SZERK_MODAL}    timeout=5s

Szerkesztes Form Fields Are Prefilled
    [Documentation]    A szerkesztési form előre ki van töltve a meglévő adatokkal.
    Login As Test User
    Navigate To Profile Page
    Open Modal
    Element Should Be Visible    ${VEZETEKNEV_INPUT}
    Element Should Be Visible    ${KERESZTNEV_INPUT}
    Element Should Be Visible    ${TELEFON_INPUT}
    Element Should Be Visible    ${UTCA_INPUT}
    Element Should Be Visible    ${HAZSZAM_INPUT}
    Element Should Be Visible    ${EMELETAJTO_INPUT}
    ${vezeteknev}=    Get Value    ${VEZETEKNEV_INPUT}
    ${keresztnev}=    Get Value    ${KERESZTNEV_INPUT}
    Log    Vezetéknév: ${vezeteknev}, Keresztnév: ${keresztnev}

Szerkesztes Saves Updated Name Fields
    [Documentation]    A felhasználó megváltoztatja a nevét és elmenti.
    Login As Test User
    Navigate To Profile Page
    Open Modal
    Fill Required Name Fields    Teszt    Elek
    Save And Wait For Modal To Close

Szerkesztes Saves Address Fields
    [Documentation]    A felhasználó módosítja a lakcím adatait és elmenti.
    Login As Test User
    Navigate To Profile Page
    Open Modal
    Fill Required Name Fields

    Clear Element Text    ${UTCA_INPUT}
    Input Text    ${UTCA_INPUT}    Fő utca

    # Trigger Vue reactivity on number input via JS
    Execute JavaScript
    ...    const el = document.getElementById('hazszam');
    ...    const setter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
    ...    setter.call(el, '42');
    ...    el.dispatchEvent(new Event('input', { bubbles: true }));
    ...    el.dispatchEvent(new Event('change', { bubbles: true }));

    # Verify Vue picked it up before saving
    ${val}=    Execute JavaScript    return document.getElementById('hazszam').value
    Log    hazszam value after JS set: ${val}

    Clear Element Text    ${EMELETAJTO_INPUT}
    Input Text    ${EMELETAJTO_INPUT}    2/4
    
    Sleep    0.3s
    Click Element    ${MENTES_BTN}
    Save And Wait For Modal To Close

Szerkesztes City Dropdown Selects A City
    Login As Test User
    Navigate To Profile Page
    Open Modal

    # Wait for the dropdown to be visible
    Wait Until Element Is Visible    id:varos    timeout=10s

    # Scroll dropdown into view
    Execute JavaScript    document.getElementById("varos").scrollIntoView({block:'center'});

    Sleep    5s

    # ⭐ Open PrimeVue dropdown via JS
    Execute JavaScript    document.querySelector('.p-dropdown-trigger').click();

    # Wait until the dropdown panel appears
    Wait Until Page Contains Element    css:.p-dropdown-panel    timeout=10s

    # Wait for filter input to appear
    Wait Until Element Is Visible    css:.p-dropdown-panel input    timeout=10s

    # Type 'Budapest' into filter input using JS
    Execute JavaScript
    ...    const input = document.querySelector('.p-dropdown-panel input');
    ...    input.value = 'Budapest';
    ...    input.dispatchEvent(new Event('input', { bubbles: true }));

    # Wait for the correct option to appear
    Wait Until Element Is Visible
    ...    xpath://li[contains(@class,"p-dropdown-item") and contains(.,"Budapest")]
    ...    timeout=10s

    # Click the option via JS
    Execute JavaScript
    ...    [...document.querySelectorAll('.p-dropdown-item')]
    ...      .find(el => el.textContent.includes('Budapest'))
    ...      .click();

    # Verify the dropdown label updated
    Wait Until Element Contains
    ...    xpath://*[@id="varos"]//*[contains(@class,"p-dropdown-label")]
    ...    Budapest
    ...    timeout=10s

    # ⭐ Click Save button
    Wait Until Element Is Visible    xpath://button[contains(.,"Mentés")]   timeout=10s
    Sleep    0.3s
    Click Element    xpath://button[contains(.,"Mentés")]
    Sleep    3s
    Element Should Not Be Visible    xpath://button[contains(.,"Mentés")]

Szerkesztes Saves Telefon
    [Documentation]    A telefonszám mező szerkeszthető és menthető (kötelező mezőkkel együtt).
    Login As Test User
    Navigate To Profile Page
    Open Modal
    Fill Required Name Fields
    Clear Element Text    ${TELEFON_INPUT}
    Input Text    ${TELEFON_INPUT}    061234567890
    Save And Wait For Modal To Close

Szerkesztes Camera Opens And Closes
    [Documentation]    A kamera gomb elindítja a kamera előnézetet, a mégse leállítja.
    [Setup]    Open Camera Browser And Login
    Open Modal
    Click Element    ${KAMERA_BTN}
    Wait Until Element Is Visible    ${VIDEO_ELEM}    timeout=10s
    Element Should Not Be Visible    ${KAMERA_BTN}
    Click Element    ${MEGSE_KAMERA_BTN}
    Wait Until Element Is Not Visible    ${VIDEO_ELEM}    timeout=5s
    Element Should Be Visible    ${KAMERA_BTN}

Szerkesztes Camera Capture And Upload
    [Documentation]    A felhasználó kamerával fotót készít és beállítja profilképnek.
    [Setup]    Open Camera Browser And Login
    Open Modal
    Click Element    ${KAMERA_BTN}
    Wait Until Element Is Visible    ${VIDEO_ELEM}    timeout=10s
    Sleep    2s
    Click Element    ${FOTOZAS_BTN}
    Wait Until Element Is Visible    ${PROFIL_BEALLITAS_BTN}    timeout=5s
    Element Should Be Visible    xpath://div[contains(@class,"camera-preview")]//img[@alt="preview"]
    Click Element    ${PROFIL_BEALLITAS_BTN}
    Wait Until Element Is Not Visible    ${VIDEO_ELEM}    timeout=15s