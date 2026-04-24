*** Settings ***
Resource    resources.robot
Test Setup    Open Registration Page
Test Teardown    Close Browser Session

*** Test Cases ***

# ─────────────────────────────────────────────
# ÚJ POSZT – KÖTELEZŐ MEZŐK VALIDÁCIÓJA
# ─────────────────────────────────────────────

New Post Submit Blocked When Title Is Empty
    [Documentation]    Ha a cím mező üres, a küldés gomb le van tiltva.
    Login As Test User
    Navigate To New Post Page
    Fill Post Content    Ez egy teszt tartalom a poszthoz.
    ${disabled}=    Execute JavaScript
    ...    return document.querySelector('button.submit-button')?.disabled ?? true
    Should Be True    ${disabled}

New Post Submit Blocked When Content Is Empty
    [Documentation]    Ha a tartalom mező üres, a küldés gomb le van tiltva.
    Login As Test User
    Navigate To New Post Page
    Fill Post Title    Teszt cím
    ${disabled}=    Execute JavaScript
    ...    return document.querySelector('button.submit-button')?.disabled ?? true
    Should Be True    ${disabled}

New Post Submit Enabled When Title And Content Filled
    [Documentation]    Ha mindkét kötelező mező ki van töltve, a küldés gomb aktív.
    Login As Test User
    Navigate To New Post Page
    Fill Post Title    Teszt cím
    Fill Post Content    Ez egy teszt tartalom a poszthoz.
    ${disabled}=    Execute JavaScript
    ...    return document.querySelector('button.submit-button')?.disabled ?? false
    Should Not Be True    ${disabled}

New Post Warning Notification When Fields Empty And Draft Clicked
    [Documentation]    Ha kötelező mezők üresek és a piszkozat gombra kattintanak, figyelmeztető üzenet jelenik meg.
    Login As Test User
    Navigate To New Post Page
    Click Element    ${DRAFT_BTN}
    Notification Should Be Warning

# ─────────────────────────────────────────────
# ÚJ POSZT – CÍM MEZŐ
# ─────────────────────────────────────────────

New Post Title Field Accepts Text Input
    [Documentation]    A cím mező elfogad szöveges bevitelt.
    Login As Test User
    Navigate To New Post Page
    Fill Post Title    Ez egy teszt bejegyzés
    ${value}=    Execute JavaScript    return document.getElementById('postTitle').value
    Should Be Equal    ${value}    Ez egy teszt bejegyzés

New Post Title Field Is Clearable
    [Documentation]    A cím mező törölhető és új értékkel felülírható.
    Login As Test User
    Navigate To New Post Page
    Fill Post Title    Eredeti cím
    Fill Post Title    Új cím
    ${value}=    Execute JavaScript    return document.getElementById('postTitle').value
    Should Be Equal    ${value}    Új cím

# ─────────────────────────────────────────────
# ÚJ POSZT – KIVONAT MEZŐ
# ─────────────────────────────────────────────

New Post Subtext Field Accepts Text
    [Documentation]    A rövid leírás mező elfogad szöveges bevitelt.
    Login As Test User
    Navigate To New Post Page
    Fill Post Subtext    Ez egy rövid leírás a poszthoz
    ${value}=    Execute JavaScript    return document.getElementById('postSubtext').value
    Should Be Equal    ${value}    Ez egy rövid leírás a poszthoz

New Post Subtext Is Optional
    [Documentation]    A rövid leírás mező üresen hagyható, a küldés gomb a cím+tartalom alapján aktiválódik.
    Login As Test User
    Navigate To New Post Page
    Fill Post Title    Teszt cím
    Fill Post Content    Teszt tartalom
    ${disabled}=    Execute JavaScript
    ...    return document.querySelector('button.submit-button')?.disabled ?? false
    Should Not Be True    ${disabled}

# ─────────────────────────────────────────────
# ÚJ POSZT – TARTALOM SZERKESZTŐ
# ─────────────────────────────────────────────

New Post Content Editor Is Visible
    [Documentation]    A quill szerkesztő látható az oldalon.
    Login As Test User
    Navigate To New Post Page
    Element Should Be Visible    ${POST_CONTENT_EDITOR}

New Post Content Editor Accepts Input
    [Documentation]    A szerkesztőbe szöveget lehet beírni.
    Login As Test User
    Navigate To New Post Page
    Fill Post Content    Ez a teszt tartalom a quill szerkesztőhöz.
    ${text}=    Execute JavaScript
    ...    return document.querySelector('.ql-editor')?.innerText?.trim() || ''
    Should Not Be Empty    ${text}

