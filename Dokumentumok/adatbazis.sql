
--a neveket lehet hoyg normalizálni kéne (vagy többesszámú vagy egyesszámú legyen minden tábla neve), és táblanévhez camelCase
--azokat a rekordokat amik nem idegenkulcs pedig camelCase-el kéne átnevezni esetleg (pl léterhozás dátuma)

CREATE TABLE kepek (
    id INT AUTO_INCREMENT PRIMARY KEY,
    url_Link VARCHAR(255) NOT NULL UNIQUE,
    alt_Szoveg VARCHAR(255),
    leiras VARCHAR(255) -- opcionális szerintem
);

CREATE TABLE varos(
    id INT AUTO_INCREMENT PRIMARY KEY,
    varos_Nev VARCHAR(100) NOT NULL UNIQUE
)

CREATE TABLE felhasznalo(
    id INT PRIMARY KEY AUTO_INCREMENT,
    felhasz_nev VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    jelszo VARCHAR(255) NOT NULL,
    profilKep_id INT,
    statusz BOOLEAN DEFAULT TRUE,
    letrehozas_Datuma TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    utolso_Belepes TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (profilKep_id) REFERENCES kepek(id) ON DELETE SET NULL
);

CREATE TABLE felhasznalo_adatok (
    felhasznalo_id INT PRIMARY KEY,
    vezeteknev VARCHAR(100),
    keresztnev VARCHAR(100),
    varos INT,
    utca VARCHAR(255),
    hazszam INT,
    emeletAjto varchar(10),
    telefonszam VARCHAR(20),
    kartyaszam INT,
    FOREIGN KEY (felhasznalo_id) REFERENCES felhasznalo(id) ON DELETE CASCADE
    FOREIGN KEY (varos) REFERENCES varosok(id) ON DELETE SET NULL
)

CREATE TABLE kategoriak (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nev VARCHAR(100) NOT NULL UNIQUE,
    fo_kategoria_id INT NULL,
    FOREIGN KEY (fo_kategoria_id) REFERENCES kategoriak(id) ON DELETE SET NULL
);

