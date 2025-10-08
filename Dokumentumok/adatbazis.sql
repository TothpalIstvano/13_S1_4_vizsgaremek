CREATE TABLE felhasznalo(
    id INT PRIMARY KEY AUTO_INCREMENT,
    felhasz_nev VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    jelszo VARCHAR(255) NOT NULL,
    profilkep VARCHAR(255),
    statusz BOOLEAN DEFAULT TRUE,
    letrehozas_datuma TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)

CREATE TABLE kepek (
    id INT AUTO_INCREMENT PRIMARY KEY,
    url_link VARCHAR(255) NOT NULL UNIQUE, -- e.g., '/uploads/posts/summer-vibes.jpg'
    alt_szoveg VARCHAR(255), -- Important for SEO and accessibility
    leiras VARCHAR(255),  -- Optional caption to display with the image
);

CREATE TABLE posztok(
    id INT PRIMARY KEY AUTO_INCREMENT,
    cim VARCHAR(255) NOT NULL,
    kivonat VARCHAR(255) NOT NULL UNIQUE,
    tartalom TEXT NOT NULL,
    szerzo_id INT,
    fo_kep_id INT NOT NULL, -- a kepek táblából
    letrehozas_datuma TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    statusz ENUM('piszkozat', 'közzétett', 'archivált') DEFAULT 'piszkozat',
    FOREIGN KEY (szerzo_id) REFERENCES felhasznalo(id) ON DELETE CASCADE,
    FOREIGN KEY (fo_kep_id) REFERENCES kepek(id) ON DELETE SET NULL
)

CREATE TABLE poszt_kepek (
    poszt_id INT NOT NULL,
    kep_id INT NOT NULL,
    sorrend INT DEFAULT 0, -- Allows you to control the order of images in a gallery
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
    FOREIGN KEY (poszt_id) REFERENCES posztok(id) ON DELETE CASCADE,
    FOREIGN KEY (kommentelo) REFERENCES felhasznalo(id) ON DELETE CASCADE,
    FOREIGN KEY (elozo_komment_id) REFERENCES kommentek(id) ON DELETE CASCADE
)

CREATE TABLE poszt_reakciok(
    id INT PRIMARY KEY AUTO_INCREMENT,
    poszt_id INT,
    felhasznalo_id INT,
    reakcio ENUM('tetszik', 'nem tetszik'),
    FOREIGN KEY (poszt_id) REFERENCES posztok(id),
    FOREIGN KEY (felhasznalo_id) REFERENCES felhasznalo(id),
    UNIQUE KEY unique_reakcio (poszt_id, felhasznalo_id) -- Egy felhasználó csak egyszer reagálhat egy posztokposztra (kihagyható szerintem)
)

CREATE TABLE kategoriak (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nev VARCHAR(100) NOT NULL,
    fo_kategoria_id INT NULL,
    FOREIGN KEY (fo_kategoria_id) REFERENCES kategoriak(id) ON DELETE SET NULL
);

CREATE TABLE termekek (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nev VARCHAR(255) NOT NULL,
    leiras TEXT,
    ar DECIMAL(10, 2) NOT NULL,
    darab INT NOT NULL DEFAULT 0,
    kategoria_id INT,
    fo_kep_id INT NULL, -- Points to the main product image
    FOREIGN KEY (kategoria_id) REFERENCES kategoriak(id) ON DELETE SET NULL,
    FOREIGN KEY (fo_kep_id) REFERENCES kepek(id) ON DELETE SET NULL
);

CREATE TABLE termek_kepek (
    termek_id INT NOT NULL,
    kep_id INT NOT NULL,
    sort_order INT DEFAULT 0, -- Controls the order of images in the product gallery
    PRIMARY KEY (termek_id, image_id),
    FOREIGN KEY (termek_id) REFERENCES termekek(id) ON DELETE CASCADE,
    FOREIGN KEY (kep_id) REFERENCES kepek(id) ON DELETE CASCADE
);

CREATE TABLE termekek_cimkek(
    termek_id INT,
    cimke_id INT,
    PRIMARY KEY (termek_id, cimke_id),
    FOREIGN KEY (termek_id) REFERENCES termekek(id) ON DELETE CASCADE,
    FOREIGN KEY (cimke_id) REFERENCES cimkek(id) ON DELETE CASCADE
)

CREATE TABLE szinek (
    id INT PRIMARY KEY AUTO_INCREMENT,
    szin_nev VARCHAR(50) NOT NULL UNIQUE,
    hex_kod VARCHAR(7) NOT NULL UNIQUE
);

CREATE TABLE termek_szinek(
    termek_id INT NOT NULL,
    szin_id INT NOT NULL,
    PRIMARY KEY (termek_id, szin_id),
    FOREIGN KEY (termek_id) REFERENCES termekek(id),
    FOREIGN KEY (szin_id) REFERENCES szinek(id)
)

CREATE TABLE kedvencek(
    felhasznalo_id INT,
    termek_id INT,
    PRIMARY KEY (felhasznalo_id, termek_id),
    FOREIGN KEY (felhasznalo_id) REFERENCES felhasznalo(id),
    FOREIGN KEY (termek_id) REFERENCES termekek(id),
)

CREATE TABLE cimkek(
    id INT AUTO_INCREMENT PRIMARY KEY,
    nev VARCHAR(50) NOT NULL UNIQUE
)