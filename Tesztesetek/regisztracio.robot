*** Settings ***
Resource    resources.robot
Test Setup    Open Registration Page
Test Teardown    Close Browser

*** Test Cases ***

Successful Registration
    Switch To Registration
    Fill Registration Form
    ...    tesztuser123
    ...    teszt123@example.com
    ...    Teszt123!
    ...    Teszt123!
    Submit Registration
    Registration Should Succeed

Registration Fails With Weak Password
    Switch To Registration
    Fill Registration Form
    ...    tesztuser123
    ...    teszt123@example.com
    ...    123
    ...    123
    Submit Registration
    Registration Should Fail

Registration Fails With Mismatched Passwords
    Switch To Registration
    Fill Registration Form
    ...    tesztuser123
    ...    teszt123@example.com
    ...    Teszt123!
    ...    Masik123!
    Submit Registration
    Registration Should Fail

Registration Fails Without Terms
    Switch To Registration
    Input Text    name:username    tesztuser123
    Input Text    name:email    teszt123@example.com
    Input Password    name:password    Teszt123!
    Input Password    name:password_confirmation    Teszt123!
    Submit Registration
    Registration Should Fail