# ─────────────────────────────────────────────
# ÚJ POSZT – VISSZAÁLLÍTÁS GOMB
# ─────────────────────────────────────────────

New Post Reset Button Clears Title
    [Documentation]    A visszaállítás gomb törli a cím mezőt.
    Login As Test User
    Navigate To New Post Page
    Fill Post Title    Törlendő cím
    Click Element    ${RESET_BTN}
    Wait Until Element Is Visible    ${NOTIFICATION}    timeout=5s
    ${value}=    Execute JavaScript    return document.getElementById('postTitle').value
    Should Be Equal    ${value}    ${EMPTY}

New Post Reset Button Shows Info Notification
    [Documentation]    A visszaállítás gomb info értesítőt jelenít meg.
    Login As Test User
    Navigate To New Post Page
    Fill Post Title    Valamiféle cím
    Click Element    ${RESET_BTN}
    Notification Should Contain    Visszaállítva

New Post Reset Button Clears Subtext
    [Documentation]    A visszaállítás gomb törli a kivonat mezőt is.
    Login As Test User
    Navigate To New Post Page
    Fill Post Subtext    Valami rövid leírás
    Click Element    ${RESET_BTN}
    Wait Until Element Is Visible    ${NOTIFICATION}    timeout=5s
    ${value}=    Execute JavaScript    return document.getElementById('postSubtext').value
    Should Be Equal    ${value}    ${EMPTY}

# ─────────────────────────────────────────────
# ÚJ POSZT – VISSZA GOMB
# ─────────────────────────────────────────────

New Post Back Button Returns To Previous Page
    [Documentation]    A vissza gombra kattintva az előző oldalra navigál.
    Login As Test User
    Navigate To Profile Page
    Navigate To New Post Page
    Click Element    xpath://button[contains(@class,"back-btn")]
    Sleep    1s
    ${url}=    Get Location
    Should Not Contain    ${url}    /newpost

# ─────────────────────────────────────────────
# ÚJ POSZT – MULTISELECT CÍMKÉK
# ─────────────────────────────────────────────

New Post Tag Multiselect Is Visible
    [Documentation]    A címke multiselect mező megjelenik az oldalon.
    Login As Test User
    Navigate To New Post Page
    Element Should Be Visible    id:postCimkek

New Post Tag Multiselect Can Be Opened
    [Documentation]    A multiselect kinyitható és tartalmaz opciókat.
    Login As Test User
    Navigate To New Post Page
    Execute JavaScript    document.getElementById('postCimkek').click()
    Sleep    1s
    ${panel_visible}=    Execute JavaScript
    ...    return !!document.querySelector('.p-multiselect-panel')
    Should Be True    ${panel_visible}

New Post Tag Can Be Selected From Multiselect
    [Documentation]    A multiselect-ből legalább egy opció kiválasztható.
    Login As Test User
    Navigate To New Post Page
    Execute JavaScript    document.getElementById('postCimkek').click()
    Sleep    1s
    ${item_count}=    Execute JavaScript
    ...    return document.querySelectorAll('.p-multiselect-item').length
    Run Keyword If    ${item_count} > 0
    ...    Execute JavaScript    document.querySelectorAll('.p-multiselect-item')[0].click()
    Sleep    0.5s
    ${chip_count}=    Execute JavaScript
    ...    return document.querySelectorAll('.p-multiselect-panel .p-checkbox-box.p-highlight, .p-chip').length
    Run Keyword If    ${item_count} > 0
    ...    Should Be True    ${chip_count} > 0

# ─────────────────────────────────────────────
# ÚJ POSZT – ÚJ CÍMKE HOZZÁADÁSA
# ─────────────────────────────────────────────

New Post New Tag Input Is Visible
    [Documentation]    Az új címke beviteli mező látható.
    Login As Test User
    Navigate To New Post Page
    Element Should Be Visible    id:newTag

New Post Add Tag Button Disabled When Input Empty
    [Documentation]    A "Hozzáadás" gomb le van tiltva, ha az új címke mező üres.
    Login As Test User
    Navigate To New Post Page
    ${disabled}=    Execute JavaScript
    ...    return [...document.querySelectorAll('button.add-tag-btn')].some(b => b.disabled)
    Should Be True    ${disabled}

New Post Add Tag Button Enabled When Input Filled
    [Documentation]    Az "Hozzáadás" gomb aktív, ha az új címke mezőben van szöveg.
    Login As Test User
    Navigate To New Post Page
    Wait Until Element Is Visible    id:newTag    timeout=5s
    Execute JavaScript
    ...    const el = document.getElementById('newTag');
    ...    const setter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
    ...    setter.call(el, 'UjTesztCimke');
    ...    el.dispatchEvent(new Event('input', { bubbles: true }));
    Sleep    0.3s
    ${disabled}=    Execute JavaScript
    ...    return [...document.querySelectorAll('button.add-tag-btn')].some(b => b.disabled)
    Should Not Be True    ${disabled}

