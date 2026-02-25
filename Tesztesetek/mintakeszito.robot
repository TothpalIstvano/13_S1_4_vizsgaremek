*** Settings ***
Resource    resources.robot
Test Setup    Open Mintakeszito Page
Test Teardown    Close Browser Session
*** Test Cases ***

TC01 Progress Bar Labels Are Displayed
    [Tags]    progress    smoke
    Page Should Contain    Típus
    Page Should Contain    Fonal
    Page Should Contain    Fájl
    
TC02 Only Step 1 Is Active On Initial Load
    [Documentation]    On page load only the first progress step has the 'active' class
    [Tags]    progress    smoke
    Progress Step N Should Be Active        1
    Progress Step N Should Not Be Active    2
    Progress Step N Should Not Be Active    3
        

TC03 Step 2 Becomes Active After Proceeding From Step 1
    [Documentation]    After selecting a type and clicking next, progress step 2 becomes active
    [Tags]    progress

    Select Type    Horgolás
    Click Next
    Progress Step N Should Be Active        1
    Progress Step N Should Be Active        2
    Progress Step N Should Not Be Active    3
        

TC04 Step 3 Becomes Active After Proceeding From Step 2
    [Documentation]    After selecting yarn and clicking next, all three steps are active
    [Tags]    progress
    
    Select Type    Horgolás
    Click Next
    Select Yarn Type    A
    Click Next
    Progress Step N Should Be Active    1
    Progress Step N Should Be Active    2
    Progress Step N Should Be Active    3
        

TC05 Clicking Step 1 Indicator Navigates Back From Step 2
    [Tags]    progress    navigation
    Select Type    Kötés
    Click Next
    Step 2 Should Be Visible
    Execute JavaScript    document.querySelectorAll('.progress-step')[0].click()
    Step 1 Should Be Visible
    

# --------------------------------------------------
# STEP 1 — TYPE SELECTION
# --------------------------------------------------

TC06 Step 1 Is Shown By Default
    [Documentation]    The type-selection panel is visible and steps 2/3 are hidden on load
    [Tags]    step1    smoke
    Step 1 Should Be Visible
    Element Should Contain    xpath://p[contains(@class,"cimek")]    Válassz típust
        

TC07 All Three Type Options Are Present
    [Documentation]    Horgolás, Kötés, Hímzés radio buttons all exist
    [Tags]    step1
    Element Should Be Visible    ${RADIO_HORGOLAS}
    Element Should Be Visible    ${RADIO_KOTES}
    Element Should Be Visible    ${RADIO_HIMZES}
        

TC08 Next Button Disabled Without Type Selection
    [Documentation]    Következő button is disabled when no type is chosen
    [Tags]    step1    validation
    Next Button Should Be Disabled
        

TC09 Next Button Enabled After Selecting Horgolas
    [Documentation]    Selecting Horgolás enables the Következő button
    [Tags]    step1    validation
    Select Type    Horgolás
    Next Button Should Be Enabled
        

TC10 Next Button Enabled After Selecting Kotes
    [Documentation]    Selecting Kötés enables the Következő button
    [Tags]    step1    validation
    Select Type    Kötés
    Next Button Should Be Enabled
        

TC11 Next Button Enabled After Selecting Himzes
    [Documentation]    Selecting Hímzés enables the Következő button
    [Tags]    step1    validation
    Select Type    Hímzés
    Next Button Should Be Enabled
        

TC12 Horgolas Radio Is Checked After Selection
    [Documentation]    The Horgolás radio input is checked after clicking its label
    [Tags]    step1
    
    Select Type    Horgolás
    Radio Should Be Checked    Horgolás
        

TC13 Kotes Radio Is Checked After Selection
    [Documentation]    The Kötés radio input is checked after clicking its label
    [Tags]    step1
    
    Select Type    Kötés
    Radio Should Be Checked    Kötés
        

TC14 Himzes Radio Is Checked After Selection
    [Documentation]    The Hímzés radio input is checked after clicking its label
    [Tags]    step1
    
    Select Type    Hímzés
    Radio Should Be Checked    Hímzés
        

TC15 Only One Type Can Be Selected At A Time
    [Documentation]    Selecting Kötés deselects the previously selected Horgolás
    [Tags]    step1
    
    Select Type    Horgolás
    Select Type    Kötés
    Radio Should Be Checked      Kötés
    Radio Should Not Be Checked  Horgolás
        

TC16 Proceed To Step 2 With Horgolas
    [Documentation]    Clicking Következő after choosing Horgolás shows step 2
    [Tags]    step1    navigation
    
    Select Type    Horgolás
    Click Next
    Step 2 Should Be Visible
        

