*** Settings ***
Resource    resources.robot
Test Setup    Open Registration Page
Test Teardown    Close Browser

*** Test Cases ***

# ──────────────────────────────────────────────────────────────
# Sikeres regisztráció
# ──────────────────────────────────────────────────────────────

R01 - Successful Registration
    # Egyedi email, valid jelszó – sikeres regisztrációt vár
    Switch To Registration
    Fill Registration Form
    ...    tesztuser1232
    ...    teszt1231@example.com
    ...    Teszt123!
    ...    Teszt123!
    Submit Registration
    Registration Should Succeed

# ──────────────────────────────────────────────────────────────
# Jelszó validációk
# ──────────────────────────────────────────────────────────────

R02 - Registration Fails With Short Password
    # 3 karakteres jelszó – "legalább 8 karakter" hibaüzenetet vár
    Switch To Registration
    Fill Registration Form
    ...    tesztuser1231
    ...    teszt_short@example.com
    ...    123
    ...    123
    Submit Registration
    Registration Should Fail At Short Password

R03 - Registration Fails With Mismatched Passwords
    # A két jelszó nem egyezik
    Switch To Registration
    Fill Registration Form
    ...    tesztuser123
    ...    teszt_mismatch@example.com
    ...    Teszt123!
    ...    Masik123!
    Submit Registration
    Registration Should Fail At Mismatched Password

Registration Fails With No Uppercase Or Lowercase
    # Csak kisbetűs jelszó – kis/nagybetű hibaüzenetet vár
    Switch To Registration
    Fill Registration Form
    ...    tesztuser123
    ...    teszt_case@example.com
    ...    teszt123!
    ...    teszt123!
    Submit Registration
    Registration Should Fail At Missing Case

Registration Fails With No Number In Password
    # Nincs szám a jelszóban
    Switch To Registration
    Fill Registration Form
    ...    tesztuser123
    ...    teszt_nonum@example.com
    ...    Tesztabc!
    ...    Tesztabc!
    Submit Registration
    Sleep    0.5s
    Registration Should Fail At Missing Number

Registration Fails With No Special Character
    # Nincs speciális karakter a jelszóban
    Switch To Registration
    Fill Registration Form
    ...    tesztuser123
    ...    teszt_nospec@example.com
    ...    Teszt1234
    ...    Teszt1234
    Submit Registration
    Registration Should Fail At Missing Special Character

Registration Fails With Password Containing Space
    # Szóközt tartalmazó jelszó – a gomb letiltott marad
    Switch To Registration
    Input Text        name:username               tesztuser123
    Input Text        name:email                  teszt_space@example.com
    Input Password    name:password               Teszt 123!
    Input Password    name:password_confirmation  Teszt 123!
    Execute JavaScript    document.querySelector('input[name="terms"]').click()
    Execute JavaScript    document.querySelector('input[name="checkbox"]').click()
    Element Should Be Disabled    xpath://button[contains(.,"Fiók létrehozása")]

# ──────────────────────────────────────────────────────────────
# Hiányzó / helytelen adatok
# ──────────────────────────────────────────────────────────────

Registration Fails Without Terms And Privacy Checkboxes
    # Egyik checkbox sem kattintva – a gomb letiltott marad
    Switch To Registration
    Input Text        name:username               tesztuser123
    Input Text        name:email                  teszt_nochk@example.com
    Input Password    name:password               Teszt123!
    Input Password    name:password_confirmation  Teszt123!
    # Egyik checkbox sem kattintva
    Element Should Be Disabled    xpath://button[contains(.,"Fiók létrehozása")]

Registration Fails Without Privacy Checkbox Only
    # Csak a terms van kattintva, privacy (checkbox) nem
    Switch To Registration
    Input Text        name:username               tesztuser123
    Input Text        name:email                  teszt_noprivacy@example.com
    Input Password    name:password               Teszt123!
    Input Password    name:password_confirmation  Teszt123!
    Execute JavaScript    document.querySelector('input[name="terms"]').click()
    # "checkbox" (adatvédelmi) nem kattintva
    Element Should Be Disabled    xpath://button[contains(.,"Fiók létrehozása")]

Registration Fails Without Terms Checkbox Only
    # Csak az adatvédelmi checkbox van kattintva, terms nem
    Switch To Registration
    Input Text        name:username               tesztuser123
    Input Text        name:email                  teszt_noterms@example.com
    Input Password    name:password               Teszt123!
    Input Password    name:password_confirmation  Teszt123!
    Execute JavaScript    document.querySelector('input[name="checkbox"]').click()
    # "terms" nem kattintva
    Element Should Be Disabled    xpath://button[contains(.,"Fiók létrehozása")]

Registration Fails With Invalid Email Format
    # Érvénytelen email – a böngésző natívan blokkolja, a gomb nem navigál
    Switch To Registration
    Input Text        name:username               tesztuser123
    Input Text        name:email                  notanemail
    Input Password    name:password               Teszt123!
    Input Password    name:password_confirmation  Teszt123!
    Execute JavaScript    document.querySelector('input[name="terms"]').click()
    Execute JavaScript    document.querySelector('input[name="checkbox"]').click()
    Execute JavaScript    document.querySelector('button[type="submit"]').click()
    Location Should Contain    ${URL}
        ${loc}=    Get Location
    Should Not Contain    ${loc}    /Profil

Registration Fails With Empty Username
    # Üres felhasználónév – a gomb letiltott marad
    Switch To Registration
    Input Text        name:email                  teszt_nouser@example.com
    Input Password    name:password               Teszt123!
    Input Password    name:password_confirmation  Teszt123!
    Execute JavaScript    document.querySelector('input[name="terms"]').click()
    Execute JavaScript    document.querySelector('input[name="checkbox"]').click()
    Element Should Be Disabled    xpath://button[contains(.,"Fiók létrehozása")]

# ──────────────────────────────────────────────────────────────
# Duplikált email
# ──────────────────────────────────────────────────────────────

Registration Fails With Duplicate Email
    # Az email már foglalt (pl. a test@example.com admin fiók)
    Switch To Registration
    Fill Registration Form
    ...    uniqueuser999
    ...    test@example.com
    ...    Teszt123!
    ...    Teszt123!
    Execute JavaScript    document.querySelector('button[type="submit"]').click()
    Registration Should Fail At Registration

# ──────────────────────────────────────────────────────────────
# Gomb állapot
# ──────────────────────────────────────────────────────────────

Registration Button Disabled Until Form Is Valid
    # A gomb csak akkor válik aktívvá, ha minden mező és checkbox helyes
    Switch To Registration
    Input Text        name:username               tesztuser123
    Input Text        name:email                  teszt_btn@example.com
    Input Password    name:password               Teszt123!
    Input Password    name:password_confirmation  Teszt123!
    # Még nincs kattintva egyik checkbox sem
    Element Should Be Disabled    xpath://button[contains(.,"Fiók létrehozása")]
    Execute JavaScript    document.querySelector('input[name="terms"]').click()
    # Csak az egyik → még letiltott
    Element Should Be Disabled    xpath://button[contains(.,"Fiók létrehozása")]
    Execute JavaScript    document.querySelector('input[name="checkbox"]').click()
    # Mindkettő kattintva → aktív
    Element Should Be Enabled    xpath://button[contains(.,"Fiók létrehozása")]
