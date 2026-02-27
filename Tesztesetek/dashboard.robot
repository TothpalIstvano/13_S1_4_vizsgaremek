*** Settings ***
Resource    resources.robot
Test Setup    Open Registration Page
Test Teardown    Close Browser

*** Test Cases ***

# --- Navigáció ---

Dashboard Betölt Bejelentkezés Után
    Login As Admin And Go To Dashboard
    Element Should Be Visible    xpath://h2[contains(.,"Dashboard")]

Dashboard Sidebar Megjelenik
    Login As Admin And Go To Dashboard
    Element Should Be Visible    xpath://div[contains(@class,"sidebar")]
    Element Should Be Visible    xpath://div[contains(@class,"sidebar-header")]//h1[contains(.,"Kreatív Hobbi")]

Dashboard Sidebar Tartalmaz Minden Menüpontot
    Login As Admin And Go To Dashboard
    Element Should Be Visible    xpath://a[contains(@class,"nav-link") and contains(.,"Dashboard")]
    Element Should Be Visible    xpath://a[contains(@class,"nav-link") and contains(.,"Termékek")]
    Element Should Be Visible    xpath://a[contains(@class,"nav-link") and contains(.,"Blog Bejegyzések")]
    Element Should Be Visible    xpath://a[contains(@class,"nav-link") and contains(.,"Felhasznalok")]
    Element Should Be Visible    xpath://a[contains(@class,"nav-link") and contains(.,"Analitika")]

Dashboard Sidebar Dashboard Link Aktív Alapból
    Login As Admin And Go To Dashboard
    Dashboard Sidebar Link Should Be Active    Dashboard

Navigáció Termékek Nézetre
    Login As Admin And Go To Dashboard
    Click Element    xpath://a[contains(@class,"nav-link") and contains(.,"Termékek")]
    Wait Until Element Is Visible    xpath://h2[contains(.,"Termékek")]    timeout=5s
    Dashboard Sidebar Link Should Be Active    Termékek

Navigáció Blog Nézetre
    Login As Admin And Go To Dashboard
    Click Element    xpath://a[contains(@class,"nav-link") and contains(.,"Blog Bejegyzések")]
    Wait Until Element Is Visible    xpath://h2[contains(.,"Blog Bejegyzések")]    timeout=5s
    Dashboard Sidebar Link Should Be Active    Blog Bejegyzések

Navigáció Felhasználók Nézetre
    Login As Admin And Go To Dashboard
    Click Element    xpath://a[contains(@class,"nav-link") and contains(.,"Felhasznalok")]
    Wait Until Element Is Visible    xpath://h2[contains(.,"Felhasználók")]    timeout=5s
    Dashboard Sidebar Link Should Be Active    Felhasznalok

Navigáció Analitika Nézetre
    Login As Admin And Go To Dashboard
    Click Element    xpath://a[contains(@class,"nav-link") and contains(.,"Analitika")]
    Wait Until Element Is Visible    xpath://h2[contains(.,"Analitika")]    timeout=5s
    Dashboard Sidebar Link Should Be Active    Analitika

# --- Dashboard Statisztika Kártyák ---

Dashboard Statisztika Kártyák Megjelennek
    Login As Admin And Go To Dashboard
    Element Should Be Visible    xpath://div[contains(@class,"stat-card")]

Dashboard Összes Értékesítés Kártya Megjelenik
    Login As Admin And Go To Dashboard
    Element Should Be Visible    xpath://div[contains(@class,"stat-title") and contains(.,"Összes Értékesítés")]

Dashboard Rendelések Kártya Megjelenik
    Login As Admin And Go To Dashboard
    Element Should Be Visible    xpath://div[contains(@class,"stat-title") and contains(.,"Rendelések")]

Dashboard Termékek Kártya Megjelenik
    Login As Admin And Go To Dashboard
    Element Should Be Visible    xpath://div[contains(@class,"stat-title") and contains(.,"Termékek")]

Dashboard Vásárlók Kártya Megjelenik
    Login As Admin And Go To Dashboard
    Element Should Be Visible    xpath://div[contains(@class,"stat-title") and contains(.,"Vásárlók")]

