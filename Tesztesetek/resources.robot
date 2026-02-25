*** Settings ***
Library    SeleniumLibrary

*** Variables ***
${URL}    http://localhost:5173
${BROWSER}    Chrome

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