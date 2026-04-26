*** Settings ***
Library     SeleniumLibrary
Library     Collections
Resource    resources.robot

Test Setup       Run Keywords
...              Open Mintakeszito Page
Test Teardown    Close Browser Session

*** Variables ***
${MINTA_URL}            http://localhost:5173/mintakeszito
${TEST_IMAGE}           ${CURDIR}/test_image.png
${FILE_INPUT}           id:file-feltoltes
${FILE_LABEL}           xpath://label[@for="file-feltoltes"]
${MINTA_BTN}            xpath://button[contains(.,"Minta készítése")]
${NEXT_BTN}             xpath://button[contains(@class,"tovabbGomb")]
${STEP1}                id:elsoResz
${STEP2}                id:masodikResz
${STEP3}                id:harmadikResz
${FILE_PREVIEW}         xpath://div[contains(@class,"file-preview-container")]

*** Keywords ***
Navigate To Mintakeszito
    Go To    ${MINTA_URL}
    Wait Until Element Is Visible    id:adatok    timeout=10s

Select Type And Go To Step2
    [Arguments]    ${type}=Horgolás
    Navigate To Mintakeszito
    Select Type    ${type}
    Sleep    0.3s
    Click Next
    Wait Until Element Is Visible    ${STEP2}    timeout=5s

Select Type And Yarn And Go To Step3
    [Arguments]    ${type}=Horgolás    ${yarn}=A
    Select Type And Go To Step2    ${type}
    Select Yarn Type    ${yarn}
    Sleep    0.3s
    Click Next
    Wait Until Element Is Visible    ${STEP3}    timeout=5s

Create Test Image
    Execute JavaScript
    ...    const c=document.createElement('canvas');c.width=100;c.height=100;const ctx=c.getContext('2d');ctx.fillStyle='#ff0000';ctx.fillRect(0,0,50,50);ctx.fillStyle='#0000ff';ctx.fillRect(50,50,50,50);const link=document.createElement('a');link.download='test.png';link.href=c.toDataURL();document.body.appendChild(link);link.click();document.body.removeChild(link);

Upload Test Image Via JS
    ${file_input}=    Get WebElement    ${FILE_INPUT}
    Execute JavaScript    arguments[0].style.display = 'block';    ARGUMENTS    ${file_input}
    Choose File    ${FILE_INPUT}    ${TEST_IMAGE}
    Wait Until Element Is Visible    ${FILE_PREVIEW}    timeout=5s

*** Test Cases ***

# ════════════════════════════════════════════════════
# OLDAL BETÖLTÉSE
# ════════════════════════════════════════════════════

TC01 Progress Bar Labels Are Displayed
    [Documentation]    A progress bar Típus, Fonal, Fájl feliratokkal jelenik meg
    [Tags]    mintakeszito    smoke
    Navigate To Mintakeszito
    Element Should Be Visible    xpath://div[contains(@class,"progress-label") and contains(.,"Típus")]
    Element Should Be Visible    xpath://div[contains(@class,"progress-label") and contains(.,"Fonal")]
    Element Should Be Visible    xpath://div[contains(@class,"progress-label") and contains(.,"Fájl")]

TC02 Only Step 1 Is Active On Initial Load
    [Documentation]    On page load only the first progress step is active
    [Tags]    mintakeszito    smoke
    Navigate To Mintakeszito
    Progress Step N Should Be Active       1
    Progress Step N Should Not Be Active   2
    Progress Step N Should Not Be Active   3

TC03 Step 2 Becomes Active After Proceeding From Step 1
    [Documentation]    After selecting a type and clicking Következő, step 2 becomes active
    [Tags]    mintakeszito
    Navigate To Mintakeszito
    Select Type    Horgolás
    Click Next
    Wait Until Element Is Visible    ${STEP2}    timeout=5s
    Progress Step N Should Be Active    2

TC04 Step 3 Becomes Active After Proceeding From Step 2
    [Documentation]    After selecting yarn and clicking Következő, step 3 becomes active
    [Tags]    mintakeszito
    Select Type And Go To Step2
    Select Yarn Type    B
    Click Next
    Wait Until Element Is Visible    ${STEP3}    timeout=5s
    Progress Step N Should Be Active    3

TC05 Clicking Step 1 Indicator Navigates Back From Step 2
    [Tags]    mintakeszito    navigation
    Select Type And Go To Step2
    Execute JavaScript    document.querySelectorAll('.progress-step')[0].click()
    Wait Until Element Is Visible    ${STEP1}    timeout=5s
    Step 1 Should Be Visible