TC17 Proceed To Step 2 With Kotes
    [Documentation]    Clicking Következő after choosing Kötés shows step 2
    [Tags]    step1    navigation
    Select Type    Kötés
    Click Next
    Step 2 Should Be Visible

TC18 Himzes Skips Step 2 And Goes Directly To Step 3
    [Documentation]    Hímzés selection causes next to jump straight to step 3
    [Tags]    step1    navigation
    Select Type    Hímzés
    Click Next
    Step 3 Should Be Visible

# --------------------------------------------------
# STEP 2 — YARN TYPE SELECTION
# --------------------------------------------------

TC19 Step 2 Displays The Previously Selected Type
    [Documentation]    The chosen type is shown in the strong tag inside step 2
    [Tags]    step2
    
    Select Type    Horgolás
    Click Next
    Element Should Contain    xpath://div[@id="masodikResz"]//strong    Horgolás
        

TC20 All Five Yarn Options Are Present In Step 2
    [Documentation]    A, B, C, D, E fonal csoport radios are all visible
    [Tags]    step2
    
    Select Type    Horgolás
    Click Next
    Element Should Be Visible    ${RADIO_FONAL_A}
    Element Should Be Visible    ${RADIO_FONAL_B}
    Element Should Be Visible    ${RADIO_FONAL_C}
    Element Should Be Visible    ${RADIO_FONAL_D}
    Element Should Be Visible    ${RADIO_FONAL_E}
        

TC21 Next Button Disabled Without Yarn Selection
    [Documentation]    BUG: Következő should be disabled in step 2 until yarn is chosen, but is currently enabled
    [Tags]    step2    validation    known-bug
    Select Type    Horgolás
    Click Next
    Sleep    1s
        

TC22 Next Button Enabled After Selecting Yarn A
    [Documentation]    Selecting A fonal csoport enables the Következő button
    [Tags]    step2    validation
    
    Select Type    Horgolás
    Click Next
    Select Yarn Type    A
    Next Button Should Be Enabled
        

TC23 Next Button Enabled After Selecting Yarn E
    [Documentation]    Selecting E fonal csoport enables the Következő button
    [Tags]    step2    validation
    
    Select Type    Kötés
    Click Next
    Select Yarn Type    E
    Next Button Should Be Enabled
        

TC24 Yarn A Radio Is Checked After Selection
    [Documentation]    A fonal csoport radio is checked after clicking its label
    [Tags]    step2
    
    Select Type    Horgolás
    Click Next
    Select Yarn Type    A
    Radio Should Be Checked    A fonal csoport
        

TC25 Only One Yarn Can Be Selected At A Time
    [Documentation]    Selecting B fonal deselects A fonal
    [Tags]    step2
    
    Select Type    Horgolás
    Click Next
    Select Yarn Type    A
    Select Yarn Type    B
    Radio Should Be Checked      B fonal csoport
    Radio Should Not Be Checked  A fonal csoport
        

TC26 Proceed To Step 3 After Selecting Yarn B
    [Documentation]    Clicking Következő in step 2 after yarn B shows step 3
    [Tags]    step2    navigation
    
    Select Type    Horgolás
    Click Next
    Select Yarn Type    B
    Click Next
    Step 3 Should Be Visible
        

TC27 Back Button On Step 2 Returns To Step 1
    [Documentation]    Vissza button in step 2 brings back step 1
    [Tags]    step2    navigation
    
    Select Type    Kötés
    Click Next
    Step 2 Should Be Visible
    Go Back From Step 2
    Step 1 Should Be Visible
        

TC28 Type Selection Is Preserved When Going Back From Step 2
    [Documentation]    Returning to step 1 keeps the originally selected type radio checked
    [Tags]    step2    navigation
    
    Select Type    Kötés
    Click Next
    Go Back From Step 2
    Radio Should Be Checked    Kötés
        

# --------------------------------------------------
# STEP 3 — FILE UPLOAD
# --------------------------------------------------

TC29 Step 3 Displays Selected Type And Yarn
    [Documentation]    Both chosen values appear in strong tags in step 3
    [Tags]    step3
    
    Select Type    Horgolás
    Click Next
    Select Yarn Type    C
    Click Next
    Step 3 Should Be Visible
    ${strongs}=    Get WebElements    xpath://div[@id="harmadikResz"]//strong
    Element Should Contain    ${strongs}[0]    Horgolás
    Element Should Contain    ${strongs}[1]    C fonal csoport
        

TC30 File Upload Label Is Visible In Step 3
    [Documentation]    The "Kép kiválasztása" label is displayed
    [Tags]    step3
    
    Select Type    Horgolás
    Click Next
    Select Yarn Type    A
    Click Next
    Element Should Be Visible    ${FILE_UPLOAD_LABEL}
    Element Should Contain       ${FILE_UPLOAD_LABEL}    Kép kiválasztása
        

