*** Settings ***
Resource    resources.robot
Test Setup    Open Registration Page
Test Teardown    Close Browser

*** Test Cases ***

R01 - Successful Registration
    Switch To Registration
    Fill Registration Form
    ...    tesztuser1232
    ...    teszt1231@example.com
    ...    Teszt123!
    ...    Teszt123!
    Submit Registration
    Registration Should Succeed

R02 - Registration Fails With Weak Password
    Switch To Registration
    Fill Registration Form
    ...    tesztuser1231
    ...    teszt123@example.com
    ...    123
    ...    123
    Submit Registration
    Registration Should Fail At Short Password

R03 - Registration Fails With Mismatched Passwords
    Switch To Registration
    Fill Registration Form
    ...    tesztuser123
    ...    teszt123@example.com
    ...    Teszt123!
    ...    Masik123!
    Submit Registration
    Registration Should Fail At Mismatched Password

Registration Fails Without Terms
    Switch To Registration
    Input Text    name:username    tesztuser123
    Input Text    name:email    teszt123@example.com
    Input Password    name:password    Teszt123!
    Input Password    name:password_confirmation    Teszt123!
    Submit Registration
    Registration Should Fail

Unsuccessful Registration
    Switch To Registration
    Fill Registration Form
    ...    tesztuser1232
    ...    teszt1231@example.com
    ...    Teszt123!
    ...    Teszt123!
    Submit Registration
    Registration Should Fail At Registration

Registration Fails With Duplicate Email
    Switch To Registration
    Fill Registration Form
    ...    uniqueuser999
    ...    teszt1231@example.com
    ...    Teszt123!
    ...    Teszt123!
    Submit Registration
    Registration Should Fail At Registration

Registration Fails With Invalid Email Format
    Switch To Registration
    Fill Registration Form
    ...    tesztuser123
    ...    notanemail
    ...    Teszt123!
    ...    Teszt123!
    Execute JavaScript    document.querySelector('button[type="submit"]').click()
    Registration Should Fail

Registration Fails Without Privacy Checkbox
    Switch To Registration
    Input Text        name:username               tesztuser123
    Input Text        name:email                  teszt123@example.com
    Input Password    name:password               Teszt123!
    Input Password    name:password_confirmation  Teszt123!
    Execute JavaScript    document.querySelector('input[name="terms"]').click()
    Submit Registration
    Registration Should Fail

Registration Fails With No Uppercase Or Lowercase
    Switch To Registration
    Fill Registration Form
    ...    tesztuser123
    ...    teszt123@example.com
    ...    teszt123!
    ...    teszt123!
    Submit Registration
    Registration Should Fail At Missing Case

Registration Fails With No Number In Password
    Switch To Registration
    Fill Registration Form
    ...    tesztuser123
    ...    teszt123@example.com
    ...    Tesztabc!
    ...    Tesztabc!
    Submit Registration
    Sleep    0.5s
    Registration Should Fail At Missing Number

Registration Fails With No Special Character
    Switch To Registration
    Fill Registration Form
    ...    tesztuser123
    ...    teszt123@example.com
    ...    Teszt1234
    ...    Teszt1234
    Submit Registration
    Registration Should Fail At Missing Special Character

Registration Fails With Password Containing Space
    Switch To Registration
    Input Text        name:username               tesztuser123
    Input Text        name:email                  teszt123@example.com
    Input Password    name:password               Teszt 123!
    Input Password    name:password_confirmation  Teszt 123!
    Execute JavaScript    document.querySelector('input[name="terms"]').click()
    Execute JavaScript    document.querySelector('input[name="checkbox"]').click()
    Element Should Be Disabled    xpath://button[contains(.,"Fiók létrehozása")]

Registration Fails With Empty Username
    Switch To Registration
    Input Text        name:email                  teszt123@example.com
    Input Password    name:password               Teszt123!
    Input Password    name:password_confirmation  Teszt123!
    Execute JavaScript    document.querySelector('input[name="terms"]').click()
    Execute JavaScript    document.querySelector('input[name="checkbox"]').click()
    Element Should Be Disabled    xpath://button[contains(.,"Fiók létrehozása")]

Registration Button Disabled Until Form Is Valid
    Switch To Registration
    Input Text        name:username               tesztuser123
    Input Text        name:email                  teszt123@example.com
    Input Password    name:password               Teszt123!
    Input Password    name:password_confirmation  Teszt123!
    Element Should Be Disabled    xpath://button[contains(.,"Fiók létrehozása")]
    Execute JavaScript    document.querySelector('input[name="terms"]').click()
    Execute JavaScript    document.querySelector('input[name="checkbox"]').click()
    Element Should Be Enabled    xpath://button[contains(.,"Fiók létrehozása")]