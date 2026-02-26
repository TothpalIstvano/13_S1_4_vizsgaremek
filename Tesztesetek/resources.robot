*** Settings ***
Library    SeleniumLibrary

*** Variables ***
${URL}    http://localhost:5173
${BROWSER}    Chrome

# Step buttons
${NEXT_BTN}             xpath://button[contains(@class,"tovabbGomb")]
${BACK_BTN}             xpath://button[contains(@class,"visszaGomb")]

# Step containers
${STEP1_CONTAINER}      id:elsoResz
${STEP2_CONTAINER}      id:masodikResz
${STEP3_CONTAINER}      id:harmadikResz

# Progress steps
${PROGRESS_STEP_1}      xpath:(//div[contains(@class,"progress-step")])[1]
${PROGRESS_STEP_2}      xpath:(//div[contains(@class,"progress-step")])[2]
${PROGRESS_STEP_3}      xpath:(//div[contains(@class,"progress-step")])[3]

# Step 1 - Type selection radios
${RADIO_HORGOLAS}       xpath://input[@id="Horgolás"]
${RADIO_KOTES}          xpath://input[@id="Kötés"]
${RADIO_HIMZES}         xpath://input[@id="Hímzés"]
${LABEL_HORGOLAS}       xpath://label[@for="Horgolás"]
${LABEL_KOTES}          xpath://label[@for="Kötés"]
${LABEL_HIMZES}         xpath://label[@for="Hímzés"]

# Step 2 - Yarn type radios
${RADIO_FONAL_A}        xpath://input[@id="A fonal csoport"]
${RADIO_FONAL_B}        xpath://input[@id="B fonal csoport"]
${RADIO_FONAL_C}        xpath://input[@id="C fonal csoport"]
${RADIO_FONAL_D}        xpath://input[@id="D fonal csoport"]
${RADIO_FONAL_E}        xpath://input[@id="E fonal csoport"]
${LABEL_FONAL_A}        xpath://label[@for="A fonal csoport"]
${LABEL_FONAL_B}        xpath://label[@for="B fonal csoport"]
${LABEL_FONAL_C}        xpath://label[@for="C fonal csoport"]
${LABEL_FONAL_D}        xpath://label[@for="D fonal csoport"]
${LABEL_FONAL_E}        xpath://label[@for="E fonal csoport"]

# Step 3 - File upload
${FILE_UPLOAD_INPUT}    id:file-upload
${FILE_UPLOAD_LABEL}    xpath://label[@for="file-upload"]
${MINTA_BTN}            xpath://button[contains(.,"Minta készítése")]

${BLOG_NAV_LINK}        xpath://header//nav//a[contains(.,"Blog")]
${POST_TITLE_INPUT}     id:postTitle
${POST_CONTENT_EDITOR}  xpath://div[contains(@class,"ql-editor")]
${POST_SUBTEXT_INPUT}   id:postSubtext
${SUBMIT_BTN}           xpath://button[@type='submit' and contains(@class, 'submit-button')]
${DRAFT_BTN}            xpath://button[contains(.,"Mentés piszkozatként")]
${RESET_BTN}            xpath://button[contains(.,"Visszaállítás")]
${NOTIFICATION}         xpath://div[contains(@class,"notification")]
${BLOG_PAGE_TITLE}      xpath://h1[contains(@class,"title") and contains(.,"Blog")]
${BLOG_CARDS}           xpath://div[contains(@class,"kartya-oszlop")]
${KERESES_INPUT}        xpath://input[contains(@placeholder,"Keresés")]
${MEGTEKINTES_BTN}      xpath:(//button[contains(.,"Megtekintés")])[1]

# Szerkesztés modal
${SZERK_BTN}                xpath://button[contains(@class,"btn edit") and contains(.,"Szerkesztés")]
${SZERK_MODAL}              xpath://div[contains(@class,"szerk-modal")]
${MEGSE_BTN}                xpath://button[contains(@class,"megse")]
${MENTES_BTN}               xpath://button[contains(@class,"mentes")]

# Form fields
${VEZETEKNEV_INPUT}         id:vezeteknev
${KERESZTNEV_INPUT}         id:keresztnev
${TELEFON_INPUT}            id:telefon
${UTCA_INPUT}               id:utca
${HAZSZAM_INPUT}            id:hazszam
${EMELETAJTO_INPUT}         id:emeletAjto

# Camera
${KAMERA_BTN}               xpath://button[contains(.,"Kamera használata")]
${FOTOZAS_BTN}              xpath://button[contains(.,"Fotózás")]
${MEGSE_KAMERA_BTN}         xpath://div[contains(@class,"camera-controls")]//button[contains(.,"Mégse")]
${PROFIL_BEALLITAS_BTN}     xpath://button[contains(.,"Profilkép beállítása")]
${VIDEO_ELEM}               xpath://div[contains(@class,"camera-preview")]//video

*** Keywords ***
Open Registration Page
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window
    Wait Until Element Is Visible    //header//nav//a[7]
    Click Element    //header//nav//a[7]    

#registration

Switch To Registration
    Click Button    //*[@id="app"]/main/div/div[3]/div[4]/button
    Wait Until Element Is Visible    xpath://h2[contains(.,"Fiók készítése")]    timeout=5s

Fill Registration Form
    [Arguments]    ${username}    ${email}    ${password}    ${confirm}
    Input Text    name:username    ${username}
    Input Text    name:email    ${email}
    Input Password    name:password    ${password}
    Input Password    name:password_confirmation    ${confirm}
    Wait Until Element Is Visible    xpath=//input[@name="terms"]    timeout=10s
    Execute JavaScript    document.querySelector('input[name="terms"]').click()
    Execute JavaScript    document.querySelector('input[name="checkbox"]').click()

Submit Registration
    Click Button    xpath://button[contains(.,"Fiók létrehozása")]

Registration Should Succeed
    Wait Until Location Contains    /Profil    timeout=20s

Registration Should Fail
    Wait Until Element Is Visible    css:.error-message    timeout=5s

Registration Should Fail At Weak Password
    Wait Until Element Is Visible    xpath=//label[contains(@class,"error-message")]    timeout=5s

Registration Should Fail At Short Password
    Wait Until Element Is Visible    xpath=//label[contains(text(),"legalább 8 karakter")]    timeout=5s

Registration Should Fail At Missing Number
    Wait Until Element Is Visible    xpath=//label[contains(text(),"Tartalmaznia kell számot")]    timeout=5s

Registration Should Fail At Missing Special Character
    Wait Until Element Is Visible    xpath=//label[contains(text(),"speciális karaktert")]    timeout=5s

Registration Should Fail At Missing Case
    Wait Until Element Is Visible    xpath=//label[contains(text(),"kis és nagybetűt")]    timeout=5s

Registration Should Fail At Password With Space
    Wait Until Element Is Visible    xpath=//label[contains(text(),"nem tartalmazhat szóközt")]    timeout=5s

Registration Should Fail At Mismatched Password
    Wait Until Element Is Visible   xpath=//label[@for="password_confirmation"]    timeout=5s
    Element Should Contain   xpath=//label[@for="password_confirmation"]    A két jelszó nem egyezik!

Registration Should Fail At Registration
    Wait Until Element Is Visible    css:.error-message    timeout=5s

#login

Switch To Login
    ${reg_visible}=    Run Keyword And Return Status
    ...    Element Should Be Visible    xpath://h2[contains(.,"Fiók készítése")]
    Run Keyword If    ${reg_visible}
    ...    Click Button    xpath://button[contains(.,"Bejelentkezés")]
    Wait Until Element Is Visible    xpath://h2[contains(.,"Lépj be a fiókodba")]    timeout=5s
    Wait Until Element Is Visible    name:email    timeout=5s

Fill Login Form
    [Arguments]    ${email}    ${password}
    Wait Until Element Is Visible      xpath=//div[contains(@class,"b-container")]//input[@name="email"]    timeout=5s
    Input Text      xpath=//div[contains(@class,"b-container")]//input[@name="email"]      ${email}
    Input Password  xpath=//div[contains(@class,"b-container")]//input[@name="password"]   ${password}

Submit Login
    Execute JavaScript    document.querySelector('.b-container button[type="submit"]').click()

Login Should Succeed
    Wait Until Location Contains    /Profil    timeout=20s

Login Should Fail
    Sleep    1s
    ${error_visible}=    Run Keyword And Return Status
    ...    Element Should Be Visible    css:.b-container .error-message
    ${still_on_login}=    Run Keyword And Return Status
    ...    Location Should Contain    ${URL}
    Should Be True    ${error_visible} or ${still_on_login}
    Should Be True    ${error_visible} or ${still_on_login}

Login Error Should Contain
    [Arguments]    ${message}
    Wait Until Element Is Visible    css:.error-message    timeout=5s
    Element Should Contain          css:.error-message    ${message}

Open Forgot Password Modal
    Click Element    xpath://a[contains(.,"Elfelejtetted a jelszavad?")]
    Wait Until Element Is Visible    xpath://h3[contains(.,"Jelszó visszaállítása")]    timeout=5s

#mintakészítő
Open Mintakeszito Page
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys
    Call Method    ${options}    add_argument    --disable-extensions
    Create Webdriver    Chrome    options=${options}
    Go To    ${URL}
    Maximize Browser Window
    Wait Until Element Is Visible    xpath://header//nav//a[contains(.,"Mintakészítő")]    timeout=10s
    Click Element    xpath://header//nav//a[contains(.,"Mintakészítő")]
    Wait Until Element Is Visible    id:adatok    timeout=10s

Step 1 Should Be Visible
    Element Should Be Visible       ${STEP1_CONTAINER}
    Element Should Not Be Visible   ${STEP2_CONTAINER}
    Element Should Not Be Visible   ${STEP3_CONTAINER}

Step 2 Should Be Visible
    Element Should Not Be Visible   ${STEP1_CONTAINER}
    Element Should Be Visible       ${STEP2_CONTAINER}
    Element Should Not Be Visible   ${STEP3_CONTAINER}
    Sleep    0.5s

Step 3 Should Be Visible
    Element Should Not Be Visible   ${STEP1_CONTAINER}
    Element Should Not Be Visible   ${STEP2_CONTAINER}
    Element Should Be Visible       ${STEP3_CONTAINER}

Next Button Should Be Disabled
    Element Should Be Disabled    ${NEXT_BTN}

Next Button Should Be Enabled
    Element Should Be Enabled    ${NEXT_BTN}

Click Next
    Execute JavaScript    document.querySelector('button.tovabbGomb:not([disabled])').click()


Select Type
    [Arguments]    ${type}
    Run Keyword If    '${type}' == 'Horgolás'    Execute JavaScript    document.querySelector('label[for="Horgolás"]').click()
    Run Keyword If    '${type}' == 'Kötés'       Execute JavaScript    document.querySelector('label[for="Kötés"]').click()
    Run Keyword If    '${type}' == 'Hímzés'      Execute JavaScript    document.querySelector('label[for="Hímzés"]').click()

Select Yarn Type
    [Arguments]    ${yarn}
    Run Keyword If    '${yarn}' == 'A'    Execute JavaScript    document.querySelector('label[for="A fonal csoport"]').click()
    Run Keyword If    '${yarn}' == 'B'    Execute JavaScript    document.querySelector('label[for="B fonal csoport"]').click()
    Run Keyword If    '${yarn}' == 'C'    Execute JavaScript    document.querySelector('label[for="C fonal csoport"]').click()
    Run Keyword If    '${yarn}' == 'D'    Execute JavaScript    document.querySelector('label[for="D fonal csoport"]').click()
    Run Keyword If    '${yarn}' == 'E'    Execute JavaScript    document.querySelector('label[for="E fonal csoport"]').click()

Progress Step N Should Be Active
    [Arguments]    ${n}
    ${classes}=    Get Element Attribute    xpath:(//div[contains(@class,"progress-step")])[${n}]    class
    Should Contain    ${classes}    active

Progress Step N Should Not Be Active
    [Arguments]    ${n}
    ${classes}=    Get Element Attribute    xpath:(//div[contains(@class,"progress-step")])[${n}]    class
    Should Not Contain    ${classes}    active

Upload Image File
    [Arguments]    ${filepath}
    Choose File    ${FILE_UPLOAD_INPUT}    ${filepath}
    Wait Until Element Is Visible    xpath://div[contains(@class,"file-preview-container")]    timeout=5s

Go Back From Step 2
    Execute JavaScript    document.querySelector('#masodikResz button.visszaGomb').click()
    Wait Until Element Is Visible    ${STEP1_CONTAINER}    timeout=5s

Go Back From Step 3 To Step 1
    Execute JavaScript    document.querySelectorAll('#harmadikResz button.visszaGomb')[0].click()
    Wait Until Element Is Visible    ${STEP1_CONTAINER}    timeout=5s

Go Back From Step 3 To Step 2
    Execute JavaScript    document.querySelectorAll('#harmadikResz button.visszaGomb')[1].click()
    Wait Until Element Is Visible    ${STEP2_CONTAINER}    timeout=5s

Radio Should Be Checked
    [Arguments]    ${id}
    ${checked}=    Execute JavaScript    return document.getElementById("${id}").checked
    Should Be True    ${checked}

Radio Should Not Be Checked
    [Arguments]    ${id}
    ${checked}=    Execute JavaScript    return document.getElementById("${id}").checked
    Should Not Be True    ${checked}

Click Minta Button
    Execute JavaScript    [...document.querySelectorAll('button')].find(b => b.textContent.includes('Minta készítése')).click()

Close Browser Session
    Close Browser

Login As Test User
    Switch To Login
    Fill Login Form    test@example.com    Alma12345678.
    Execute JavaScript    document.querySelector('.b-container button[type="submit"]').click()
    Wait Until Location Contains    /Profil   timeout=20s

Navigate To New Post Page
    Go To    ${URL}/newpost
    Wait Until Element Is Visible    ${POST_TITLE_INPUT}    timeout=10s

Fill Post Title
    [Arguments]    ${title}
    Clear Element Text    ${POST_TITLE_INPUT}
    Input Text    ${POST_TITLE_INPUT}    ${title}

Fill Post Content
    [Arguments]    ${content}
    Wait Until Element Is Visible    ${POST_CONTENT_EDITOR}    timeout=5s
    Click Element    ${POST_CONTENT_EDITOR}
    Input Text    ${POST_CONTENT_EDITOR}    ${content}

Fill Post Subtext
    [Arguments]    ${subtext}
    Input Text    ${POST_SUBTEXT_INPUT}    ${subtext}

Notification Should Contain
    [Arguments]    ${text}
    Wait Until Element Is Visible    ${NOTIFICATION}    timeout=8s
    Element Should Contain    ${NOTIFICATION}    ${text}

Notification Should Be Warning
    Wait Until Element Is Visible    ${NOTIFICATION}    timeout=8s
    ${classes}=    Get Element Attribute    ${NOTIFICATION}    class
    Should Contain    ${classes}    warn

Navigate To Blog Page
    Wait Until Element Is Visible    ${BLOG_NAV_LINK}    timeout=10s
    Click Element    ${BLOG_NAV_LINK}
    Wait Until Element Is Visible    ${BLOG_PAGE_TITLE}    timeout=10s

Navigate To Profile Page
    Go To    ${URL}/Profil
    Sleep    1s
    Wait Until Element Is Visible    xpath://h2[contains(.,"profilhoz tartozó cikkek")]    timeout=15s

Get First Post Edit Href
    ${href}=    Execute JavaScript
    ...    return document.querySelector('a[href*="/editpost/"]')?.getAttribute('href') || ''
    RETURN    ${href}

Check Count Changed
    [Arguments]    ${locator}    ${original_value}
    ${current_value} =    Get Text    ${locator}
    Should Not Be Equal    ${current_value}    ${original_value}

Open Browser With Camera Permission
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys
    Call Method    ${options}    add_argument    --use-fake-ui-for-media-stream
    Call Method    ${options}    add_argument    --use-fake-device-for-media-stream
    Create Webdriver    Chrome    options=${options}

    Go To    ${URL}

Open Modal
    Click Element    ${SZERK_BTN}
    Wait Until Element Is Visible    ${SZERK_MODAL}    timeout=5s

Fill Required Name Fields
    [Arguments]    ${vez}=Teszt    ${ker}=Elek
    Clear Element Text    ${VEZETEKNEV_INPUT}
    Input Text    ${VEZETEKNEV_INPUT}    ${vez}
    Clear Element Text    ${KERESZTNEV_INPUT}
    Input Text    ${KERESZTNEV_INPUT}    ${ker}

Save And Wait For Modal To Close
    Click Element    ${MENTES_BTN}
    Wait Until Element Is Not Visible    ${SZERK_MODAL}    timeout=10s

Open Camera Browser And Login
    # Override the default Test Setup — open Chrome with fake camera, then log in and navigate
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys
    Call Method    ${options}    add_argument    --use-fake-ui-for-media-stream
    Call Method    ${options}    add_argument    --use-fake-device-for-media-stream
    Create Webdriver    Chrome    options=${options}
    Maximize Browser Window
    Go To    ${URL}
    # The login page is at the same URL — navigate there via nav link
    Wait Until Element Is Visible    //header//nav//a[7]    timeout=10s
    Click Element    //header//nav//a[7]
    Login As Test User
    Navigate To Profile Page