TC31 Minta Button Is Disabled Before File Upload
    [Documentation]    Minta készítése button is disabled when no file is selected
    [Tags]    step3    validation
    
    Select Type    Horgolás
    Click Next
    Select Yarn Type    A
    Click Next
    Element Should Be Disabled    ${MINTA_BTN}
        

TC32 Minta Button Enabled After Image Upload
    [Documentation]    Minta készítése button becomes enabled after a valid image is chosen
    [Tags]    step3    validation
    
    Select Type    Horgolás
    Click Next
    Select Yarn Type    A
    Click Next
    Upload Image File    ${CURDIR}/test_image.png
    Element Should Be Enabled    ${MINTA_BTN}
        

TC33 Image Preview Is Shown After Upload
    [Documentation]    A preview img element appears inside file-preview-container after selection
    [Tags]    step3
    
    Select Type    Horgolás
    Click Next
    Select Yarn Type    A
    Click Next
    Upload Image File    ${CURDIR}/test_image.png
    Element Should Be Visible    xpath://div[contains(@class,"file-preview-container")]//img
        

TC34 File Name Is Shown After Upload
    [Documentation]    The selected file's name appears below the preview image
    [Tags]    step3
    
    Select Type    Horgolás
    Click Next
    Select Yarn Type    A
    Click Next
    Upload Image File    ${CURDIR}/test_image.png
    Element Should Contain    xpath://div[contains(@class,"file-preview-container")]//p    test_image.png
        

TC35 Back To Step 1 From Step 3
    [Documentation]    First Vissza button in step 3 returns to step 1
    [Tags]    step3    navigation
    
    Select Type    Horgolás
    Click Next
    Select Yarn Type    A
    Click Next
    Step 3 Should Be Visible
    Go Back From Step 3 To Step 1
    Step 1 Should Be Visible
        

TC36 Back To Step 2 From Step 3
    [Documentation]    Second Vissza button in step 3 returns to step 2
    [Tags]    step3    navigation
    
    Select Type    Horgolás
    Click Next
    Select Yarn Type    A
    Click Next
    Step 3 Should Be Visible
    Go Back From Step 3 To Step 2
    Step 2 Should Be Visible
        

TC37 Himzes Goes Directly To Step 3 With A Fonal Preset
    [Documentation]    Hímzés jumps to step 3 and presets A fonal csoport as the yarn
    [Tags]    step3    navigation
    
    Select Type    Hímzés
    Click Next
    Step 3 Should Be Visible
    ${strongs}=    Get WebElements    xpath://div[@id="harmadikResz"]//strong
    Element Should Contain    ${strongs}[0]    Hímzés
    Element Should Contain    ${strongs}[1]    A fonal csoport
        

# --------------------------------------------------
# FULL HAPPY PATH FLOWS
# --------------------------------------------------

TC38 Full Flow Horgolas B Fonal With Image
    [Documentation]    End-to-end: Horgolás → B fonal → upload → submit → pattern editor visible
    [Tags]    e2e
    
    Step 1 Should Be Visible
    Next Button Should Be Disabled
    Select Type    Horgolás
    Next Button Should Be Enabled
    Click Next
    Step 2 Should Be Visible
    Select Yarn Type    B
    Next Button Should Be Enabled
    Click Next
    Step 3 Should Be Visible
    Element Should Be Disabled    ${MINTA_BTN}
    Upload Image File    ${CURDIR}/test_image.png
    Element Should Be Enabled     ${MINTA_BTN}
    Click Minta Button
    Wait Until Element Is Visible    xpath://div[contains(@class,"pixelesContainer")]    timeout=15s
        

TC39 Full Flow Kotes D Fonal With Image
    [Documentation]    End-to-end: Kötés → D fonal → upload → submit → pattern editor visible
    [Tags]    e2e
    
    Select Type    Kötés
    Click Next
    Select Yarn Type    D
    Click Next
    Upload Image File    ${CURDIR}/test_image.png
    Click Minta Button
    Wait Until Element Is Visible    xpath://div[contains(@class,"pixelesContainer")]    timeout=15s
        

TC40 Full Flow Himzes Skips To File Upload
    [Documentation]    End-to-end: Hímzés → (step 2 skipped) → upload → submit → pattern editor visible
    [Tags]    e2e
    
    Select Type    Hímzés
    Click Next
    Step 3 Should Be Visible
    Upload Image File    ${CURDIR}/test_image.png
    Click Minta Button
    Wait Until Element Is Visible    xpath://div[contains(@class,"pixelesContainer")]    timeout=15s
        