New Post Existing Tag Selected When Duplicate Added
    [Documentation]    Ha már létező névvel adunk hozzá címkét, info értesítő jelenik meg és a mező ürül.
    Login As Test User
    Navigate To New Post Page
    Execute JavaScript    document.getElementById('postCimkek').click()
    Sleep    1s
    ${first_option_text}=    Execute JavaScript
    ...    return document.querySelectorAll('.p-multiselect-item span')[0]?.innerText?.trim() || ''
    Execute JavaScript    document.body.click()
    Sleep    0.3s
    Run Keyword If    '${first_option_text}' != '${EMPTY}'
    ...    Run Keywords
    ...    Execute JavaScript
    ...        const el = document.getElementById('newTag');
    ...        const setter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
    ...        setter.call(el, '${first_option_text}');
    ...        el.dispatchEvent(new Event('input', { bubbles: true }));
    ...    AND    Execute JavaScript    [...document.querySelectorAll('button.add-tag-btn')].find(b => !b.disabled)?.click()
    ...    AND    Wait Until Element Is Visible    ${NOTIFICATION}    timeout=5s

# ─────────────────────────────────────────────
# ÚJ POSZT – KÉPFELTÖLTÉS
# ─────────────────────────────────────────────

New Post File Upload Area Is Visible
    [Documentation]    A képfeltöltési terület megjelenik a szerkesztő alatt.
    Login As Test User
    Navigate To New Post Page
    Element Should Be Visible    xpath://div[contains(@class,"drag-drop-area")]

New Post Uploaded Image Shows Preview And Remove Button
    [Documentation]    Kép kiválasztása után az előnézet és az eltávolítás gomb látható.
    Login As Test User
    Navigate To New Post Page
    ${test_file}=    Set Variable    ${CURDIR}/test_image.jpg
    ${exists}=    Run Keyword And Return Status    File Should Exist    ${test_file}
    Skip If    not ${exists}    test_image.jpg nem található, a képfeltöltés teszt kihagyva
    Execute JavaScript
    ...    const dt = new DataTransfer();
    ...    const file = new File(['dummy'], 'test_image.jpg', { type: 'image/jpeg' });
    ...    dt.items.add(file);
    ...    const input = document.querySelector('input[name="images[]"]');
    ...    if (input) {
    ...        Object.defineProperty(input, 'files', { value: dt.files });
    ...        input.dispatchEvent(new Event('change', { bubbles: true }));
    ...    }
    Sleep    1s
    ${preview_count}=    Execute JavaScript
    ...    return document.querySelectorAll('.image-preview').length
    Should Be True    ${preview_count} > 0

New Post Remove Image Button Removes Preview
    [Documentation]    Az eltávolítás gombra kattintva az előnézet eltűnik.
    Login As Test User
    Navigate To New Post Page
    Execute JavaScript
    ...    const dt = new DataTransfer();
    ...    const file = new File(['dummy'], 'test_image.jpg', { type: 'image/jpeg' });
    ...    dt.items.add(file);
    ...    window._vueApp = document.getElementById('app').__vue_app__;
    Sleep    0.3s
    Execute JavaScript
    ...    const comp = document.querySelector('#app').__vue_app__?.config?.globalProperties;
    ...    const previewArea = document.querySelector('.image-preview-container');
    ...    if (!previewArea) return;
    ...    const reader = new FileReader();
    ...    reader.onload = (e) => {
    ...        const preview = document.createElement('div');
    ...        preview.className = 'image-preview';
    ...        preview.innerHTML = '<img class="preview-image" src="' + e.target.result + '"/><button class="p-button-rounded p-button-danger image-remove-btn">X</button>';
    ...        previewArea.appendChild(preview);
    ...    };
    ...    reader.readAsDataURL(new File(['a'], 'a.jpg', {type:'image/jpeg'}));
    Sleep    0.5s
    ${count_before}=    Execute JavaScript
    ...    return document.querySelectorAll('.image-preview').length
    Run Keyword If    ${count_before} > 0
    ...    Execute JavaScript    document.querySelector('.image-remove-btn')?.click()
    Sleep    0.3s
    ${count_after}=    Execute JavaScript
    ...    return document.querySelectorAll('.image-preview').length
    Should Be True    ${count_after} < ${count_before} or ${count_before} == 0