CREATE TABLE cimkek(
    id INT AUTO_INCREMENT PRIMARY KEY,
    nev VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE szinek (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nev VARCHAR(50) NOT NULL UNIQUE,
    hex_kod VARCHAR(7) NOT NULL UNIQUE
);

CREATE TABLE posztok(
    id INT PRIMARY KEY AUTO_INCREMENT,
    cim VARCHAR(255) NOT NULL,
    kivonat VARCHAR(255) NOT NULL,
    tartalom TEXT NOT NULL,
    szerzo_id INT,
    fo_kep_id INT,
    letrehozas_datuma TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modositas_datuma TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    statusz ENUM('piszkozat', 'közzétett', 'archivált') DEFAULT 'piszkozat',
    FOREIGN KEY (szerzo_id) REFERENCES felhasznalo(id) ON DELETE SET NULL,
    FOREIGN KEY (fo_kep_id) REFERENCES kepek(id) ON DELETE SET NULL
);

CREATE TABLE poszt_kepek (
    poszt_id INT NOT NULL,
    kep_id INT NOT NULL,
    sorrend INT DEFAULT 0, -- Befolyásolni lehet a sorrendet (kihagyható szerintem)
    PRIMARY KEY (poszt_id, kep_id),
    FOREIGN KEY (poszt_id) REFERENCES posztok(id) ON DELETE CASCADE,
    FOREIGN KEY (kep_id) REFERENCES kepek(id) ON DELETE CASCADE
);

CREATE TABLE poszt_cimkek (
    poszt_id INT NOT NULL,
    cimke_id INT NOT NULL,
    PRIMARY KEY (poszt_id, cimke_id),
    FOREIGN KEY (poszt_id) REFERENCES posztok(id) ON DELETE CASCADE,
    FOREIGN KEY (cimke_id) REFERENCES cimkek(id) ON DELETE CASCADE
);

CREATE TABLE kommentek(
    id INT PRIMARY KEY AUTO_INCREMENT,
    komment TEXT NOT NULL,    
    poszt_id INT NOT NULL,
    kommentelo INT NOT NULL,
    elozo_komment_id INT,
    letrehozas_datuma TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (poszt_id) REFERENCES posztok(p_id) ON DELETE CASCADE,
    FOREIGN KEY (kommentelo) REFERENCES felhasznalo(id) ON DELETE CASCADE,
    FOREIGN KEY (elozo_komment_id) REFERENCES kommentek(id) ON DELETE CASCADE
);

CREATE TABLE poszt_reakciok(
    poszt_id INT,
    felhasznalo_id INT,
    reakcio ENUM('tetszik', 'nem tetszik'),
    PRIMARY KEY (poszt_id, felhasznalo_id) -- Egy felhasználó csak egyszer reagálhat egy posztoktra
    FOREIGN KEY (poszt_id) REFERENCES posztok(id) ON DELETE CASCADE,
    FOREIGN KEY (felhasznalo_id) REFERENCES felhasznalo(id) ON DELETE CASCADE
);

CREATE TABLE termekek (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nev VARCHAR(255) NOT NULL,
    leiras TEXT,
    ar DECIMAL(10, 2) NOT NULL,
    darab INT NOT NULL DEFAULT 0,
    kategoria_id INT,
    fo_kep_id INT NULL,
    FOREIGN KEY (kategoria_id) REFERENCES kategoriak(id) ON DELETE SET NULL,
    FOREIGN KEY (fo_kep_id) REFERENCES kepek(id) ON DELETE SET NULL
);

CREATE TABLE termek_kepek (
    termek_id INT NOT NULL,
    kep_id INT NOT NULL,
    sort_order INT DEFAULT 0,
    PRIMARY KEY (termek_id, kep_id),
    FOREIGN KEY (termek_id) REFERENCES termekek(id) ON DELETE CASCADE,
    FOREIGN KEY (kep_id) REFERENCES kepek(id) ON DELETE CASCADE
);

CREATE TABLE termekek_cimkek(
    termek_id INT,
    cimke_id INT,
    PRIMARY KEY (termek_id, cimke_id),
    FOREIGN KEY (termek_id) REFERENCES termekek(id) ON DELETE CASCADE,
    FOREIGN KEY (cimke_id) REFERENCES cimkek(id) ON DELETE CASCADE
);

CREATE TABLE termek_szinek(
    termek_id INT NOT NULL,
    szin_id INT NOT NULL,
    PRIMARY KEY (termek_id, szin_id),
    FOREIGN KEY (termek_id) REFERENCES termekek(id),
    FOREIGN KEY (szin_id) REFERENCES szinek(id)
);

CREATE TABLE kedvencek(
    felhasznalo_id INT,
    termek_id INT,
    PRIMARY KEY (felhasznalo_id, termek_id),
    FOREIGN KEY (felhasznalo_id) REFERENCES felhasznalo(id),
    FOREIGN KEY (termek_id) REFERENCES termekek(id),
)

CREATE TABLE rendelesek(
    id INT AUTO_INCREMENT PRIMARY KEY,
    felhasznalo_id INT NOT NULL,
    statusz ENUM('függőben', 'szállítás alatt', 'befejezve', 'törölve') NOT NULL DEFAULT 'függőben',
    osszeg DECIMAL(10, 2) NOT NULL,
    rendeles_Datuma TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (felhasznalo_id) REFERENCES felhasznalo(id) ON DELETE CASCADE,
    FOREIGN KEY (termek_id) REFERENCES termekek(id) ON DELETE CASCADE
)

CREATE TABLE rendelt_termekek(
    id INT AUTO_INCREMENT PRIMARY KEY,
    rendeles_id INT NOT NULL,
    termek_id INT NOT NULL,
    mennyiseg INT NOT NULL,
    egysegar DECIMAL(10, 2) NOT NULL,
    szin_id INT NOT NULL,
    FOREIGN KEY (rendeles_id) REFERENCES rendelesek(id) ON DELETE CASCADE,
    FOREIGN KEY (termek_id) REFERENCES termekek(id) ON DELETE CASCADE,
    FOREIGN KEY (szin_id) REFERENCES szinek(id) ON DELETE SET NULL
)