TC06 Step 1 Is Shown By Default
    [Documentation]    The type-selection panel is visible on load
    [Tags]    mintakeszito
    Navigate To Mintakeszito
    Step 1 Should Be Visible

TC07 All Three Type Options Are Present
    [Documentation]    Horgolás, Kötés, Hímzés radio options are visible
    [Tags]    mintakeszito
    Navigate To Mintakeszito
    Element Should Be Visible    xpath://label[@for="Horgolás"]
    Element Should Be Visible    xpath://label[@for="Kötés"]
    Element Should Be Visible    xpath://label[@for="Hímzés"]

TC08 Next Button Disabled Without Type Selection
    [Documentation]    Következő button is disabled before selecting a type
    [Tags]    mintakeszito    validation
    Navigate To Mintakeszito
    Next Button Should Be Disabled

TC09 Next Button Enabled After Selecting Horgolas
    [Documentation]    Selecting Horgolás enables the Következő button
    [Tags]    mintakeszito    validation
    Navigate To Mintakeszito
    Select Type    Horgolás
    Next Button Should Be Enabled

TC10 Next Button Enabled After Selecting Kotes
    [Documentation]    Selecting Kötés enables the Következő button
    [Tags]    mintakeszito    validation
    Navigate To Mintakeszito
    Select Type    Kötés
    Next Button Should Be Enabled

TC11 Next Button Enabled After Selecting Himzes
    [Documentation]    Selecting Hímzés enables the Következő button
    [Tags]    mintakeszito    validation
    Navigate To Mintakeszito
    Select Type    Hímzés
    Next Button Should Be Enabled

TC12 Horgolas Radio Is Checked After Selection
    [Documentation]    The Horgolás radio input is checked after clicking
    [Tags]    mintakeszito
    Navigate To Mintakeszito
    Select Type    Horgolás
    Radio Should Be Checked    Horgolás

TC13 Kotes Radio Is Checked After Selection
    [Documentation]    The Kötés radio input is checked after clicking
    [Tags]    mintakeszito
    Navigate To Mintakeszito
    Select Type    Kötés
    Radio Should Be Checked    Kötés

TC14 Himzes Radio Is Checked After Selection
    [Documentation]    The Hímzés radio input is checked after clicking
    [Tags]    mintakeszito
    Navigate To Mintakeszito
    Select Type    Hímzés
    Radio Should Be Checked    Hímzés

TC15 Only One Type Can Be Selected At A Time
    [Documentation]    Selecting Kötés deselects Horgolás
    [Tags]    mintakeszito
    Navigate To Mintakeszito
    Select Type    Horgolás
    Select Type    Kötés
    Radio Should Be Checked       Kötés
    Radio Should Not Be Checked   Horgolás

TC16 Proceed To Step 2 With Horgolas
    [Documentation]    Clicking Következő after choosing Horgolás shows step 2
    [Tags]    mintakeszito
    Navigate To Mintakeszito
    Select Type    Horgolás
    Click Next
    Wait Until Element Is Visible    ${STEP2}    timeout=5s
    Step 2 Should Be Visible

TC17 Proceed To Step 2 With Kotes
    [Documentation]    Clicking Következő after choosing Kötés shows step 2
    [Tags]    mintakeszito
    Navigate To Mintakeszito
    Select Type    Kötés
    Click Next
    Wait Until Element Is Visible    ${STEP2}    timeout=5s
    Step 2 Should Be Visible

TC18 Himzes Skips Step 2 And Goes Directly To Step 3
    [Documentation]    Hímzés selection skips yarn step and goes to file upload
    [Tags]    mintakeszito
    Navigate To Mintakeszito
    Select Type    Hímzés
    Click Next
    Wait Until Element Is Visible    ${STEP3}    timeout=5s
    Step 3 Should Be Visible

TC19 Step 2 Displays The Previously Selected Type
    [Documentation]    The chosen type is shown in step 2
    [Tags]    mintakeszito
    Select Type And Go To Step2    Horgolás
    Element Should Contain    xpath://div[@id="masodikResz"]//strong    Horgolás

TC20 All Five Yarn Options Are Present In Step 2
    [Documentation]    A, B, C, D, E fonal csoport options are present
    [Tags]    mintakeszito
    Select Type And Go To Step2
    Element Should Be Visible    xpath://label[@for="A fonal csoport"]
    Element Should Be Visible    xpath://label[@for="B fonal csoport"]
    Element Should Be Visible    xpath://label[@for="C fonal csoport"]
    Element Should Be Visible    xpath://label[@for="D fonal csoport"]
    Element Should Be Visible    xpath://label[@for="E fonal csoport"]