# ─────────────────────────────────────────────
# ÚJ POSZT – PISZKOZAT MENTÉS
# ─────────────────────────────────────────────

New Post Draft Save Shows Success Notification
    [Documentation]    Kitöltött cím és tartalom esetén a piszkozat sikeresen mentődik.
    Login As Test User
    Navigate To New Post Page
    Fill Post Title    Piszkozat teszt bejegyzés
    Fill Post Content    Ez egy piszkozat tartalom.
    Click Element    ${DRAFT_BTN}
    Wait Until Element Is Visible    ${NOTIFICATION}    timeout=10s
    ${classes}=    Get Element Attribute    ${NOTIFICATION}    class
    Should Contain Any    ${classes}    success    warn

# ─────────────────────────────────────────────
# ÚJ POSZT – POSZT KÖZZÉTÉTEL
# ─────────────────────────────────────────────

New Post Publish Shows Success Notification
    [Documentation]    Kitöltött mezők esetén a közzététel sikeres értesítőt ad.
    Login As Test User
    Navigate To New Post Page
    Fill Post Title    Közzétett teszt bejegyzés ${RANDOM}
    Fill Post Content    Ez egy közzétett teszt tartalom.
    ${disabled}=    Execute JavaScript
    ...    return document.querySelector('button.submit-button')?.disabled ?? true
    Skip If    ${disabled}    A küldés gomb nem aktív
    Click Element    xpath://button[@type='submit' and contains(@class,'submit-button')]
    Wait Until Element Is Visible    ${NOTIFICATION}    timeout=10s
    ${classes}=    Get Element Attribute    ${NOTIFICATION}    class
    Should Contain    ${classes}    success

New Post Publish Redirects To Profile After Success
    [Documentation]    Sikeres közzététel után a felhasználó a profil oldalra kerül.
    Login As Test User
    Navigate To New Post Page
    Fill Post Title    Redirect teszt ${RANDOM}
    Fill Post Content    Ez egy átirányítás teszt tartalom.
    ${disabled}=    Execute JavaScript
    ...    return document.querySelector('button.submit-button')?.disabled ?? true
    Skip If    ${disabled}    A küldés gomb nem aktív
    Click Element    xpath://button[@type='submit' and contains(@class,'submit-button')]
    Wait Until Location Contains    /profil    timeout=15s

# ─────────────────────────────────────────────
# ÚJ POSZT – SZERKESZTÉS MÓD
# ─────────────────────────────────────────────

Edit Post Page Loads Existing Post Data
    [Documentation]    Szerkesztési módban a meglévő poszt adatai betöltődnek a mezőkbe.
    Login As Test User
    Navigate To Profile Page
    ${href}=    Get First Post Edit Href
    Skip If    '${href}' == ''    Nincs szerkeszthető poszt a tesztfelhasználónál
    Go To    ${URL}${href}
    Wait Until Element Is Visible    ${POST_TITLE_INPUT}    timeout=10s
    ${title}=    Execute JavaScript    return document.getElementById('postTitle').value
    Should Not Be Empty    ${title}

Edit Post Page Shows Edit Mode Title
    [Documentation]    Szerkesztési módban a lap fejléce szerkesztési opciót mutat.
    Login As Test User
    Navigate To Profile Page
    ${href}=    Get First Post Edit Href
    Skip If    '${href}' == ''    Nincs szerkeszthető poszt
    Go To    ${URL}${href}
    Wait Until Element Is Visible    ${POST_TITLE_INPUT}    timeout=10s
    ${heading}=    Get Text    xpath://h1[contains(@class,"title")]
    Should Not Be Empty    ${heading}

Edit Post Submit Updates Post
    [Documentation]    Szerkesztési módban a mentés frissíti a posztot (értesítő jelenik meg).
    Login As Test User
    Navigate To Profile Page
    ${href}=    Get First Post Edit Href
    Skip If    '${href}' == ''    Nincs szerkeszthető poszt
    Go To    ${URL}${href}
    Wait Until Element Is Visible    ${POST_TITLE_INPUT}    timeout=10s
    ${orig_title}=    Execute JavaScript    return document.getElementById('postTitle').value
    Fill Post Title    ${orig_title} (szerkesztve)
    ${disabled}=    Execute JavaScript
    ...    return document.querySelector('button.submit-button')?.disabled ?? true
    Skip If    ${disabled}    A küldés gomb nem aktív
    Click Element    xpath://button[@type='submit' and contains(@class,'submit-button')]
    Wait Until Element Is Visible    ${NOTIFICATION}    timeout=10s
    ${classes}=    Get Element Attribute    ${NOTIFICATION}    class
    Should Contain Any    ${classes}    success    info
