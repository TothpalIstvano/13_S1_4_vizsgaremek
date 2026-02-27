*** Settings ***
Resource    resources.robot
Test Setup    Open Registration Page
Test Teardown    Close Browser

*** Test Cases ***

L1 - Successful Login
    Switch To Login
    Fill Login Form
    ...    teszt1231@example.com
    ...    Teszt123!
    Submit Login
    Login Should Succeed

L2 - Login Fails With Wrong Password
    Switch To Login
    Fill Login Form
    ...    teszt1231@example.com
    ...    WrongPass1!
    Submit Login
    Login Should Fail

Login Fails With Wrong Email
    Switch To Login
    Fill Login Form
    ...    nemletezik@example.com
    ...    Teszt123!
    Submit Login
    Login Should Fail

Login Fails With Invalid Email Format
    Switch To Login
    Fill Login Form
    ...    notanemail
    ...    Teszt123!
    Submit Login
    Login Should Fail

Login Fails With Empty Email
    Switch To Login
    Fill Login Form
    ...    ${EMPTY}
    ...    Teszt123!
    Submit Login
    Login Should Fail

Login Fails With Empty Password
    Switch To Login
    Fill Login Form
    ...    teszt1231@example.com
    ...    ${EMPTY}
    Submit Login
    Login Should Fail

Login Fails With Both Fields Empty
    Switch To Login
    Fill Login Form
    ...    ${EMPTY}
    ...    ${EMPTY}
    Submit Login
    Login Should Fail

Login Fails With Short Password
    Switch To Login
    Fill Login Form
    ...    teszt1231@example.com
    ...    abc
    Submit Login
    Login Should Fail

Forgot Password Modal Opens
    Switch To Login
    Open Forgot Password Modal
    Element Should Be Visible    xpath://input[@placeholder="Email cím"]

Forgot Password Modal Closes On X Button
    Switch To Login
    Open Forgot Password Modal
    Click Button    xpath://button[contains(.,"✕")]
    Wait Until Element Is Not Visible    xpath://h3[contains(.,"Jelszó visszaállítása")]    timeout=5s

Forgot Password Fails With Invalid Email
    Switch To Login
    Open Forgot Password Modal
    Input Text    xpath://input[@placeholder="Email cím"]    notanemail
    Click Button    xpath://button[contains(.,"Link küldése")]
    Wait Until Element Is Visible    css:.error-message    timeout=5s
    Element Should Contain    css:.error-message    érvényes email

L3 - Forgot Password Succeeds With Valid Email
    Switch To Login
    Open Forgot Password Modal
    Input Text    xpath://input[@placeholder="Email cím"]    teszt1231@example.com
    Click Button    xpath://button[contains(.,"Link küldése")]
    Wait Until Element Is Visible    xpath://*[contains(.,"Elküldtük a visszaállító linket")]    timeout=10s

Switch From Login To Registration
    Switch To Login
    Click Button    xpath://button[contains(.,"Regisztráció")]
    Wait Until Element Is Visible    xpath://h2[contains(.,"Fiók készítése")]    timeout=5s

Switch From Registration Back To Login
    Switch To Registration
    Click Button    xpath://button[contains(.,"Bejelentkezés")]
    Wait Until Element Is Visible    xpath://h2[contains(.,"Lépj be a fiókodba")]    timeout=5s