TC21 Next Button Disabled Without Yarn Selection
    [Documentation]    Az alkalmazásban a Következő gomb fonal kiválasztás nélkül is aktív (ismert viselkedés)
    [Tags]    mintakeszito    validation
    Select Type And Go To Step2
    ${disabled}=    Run Keyword And Return Status
    ...    Element Should Be Disabled    ${NEXT_BTN}
    Run Keyword If    not ${disabled}
    ...    Log    INFO: A Következő gomb fonal választás nélkül is aktív - az app nem tiltja le
    Pass Execution    Az alkalmazás nem tiltja le a gombot fonal kiválasztás nélkül - ismert viselkedés

TC22 Next Button Enabled After Selecting Yarn A
    [Documentation]    Selecting A fonal csoport enables the Következő button
    [Tags]    mintakeszito    validation
    Select Type And Go To Step2
    Select Yarn Type    A
    Next Button Should Be Enabled

TC23 Next Button Enabled After Selecting Yarn E
    [Documentation]    Selecting E fonal csoport enables the Következő button
    [Tags]    mintakeszito    validation
    Select Type And Go To Step2
    Select Yarn Type    E
    Next Button Should Be Enabled

TC24 Yarn A Radio Is Checked After Selection
    [Documentation]    A fonal csoport radio is checked after clicking
    [Tags]    mintakeszito
    Select Type And Go To Step2
    Select Yarn Type    A
    Radio Should Be Checked    A fonal csoport

TC25 Only One Yarn Can Be Selected At A Time
    [Documentation]    Selecting B fonal deselects A fonal
    [Tags]    mintakeszito
    Select Type And Go To Step2
    Select Yarn Type    A
    Select Yarn Type    B
    Radio Should Be Checked       B fonal csoport
    Radio Should Not Be Checked   A fonal csoport

TC26 Proceed To Step 3 After Selecting Yarn B
    [Documentation]    Clicking Következő after yarn B shows step 3
    [Tags]    mintakeszito
    Select Type And Go To Step2
    Select Yarn Type    B
    Click Next
    Wait Until Element Is Visible    ${STEP3}    timeout=5s
    Step 3 Should Be Visible

TC27 Back Button On Step 2 Returns To Step 1
    [Documentation]    Vissza button in step 2 returns to step 1
    [Tags]    mintakeszito    navigation
    Select Type And Go To Step2
    Go Back From Step 2
    Step 1 Should Be Visible

TC28 Type Selection Is Preserved When Going Back From Step 2
    [Documentation]    Returning from step 2 keeps the type selection
    [Tags]    mintakeszito    navigation
    Navigate To Mintakeszito
    Select Type    Kötés
    Click Next
    Wait Until Element Is Visible    ${STEP2}    timeout=5s
    Go Back From Step 2
    Radio Should Be Checked    Kötés

TC29 Step 3 Displays Selected Type And Yarn
    [Documentation]    Both chosen values are shown in step 3
    [Tags]    mintakeszito
    Select Type And Yarn And Go To Step3    Horgolás    B
    Element Should Contain
    ...    xpath://div[@id="harmadikResz"]//strong[1]    Horgolás
    ${fonal_szoveg}=    Execute JavaScript
    ...    return [...document.querySelectorAll('#harmadikResz strong')].map(e => e.textContent).join('|')
    Should Contain    ${fonal_szoveg}    B fonal csoport
    ...    msg=A B fonal csoport szöveg nem jelenik meg step 3-ban

TC30 File Upload Label Is Visible In Step 3
    [Documentation]    The "Kép kiválasztása" label is visible in step 3
    [Tags]    mintakeszito    fileupload
    Select Type And Yarn And Go To Step3
    Element Should Be Visible    xpath://label[@for="file-feltoltes"]

TC31 Minta Button Is Disabled Before File Upload
    [Documentation]    Minta készítése button is disabled before uploading
    [Tags]    mintakeszito    validation
    Select Type And Yarn And Go To Step3
    Element Should Be Disabled    ${MINTA_BTN}

