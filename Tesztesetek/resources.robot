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

Switch To Registration
    Click Button    //*[@id="app"]/main/div/div[3]/div[4]/button
    Wait Until Element Is Visible    xpath://h2[contains(.,"Fiók készítése")]

Fill Registration Form
    [Arguments]    ${username}    ${email}    ${password}    ${confirm}
    Input Text    name:username    ${username}
    Input Text    name:email    ${email}
    Input Password    name:password    ${password}
    Input Password    name:password_confirmation    ${confirm}
    Wait Until Element Is Visible     xpath=//form//label[1]/input    timeout=10s
    Select Checkbox     xpath=//form//label[1]/input
    Select Checkbox     xpath=//form//label[2]/input

Submit Registration
    Click Button    xpath://button[contains(.,"Fiók létrehozása")]

Registration Should Succeed
    Wait Until Location Contains    /Profil    timeout=10s

Registration Should Fail
    Wait Until Element Is Visible    css:.error-message    timeout=5s