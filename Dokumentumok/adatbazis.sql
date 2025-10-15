    CREATE TABLE kepek (
    k_id INT AUTO_INCREMENT PRIMARY KEY,
    url_link VARCHAR(255) NOT NULL UNIQUE,
    alt_szoveg VARCHAR(255),
    leiras TEXT -- opcionális szerintem
);

CREATE TABLE felhasznalo(
    f_id INT PRIMARY KEY AUTO_INCREMENT,
    felhasz_nev VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    jelszo VARCHAR(255) NOT NULL,
    profilkep_id INT,
    statusz BOOLEAN DEFAULT TRUE,
    letrehozas_datuma TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (profilkep_id) REFERENCES kepek(k_id) ON DELETE SET NULL
);

CREATE TABLE kategoriak (
    kat_id INT AUTO_INCREMENT PRIMARY KEY,
    nev VARCHAR(100) NOT NULL UNIQUE,
    fo_kategoria_id INT NULL,
    FOREIGN KEY (fo_kategoria_id) REFERENCES kategoriak(kat_id) ON DELETE SET NULL
);

CREATE TABLE cimkek(
    c_id INT AUTO_INCREMENT PRIMARY KEY,
    nev VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE szinek (
    sz_id INT PRIMARY KEY AUTO_INCREMENT,
    szin_nev VARCHAR(50) NOT NULL UNIQUE,
    hex_kod VARCHAR(7) NOT NULL UNIQUE
);

CREATE TABLE posztok(
    p_id INT PRIMARY KEY AUTO_INCREMENT,
    cim VARCHAR(255) NOT NULL,
    kivonat VARCHAR(255) NOT NULL,
    tartalom TEXT NOT NULL,
    szerzo_id INT,
    fo_kep_id INT NOT NULL,
    letrehozas_datuma TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modositas_datuma TIMESTAMP,
    statusz ENUM('piszkozat', 'közzétett', 'archivált') DEFAULT 'piszkozat',
    FOREIGN KEY (szerzo_id) REFERENCES felhasznalo(f_id) ON DELETE SET NULL,
    FOREIGN KEY (fo_kep_id) REFERENCES kepek(k_id) ON DELETE SET NULL
);

CREATE TABLE poszt_kepek (
    poszt_id INT NOT NULL,
    kep_id INT NOT NULL,
    sorrend INT DEFAULT 0, -- Befolyásolni lehet a sorrendet (kihagyható szerintem)
    PRIMARY KEY (poszt_id, kep_id),
    FOREIGN KEY (poszt_id) REFERENCES posztok(p_id) ON DELETE CASCADE,
    FOREIGN KEY (kep_id) REFERENCES kepek(k_id) ON DELETE CASCADE
);

CREATE TABLE poszt_cimkek (
    poszt_id INT NOT NULL,
    cimke_id INT NOT NULL,
    PRIMARY KEY (poszt_id, cimke_id),
    FOREIGN KEY (poszt_id) REFERENCES posztok(p_id) ON DELETE CASCADE,
    FOREIGN KEY (cimke_id) REFERENCES cimkek(c_id) ON DELETE CASCADE
);

CREATE TABLE kommentek(
    kom_id INT PRIMARY KEY AUTO_INCREMENT,
    komment TEXT NOT NULL,    
    poszt_id INT NOT NULL,
    kommentelo INT NOT NULL,
    elozo_komment_id INT,
    letrehozas_datuma TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    statusz ENUM('aktív', 'törölt') DEFAULT 'aktív',
    FOREIGN KEY (poszt_id) REFERENCES posztok(p_id) ON DELETE CASCADE,
    FOREIGN KEY (kommentelo) REFERENCES felhasznalo(f_id) ON DELETE CASCADE,
    FOREIGN KEY (elozo_komment_id) REFERENCES kommentek(kom_id) ON DELETE SET NULL
);

CREATE TABLE poszt_reakciok(
    poszt_id INT NOT NULL,
    felhasznalo_id INT NOT NULL,
    reakcio ENUM('tetszik', 'nem tetszik') NOT NULL,
    PRIMARY KEY (poszt_id, felhasznalo_id), -- Egy felhasználó csak egyszer reagálhat egy posztra
    FOREIGN KEY (poszt_id) REFERENCES posztok(p_id) ON DELETE CASCADE,
    FOREIGN KEY (felhasznalo_id) REFERENCES felhasznalo(f_id) ON DELETE CASCADE
);

CREATE TABLE termekek (
    t_id INT AUTO_INCREMENT PRIMARY KEY,
    nev VARCHAR(255) NOT NULL,
    leiras TEXT,
    ar DECIMAL(10, 2) NOT NULL,
    darab INT NOT NULL DEFAULT 0,
    kategoria_id INT,
    fo_kep_id INT NULL,
    FOREIGN KEY (kategoria_id) REFERENCES kategoriak(kat_id) ON DELETE SET NULL,
    FOREIGN KEY (fo_kep_id) REFERENCES kepek(k_id) ON DELETE SET NULL
);

CREATE TABLE termek_kepek (
    termek_id INT NOT NULL,
    kep_id INT NOT NULL,
    rendezes INT DEFAULT 0, -- kihagyható szerintem
    PRIMARY KEY (termek_id, kep_id),
    FOREIGN KEY (termek_id) REFERENCES termekek(t_id) ON DELETE CASCADE,
    FOREIGN KEY (kep_id) REFERENCES kepek(k_id) ON DELETE CASCADE
);

CREATE TABLE termek_cimkek(
    termek_id INT NOT NULL,
    cimke_id INT NOT NULL,
    PRIMARY KEY (termek_id, cimke_id),
    FOREIGN KEY (termek_id) REFERENCES termekek(t_id) ON DELETE CASCADE,
    FOREIGN KEY (cimke_id) REFERENCES cimkek(c_id) ON DELETE CASCADE
);

CREATE TABLE termek_szinek(
    termek_id INT NOT NULL,
    szin_id INT NOT NULL,
    PRIMARY KEY (termek_id, szin_id),
    FOREIGN KEY (termek_id) REFERENCES termekek(t_id) ON DELETE CASCADE,
    FOREIGN KEY (szin_id) REFERENCES szinek(sz_id) ON DELETE CASCADE
);

CREATE TABLE kedvencek(
    felhasznalo_id INT NOT NULL,
    termek_id INT NOT NULL,
    PRIMARY KEY (felhasznalo_id, termek_id),
    FOREIGN KEY (felhasznalo_id) REFERENCES felhasznalo(f_id) ON DELETE CASCADE,
    FOREIGN KEY (termek_id) REFERENCES termekek(t_id) ON DELETE CASCADE
)