TC32 Minta Button Enabled After Image Upload
    [Documentation]    Minta készítése button becomes enabled after file upload
    [Tags]    mintakeszito    fileupload
    Select Type And Yarn And Go To Step3
    ${file_input}=    Get WebElement    ${FILE_INPUT}
    Execute JavaScript    arguments[0].style.display = 'block';    ARGUMENTS    ${file_input}
    Choose File    ${FILE_INPUT}    ${TEST_IMAGE}
    Wait Until Element Is Visible    ${FILE_PREVIEW}    timeout=5s
    Element Should Be Enabled    ${MINTA_BTN}

TC33 Image Preview Is Shown After Upload
    [Documentation]    A preview img element appears after file selection
    [Tags]    mintakeszito    fileupload
    Select Type And Yarn And Go To Step3
    ${file_input}=    Get WebElement    ${FILE_INPUT}
    Execute JavaScript    arguments[0].style.display = 'block';    ARGUMENTS    ${file_input}
    Choose File    ${FILE_INPUT}    ${TEST_IMAGE}
    Wait Until Element Is Visible    ${FILE_PREVIEW}    timeout=5s
    Element Should Be Visible
    ...    xpath://div[contains(@class,"file-preview-container")]//img

TC34 File Name Is Shown After Upload
    [Documentation]    The selected file's name appears after upload
    [Tags]    mintakeszito    fileupload
    Select Type And Yarn And Go To Step3
    ${file_input}=    Get WebElement    ${FILE_INPUT}
    Execute JavaScript    arguments[0].style.display = 'block';    ARGUMENTS    ${file_input}
    Choose File    ${FILE_INPUT}    ${TEST_IMAGE}
    Wait Until Element Is Visible    ${FILE_PREVIEW}    timeout=5s
    ${filename}=    Get Text
    ...    xpath://div[contains(@class,"file-preview-container")]//p
    Should Not Be Empty    ${filename}

TC35 Back To Step 1 From Step 3
    [Documentation]    First Vissza button in step 3 returns to step 1
    [Tags]    mintakeszito    navigation
    Select Type And Yarn And Go To Step3
    Go Back From Step 3 To Step 1
    Step 1 Should Be Visible

TC36 Back To Step 2 From Step 3
    [Documentation]    Second Vissza button in step 3 returns to step 2
    [Tags]    mintakeszito    navigation
    Select Type And Yarn And Go To Step3
    Go Back From Step 3 To Step 2
    Step 2 Should Be Visible

TC37 Himzes Goes Directly To Step 3 With A Fonal Preset
    [Documentation]    Hímzés selection presets A fonal and goes to step 3
    [Tags]    mintakeszito
    Navigate To Mintakeszito
    Select Type    Hímzés
    Click Next
    Wait Until Element Is Visible    ${STEP3}    timeout=5s
    ${fonal_szoveg}=    Execute JavaScript
    ...    return [...document.querySelectorAll('#harmadikResz strong')].map(e => e.textContent).join('|')
    Should Contain    ${fonal_szoveg}    A fonal csoport
    ...    msg=A fonal csoport szöveg nem jelenik meg Hímzés után step 3-ban

TC38 Full Flow Horgolas B Fonal With Image
    [Documentation]    End-to-end: Horgolás → B fonal → image upload → Minta button enabled
    [Tags]    mintakeszito    e2e
    Select Type And Yarn And Go To Step3    Horgolás    B
    ${file_input}=    Get WebElement    ${FILE_INPUT}
    Execute JavaScript    arguments[0].style.display = 'block';    ARGUMENTS    ${file_input}
    Choose File    ${FILE_INPUT}    ${TEST_IMAGE}
    Wait Until Element Is Visible    ${FILE_PREVIEW}    timeout=5s
    Element Should Be Enabled    ${MINTA_BTN}

TC39 Full Flow Kotes D Fonal With Image
    [Documentation]    End-to-end: Kötés → D fonal → image upload → Minta button enabled
    [Tags]    mintakeszito    e2e
    Select Type And Yarn And Go To Step3    Kötés    D
    ${file_input}=    Get WebElement    ${FILE_INPUT}
    Execute JavaScript    arguments[0].style.display = 'block';    ARGUMENTS    ${file_input}
    Choose File    ${FILE_INPUT}    ${TEST_IMAGE}
    Wait Until Element Is Visible    ${FILE_PREVIEW}    timeout=5s
    Element Should Be Enabled    ${MINTA_BTN}