Dashboard Statisztika Értékek Nem Üresek
    Login As Admin And Go To Dashboard
    ${val}=    Get Text    xpath:(//div[contains(@class,"stat-value")])[1]
    Should Not Be Empty    ${val}

# --- Frissítés Gomb ---

Dashboard Frissítés Gomb Megjelenik
    Login As Admin And Go To Dashboard
    Element Should Be Visible    xpath://button[contains(.,"Frissítés")]

Dashboard Frissítés Gomb Működik
    Login As Admin And Go To Dashboard
    Click Element    xpath://button[contains(.,"Frissítés")]
    Sleep    1s
    Element Should Be Visible    xpath://div[contains(@class,"stat-card")]

# --- Legújabb Rendelések Táblázat ---

Dashboard Rendelések Táblázat Megjelenik
    Login As Admin And Go To Dashboard
    Element Should Be Visible    xpath://h3[contains(.,"Legújabb Rendelések")]

Dashboard Rendelések Táblázat Fejléce Helyes
    Login As Admin And Go To Dashboard
    Element Should Be Visible    xpath://th[contains(.,"Rendelés ID")]
    Element Should Be Visible    xpath://th[contains(.,"Vásárló")]
    Element Should Be Visible    xpath://th[contains(.,"Termékek")]
    Element Should Be Visible    xpath://th[contains(.,"Összeg")]
    Element Should Be Visible    xpath://th[contains(.,"Státusz")]
    Element Should Be Visible    xpath://th[contains(.,"Dátum")]

# --- Termékek Nézet ---

Termékek Táblázat Megjelenik
    Login As Admin And Go To Dashboard
    Click Element    xpath://a[contains(@class,"nav-link") and contains(.,"Termékek")]
    Wait Until Element Is Visible    xpath://h3[contains(.,"Összes Termék")]    timeout=5s

Termékek Új Termék Gomb Megjelenik
    Login As Admin And Go To Dashboard
    Click Element    xpath://a[contains(@class,"nav-link") and contains(.,"Termékek")]
    Wait Until Element Is Visible    xpath://button[contains(.,"Új Termék")]    timeout=5s

Termékek Táblázat Fejléce Helyes
    Login As Admin And Go To Dashboard
    Click Element    xpath://a[contains(@class,"nav-link") and contains(.,"Termékek")]
    Wait Until Element Is Visible    xpath://h3[contains(.,"Összes Termék")]    timeout=5s
    Element Should Be Visible    xpath://th[contains(.,"Név")]
    Element Should Be Visible    xpath://th[contains(.,"Kategória")]
    Element Should Be Visible    xpath://th[contains(.,"Ár")]
    Element Should Be Visible    xpath://th[contains(.,"Készlet")]
    Element Should Be Visible    xpath://th[contains(.,"Státusz")]
    Element Should Be Visible    xpath://th[contains(.,"Műveletek")]

Termékek Keresőmező Működik
    Login As Admin And Go To Dashboard
    Click Element    xpath://a[contains(@class,"nav-link") and contains(.,"Termékek")]
    Wait Until Element Is Visible    xpath://input[contains(@placeholder,"Keresés termékek között")]    timeout=5s
    Input Text    xpath://input[contains(@placeholder,"Keresés termékek között")]    Fonal
    Sleep    0.5s
    ${rows}=    Get WebElements    xpath://tbody/tr
    FOR    ${row}    IN    @{rows}
        Element Should Contain    ${row}    Fonal
    END

Termékek Keresőmező Üres Találat
    Login As Admin And Go To Dashboard
    Click Element    xpath://a[contains(@class,"nav-link") and contains(.,"Termékek")]
    Wait Until Element Is Visible    xpath://input[contains(@placeholder,"Keresés termékek között")]    timeout=5s
    Input Text    xpath://input[contains(@placeholder,"Keresés termékek között")]    xxxxxnemletezik12345
    Sleep    0.5s
    ${rows}=    Get WebElements    xpath://tbody/tr
    Length Should Be    ${rows}    0

Termékek Új Termék Modal Megnyílik
    Login As Admin And Go To Dashboard
    Click Element    xpath://a[contains(@class,"nav-link") and contains(.,"Termékek")]
    Wait Until Element Is Visible    xpath://button[contains(.,"Új Termék")]    timeout=5s
    Click Element    xpath://button[contains(.,"Új Termék")]
    Wait Until Element Is Visible    xpath://h3[contains(.,"Új Termék")]    timeout=5s

Termékek Új Termék Modal Bezárul Mégsére
    Login As Admin And Go To Dashboard
    Click Element    xpath://a[contains(@class,"nav-link") and contains(.,"Termékek")]
    Wait Until Element Is Visible    xpath://button[contains(.,"Új Termék")]    timeout=5s
    Click Element    xpath://button[contains(.,"Új Termék")]
    Wait Until Element Is Visible    xpath://h3[contains(.,"Új Termék")]    timeout=5s
    Click Element    xpath://div[contains(@class,"modal-footer")]//button[contains(.,"Mégse")]
    Wait Until Element Is Not Visible    xpath://h3[contains(.,"Új Termék")]    timeout=5s

Termékek Szerkesztés Modal Megnyílik
    Login As Admin And Go To Dashboard
    Click Element    xpath://a[contains(@class,"nav-link") and contains(.,"Termékek")]
    Wait Until Element Is Visible    xpath://tbody/tr    timeout=10s
    Click Element    xpath:(//button[contains(@class,"btn-warning")])[1]
    Wait Until Element Is Visible    xpath://h3[contains(.,"Termék Szerkesztése")]    timeout=5s

Termékek Törlés Gomb Megjelenik
    Login As Admin And Go To Dashboard
    Click Element    xpath://a[contains(@class,"nav-link") and contains(.,"Termékek")]
    Wait Until Element Is Visible    xpath://tbody/tr    timeout=10s
    Element Should Be Visible    xpath:(//button[contains(@class,"btn-danger")])[1]

# --- Felhasználók Nézet ---

Felhasználók Táblázat Megjelenik
    Login As Admin And Go To Dashboard
    Click Element    xpath://a[contains(@class,"nav-link") and contains(.,"Felhasznalok")]
    Wait Until Element Is Visible    xpath://h3[contains(.,"Összes felhasználó")]    timeout=5s

Felhasználók Táblázat Fejléce Helyes
    Login As Admin And Go To Dashboard
    Click Element    xpath://a[contains(@class,"nav-link") and contains(.,"Felhasznalok")]
    Wait Until Element Is Visible    xpath://h3[contains(.,"Összes felhasználó")]    timeout=5s
    Element Should Be Visible    xpath://th[contains(.,"Név")]
    Element Should Be Visible    xpath://th[contains(.,"Szerepkör")]
    Element Should Be Visible    xpath://th[contains(.,"Email")]
    Element Should Be Visible    xpath://th[contains(.,"Aktív")]
    Element Should Be Visible    xpath://th[contains(.,"Regisztráció ideje")]

Felhasználók Keresőmező Működik
    Login As Admin And Go To Dashboard
    Click Element    xpath://a[contains(@class,"nav-link") and contains(.,"Felhasznalok")]
    Wait Until Element Is Visible    xpath://input[contains(@placeholder,"Keresés felhasználók között")]    timeout=5s
    Input Text    xpath://input[contains(@placeholder,"Keresés felhasználók között")]    admin
    Sleep    10s
    Element Should Be Visible    xpath://tr[contains(.,"admin")]

Felhasználók Új Felhasználó Modal Megnyílik
    Login As Admin And Go To Dashboard
    Click Element    xpath://a[contains(@class,"nav-link") and contains(.,"Felhasznalok")]
    Wait Until Element Is Visible    xpath://button[contains(.,"Új felhasználó")]    timeout=5s
    Click Element    xpath://button[contains(.,"Új felhasználó")]
    Wait Until Element Is Visible    xpath://h3[contains(.,"Új Felhasználó")]    timeout=5s

Felhasználók Új Felhasználó Modal Bezárul Mégsére
    Login As Admin And Go To Dashboard
    Click Element    xpath://a[contains(@class,"nav-link") and contains(.,"Felhasznalok")]
    Wait Until Element Is Visible    xpath://button[contains(.,"Új felhasználó")]    timeout=5s
    Click Element    xpath://button[contains(.,"Új felhasználó")]
    Wait Until Element Is Visible    xpath://h3[contains(.,"Új Felhasználó")]    timeout=5s
    Click Element    xpath://div[contains(@class,"modal-footer")]//button[contains(.,"Mégse")]
    Wait Until Element Is Not Visible    xpath://h3[contains(.,"Új Felhasználó")]    timeout=5s

Felhasználók Saját Fiók Szerkesztés Tiltott
    Login As Admin And Go To Dashboard
    Click Element    xpath://a[contains(@class,"nav-link") and contains(.,"Felhasznalok")]
    Wait Until Element Is Visible    xpath://tbody/tr    timeout=10s
    # Find the row with admin email and check edit button is disabled
    ${disabled}=    Execute JavaScript
    ...    return [...document.querySelectorAll('tbody tr')].find(r => r.textContent.includes('test@example.com'))?.querySelector('button.btn-warning')?.disabled
    Should Be True    ${disabled}

Felhasználók Saját Fiók Törlés Tiltott
    Login As Admin And Go To Dashboard
    Click Element    xpath://a[contains(@class,"nav-link") and contains(.,"Felhasznalok")]
    Wait Until Element Is Visible    xpath://tbody/tr    timeout=10s
    ${disabled}=    Execute JavaScript
    ...    return [...document.querySelectorAll('tbody tr')].find(r => r.textContent.includes('test@example.com'))?.querySelector('button.btn-danger')?.disabled
    Should Be True    ${disabled}

Felhasználók Szerkesztés Modal Tartalmaz Szerepkör Selectet
    Login As Admin And Go To Dashboard
    Click Element    xpath://a[contains(@class,"nav-link") and contains(.,"Felhasznalok")]
    Wait Until Element Is Visible    xpath://tbody/tr    timeout=10s
    # Click edit on first non-self user
    ${clicked}=    Execute JavaScript
    ...    const btn = [...document.querySelectorAll('tbody tr')].find(r => !r.textContent.includes('test@example.com'))?.querySelector('button.btn-warning'); if(btn && !btn.disabled) { btn.click(); return true; } return false;
    Should Be True    ${clicked}
    Wait Until Element Is Visible    xpath://h3[contains(.,"Felhasználó Szerkesztése")]    timeout=5s
    Element Should Be Visible    xpath://select[contains(@class,"form-select")]

# --- Blog Nézet ---

Blog Táblázat Megjelenik
    Login As Admin And Go To Dashboard
    Click Element    xpath://a[contains(@class,"nav-link") and contains(.,"Blog Bejegyzések")]
    Wait Until Element Is Visible    xpath://h3[contains(.,"Összes Bejegyzés")]    timeout=5s

Blog Táblázat Fejléce Helyes
    Login As Admin And Go To Dashboard
    Click Element    xpath://a[contains(@class,"nav-link") and contains(.,"Blog Bejegyzések")]
    Wait Until Element Is Visible    xpath://h3[contains(.,"Összes Bejegyzés")]    timeout=5s
    Element Should Be Visible    xpath://th[contains(.,"Cím")]
    Element Should Be Visible    xpath://th[contains(.,"Szerző")]
    Element Should Be Visible    xpath://th[contains(.,"Címkék")]
    Element Should Be Visible    xpath://th[contains(.,"Dátum")]
    Element Should Be Visible    xpath://th[contains(.,"Státusz")]
    Element Should Be Visible    xpath://th[contains(.,"Műveletek")]

Blog Keresőmező Működik
    Login As Admin And Go To Dashboard
    Click Element    xpath://a[contains(@class,"nav-link") and contains(.,"Blog Bejegyzések")]
    Wait Until Element Is Visible    xpath://input[contains(@placeholder,"Keresés bejegyzések között")]    timeout=5s
    Input Text    xpath://input[contains(@placeholder,"Keresés bejegyzések között")]    First
    Sleep    10s
    Element Should Be Visible    xpath://tr[contains(.,"First")]

Blog Keresőmező Üres Találat
    Login As Admin And Go To Dashboard
    Click Element    xpath://a[contains(@class,"nav-link") and contains(.,"Blog Bejegyzések")]
    Wait Until Element Is Visible    xpath://input[contains(@placeholder,"Keresés bejegyzések között")]    timeout=5s
    Input Text    xpath://input[contains(@placeholder,"Keresés bejegyzések között")]    xxxxxnemletezik12345
    Sleep    0.5s
    ${rows}=    Get WebElements    xpath://tbody/tr
    Length Should Be    ${rows}    0

Blog Új Bejegyzés Modal Megnyílik
    Login As Admin And Go To Dashboard
    Click Element    xpath://a[contains(@class,"nav-link") and contains(.,"Blog Bejegyzések")]
    Wait Until Element Is Visible    xpath://button[contains(.,"Új Bejegyzés")]    timeout=5s
    Click Element    xpath://button[contains(.,"Új Bejegyzés")]
    Wait Until Element Is Visible    xpath://h3[contains(.,"Új poszt hozzáadása")]    timeout=10s

Blog Új Bejegyzés Modal Bezárul Mégsére
    Login As Admin And Go To Dashboard
    Click Element    xpath://a[contains(@class,"nav-link") and contains(.,"Blog Bejegyzések")]
    Wait Until Element Is Visible    xpath://button[contains(.,"Új Bejegyzés")]    timeout=5s
    Click Element    xpath://button[contains(.,"Új Bejegyzés")]
    Wait Until Element Is Visible    xpath://h3[contains(.,"Új poszt hozzáadása")]    timeout=10s
    Click Element    xpath://div[contains(@class,"modal-footer")]//button[contains(.,"Mégse")]
    Wait Until Element Is Not Visible    xpath://h3[contains(.,"Új poszt hozzáadása")]    timeout=5s

Blog Szerkesztés Modal Megnyílik
    Login As Admin And Go To Dashboard
    Click Element    xpath://a[contains(@class,"nav-link") and contains(.,"Blog Bejegyzések")]
    Wait Until Element Is Visible    xpath://tbody/tr    timeout=10s
    Click Element    xpath:(//button[contains(@class,"btn-warning")])[1]
    Wait Until Element Is Visible    xpath://h3[contains(.,"Poszt szerkesztése")]    timeout=10s

Blog Közzétett Státusz Badge Megjelenik
    Login As Admin And Go To Dashboard
    Click Element    xpath://a[contains(@class,"nav-link") and contains(.,"Blog Bejegyzések")]
    Wait Until Element Is Visible    xpath://tbody/tr    timeout=10s
    Element Should Be Visible    xpath://span[contains(@class,"badge") and (contains(.,"Publikálva") or contains(.,"törölt"))]

# --- Analitika Nézet ---

Analitika Nézet Megjelenik
    Login As Admin And Go To Dashboard
    Click Element    xpath://a[contains(@class,"nav-link") and contains(.,"Analitika")]
    Wait Until Element Is Visible    xpath://h2[contains(.,"Analitika")]    timeout=5s

Analitika Grafikonok Megjelennek
    Login As Admin And Go To Dashboard
    Click Element    xpath://a[contains(@class,"nav-link") and contains(.,"Analitika")]
    Wait Until Element Is Visible    xpath://h3[contains(.,"Eladott Termékek Havi Bontásban")]    timeout=5s
    Element Should Be Visible    xpath://h3[contains(.,"Bevétel Havi Trendje")]

# --- Dashboard Grafikonok ---

Dashboard Havi Értékesítés Grafikon Megjelenik
    Login As Admin And Go To Dashboard
    Element Should Be Visible    xpath://h3[contains(.,"Havi Értékesítés")]

Dashboard Kategória Grafikon Megjelenik
    Login As Admin And Go To Dashboard
    Element Should Be Visible    xpath://h3[contains(.,"Kategóriák szerinti termék megosztás")]

# --- Nézet váltás és visszaváltás ---

Nézet Váltás Dashboard Ról Termékekre És Vissza
    Login As Admin And Go To Dashboard
    Click Element    xpath://a[contains(@class,"nav-link") and contains(.,"Termékek")]
    Wait Until Element Is Visible    xpath://h2[contains(.,"Termékek")]    timeout=5s
    Click Element    xpath://a[contains(@class,"nav-link") and contains(.,"Dashboard")]
    Wait Until Element Is Visible    xpath://h2[contains(.,"Dashboard")]    timeout=5s
    Element Should Be Visible    xpath://div[contains(@class,"stat-card")]

Analitika Után Dashboard Grafikonok Újra Megjelennek
    Login As Admin And Go To Dashboard
    Click Element    xpath://a[contains(@class,"nav-link") and contains(.,"Analitika")]
    Wait Until Element Is Visible    xpath://h2[contains(.,"Analitika")]    timeout=5s
    Click Element    xpath://a[contains(@class,"nav-link") and contains(.,"Dashboard")]
    Wait Until Element Is Visible    xpath://h2[contains(.,"Dashboard")]    timeout=5s
    Element Should Be Visible    xpath://h3[contains(.,"Havi Értékesítés")]