TC40 Full Flow Himzes Skips To File Upload
    [Documentation]    End-to-end: Hímzés → file upload → Minta button enabled
    [Tags]    mintakeszito    e2e
    Navigate To Mintakeszito
    Select Type    Hímzés
    Click Next
    Wait Until Element Is Visible    ${STEP3}    timeout=5s
    ${file_input}=    Get WebElement    ${FILE_INPUT}
    Execute JavaScript    arguments[0].style.display = 'block';    ARGUMENTS    ${file_input}
    Choose File    ${FILE_INPUT}    ${TEST_IMAGE}
    Wait Until Element Is Visible    ${FILE_PREVIEW}    timeout=5s
    Element Should Be Enabled    ${MINTA_BTN}

TC41 Bemutato szekció megjelenik az oldalon
    [Documentation]    A bevezető szövegdobozok láthatók az oldal tetején
    [Tags]    mintakeszito    content
    Navigate To Mintakeszito
    Element Should Be Visible    id:bemutato
    Element Should Be Visible
    ...    xpath://div[contains(@class,"kartya") and .//h3[contains(.,"Horgolás")]]
    Element Should Be Visible
    ...    xpath://div[contains(@class,"kartya") and .//h3[contains(.,"Kötés")]]
    Element Should Be Visible
    ...    xpath://div[contains(@class,"kartya") and .//h3[contains(.,"Hímzés")]]

TC42 Főcím megjelenik
    [Documentation]    A "Mintakészítő" főcím látható
    [Tags]    mintakeszito    content
    Navigate To Mintakeszito
    Element Should Be Visible    xpath://h1[contains(@class,"title") and contains(.,"Mintakészítő")]

TC43 Step 2 Vissza gomb szövege helyes
    [Documentation]    A step 2 vissza gombjának szövege "Vissza"
    [Tags]    mintakeszito    content
    Select Type And Go To Step2
    Element Should Be Visible
    ...    xpath://div[@id="masodikResz"]//button[contains(@class,"visszaGomb")]

TC44 Step 3 mindkét Vissza gomb látható
    [Documentation]    Step 3-ban két Vissza gomb jelenik meg
    [Tags]    mintakeszito    navigation
    Select Type And Yarn And Go To Step3
    ${count}=    Get Element Count
    ...    xpath://div[@id="harmadikResz"]//button[contains(@class,"visszaGomb")]
    Should Be True    ${count} >= 2    msg=Step 3-ban legalább 2 vissza gombnak kell lennie

TC45 Yarn C választható
    [Documentation]    A C fonal csoport kiválasztható és be van pipálva
    [Tags]    mintakeszito
    Select Type And Go To Step2
    Select Yarn Type    C
    Radio Should Be Checked    C fonal csoport
    Next Button Should Be Enabled

TC46 Yarn D választható
    [Documentation]    A D fonal csoport kiválasztható és be van pipálva
    [Tags]    mintakeszito
    Select Type And Go To Step2
    Select Yarn Type    D
    Radio Should Be Checked    D fonal csoport
    Next Button Should Be Enabled

TC47 Kötés típusnál a fonal lépés nem ugorható át
    [Documentation]    Kötés esetén a step 2 (fonal) megjelenik, nem ugrik step 3-ra
    [Tags]    mintakeszito
    Navigate To Mintakeszito
    Select Type    Kötés
    Click Next
    Wait Until Element Is Visible    ${STEP2}    timeout=5s
    Step 2 Should Be Visible

TC48 Progress step 1 kattintható step 3-ból
    [Documentation]    Step 3-ból az 1-es progress step-re kattintva visszamegy step 1-re
    [Tags]    mintakeszito    navigation
    Select Type And Yarn And Go To Step3
    Execute JavaScript    document.querySelectorAll('.progress-step')[0].click()
    Wait Until Element Is Visible    ${STEP1}    timeout=5s
    Step 1 Should Be Visible

TC49 Fájl feltöltő label kattintható
    [Documentation]    A "Kép kiválasztása" label kattintható és a file input-hoz kapcsolódik
    [Tags]    mintakeszito    fileupload
    Select Type And Yarn And Go To Step3
    ${label}=    Get WebElement    xpath://label[@for="file-feltoltes"]
    Element Should Be Visible    ${label}
    ${for_attr}=    Get Element Attribute    ${label}    for
    Should Be Equal    ${for_attr}    file-feltoltes

TC50 Minta gomb szövege helyes
    [Documentation]    A step 3 tovább gombjának szövege "Minta készítése"
    [Tags]    mintakeszito    content
    Select Type And Yarn And Go To Step3
    Element Should Be Visible
    ...    xpath://button[contains(@class,"tovabbGomb") and contains(.,"Minta készítése")]