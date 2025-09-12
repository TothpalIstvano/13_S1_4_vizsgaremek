CREATE TABLE felhasznalo{
    id INT PRIMARY KEY AUTO_INCREMENT,
    felhasz_nev VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    jelszo VARCHAR(255) NOT NULL,
    szul_datum DATE,
    profilkep VARCHAR(255),
    statusz ENUM('aktiv', 'inaktiv', 'admin') DEFAULT 'aktiv',
    letrehozas_datuma TIMESTAMP DEFAULT CURRENT_TIMESTAMP
}

/*CREATE TABLE termekek{
    id INT PRIMARY KEY AUTO_INCREMENT,
    cimke_id VARCHAR(3),
    nev VARCHAR(100) NOT NULL,
    leiras TEXT,
    ar DECIMAL(10, 2) NOT NULL,
    keszlet ENUM('elerheto', 'nem elerheto') DEFAULT 'elerheto',
    mennyiseg INT,
    kepek VARCHAR(255),
    megjelenito_kep VARCHAR(255),
    merominta VARCHAR(50)
}*/

CREATE TABLE termekek_szinek{
    id INT PRIMARY KEY AUTO_INCREMENT,
    termek_id INT,
    szin VARCHAR(50),
    FOREIGN KEY (termek_id) REFERENCES termekek(id)
}

CREATE TABLE blog{
    id INT PRIMARY KEY AUTO_INCREMENT,
    cim VARCHAR(200) NOT NULL,
    tartalom TEXT NOT NULL,
    szerzo_id INT,
    letrehozas_datuma TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    kep VARCHAR(255),
    FOREIGN KEY (szerzo_id) REFERENCES felhasznalo(id)
}

CREATE TABLE kommentek{
    id INT PRIMARY KEY AUTO_INCREMENT,
    poszt_id INT,
    kommentelo INT,
    komment TEXT NOT NULL,
    letrehozas_datuma TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    elozo_komment_id INT,
    FOREIGN KEY (poszt_id) REFERENCES blog(id),
    FOREIGN KEY (kommentelo) REFERENCES felhasznalo(id),
    FOREIGN KEY (elozo_komment_id) REFERENCES kommentek(id)
}

CREATE TABLE cimkek{
    id INT PRIMARY KEY AUTO_INCREMENT,
    nev VARCHAR(100) NOT NULL UNIQUE,
}

CREATE TABLE termekek_cimkek{
    id INT PRIMARY KEY AUTO_INCREMENT,
    termekek_id INT,
    cimke_id INT,
    FOREIGN KEY (termekek_id) REFERENCES termekek(cimke_id),
    FOREIGN KEY (cimke_id) REFERENCES cimkek(id)
}

CREATE TABLE blog_cimkek{
    id INT PRIMARY KEY AUTO_INCREMENT,
    blog_id INT,
    cimke_id INT,
    FOREIGN KEY (blog_id) REFERENCES blog(id),
    FOREIGN KEY (cimke_id) REFERENCES cimkek(id)
}

CREATE TABLE blog_reakciok{
    id INT PRIMARY KEY AUTO_INCREMENT,
    blog_id INT,
    felhasznalo_id INT,
    reakcio ENUM('tetszik', 'nem tetszik'),
    FOREIGN KEY (blog_id) REFERENCES blog(id),
    FOREIGN KEY (felhasznalo_id) REFERENCES felhasznalo(id),
    UNIQUE KEY unique_reaction (blog_id, felhasznalo_id) -- Egy felhasználó csak egyszer reagálhat egy blogposztra (kihagyható szerintem)
}

CREATE TABLE kedvencek{
    id INT PRIMARY KEY AUTO_INCREMENT,
    felhasznalo_id INT,
    termek_id INT,
    FOREIGN KEY (felhasznalo_id) REFERENCES felhasznalo(id),
    FOREIGN KEY (termek_id) REFERENCES termekek(id),
    UNIQUE KEY unique_favorite (felhasznalo_id, termek_id) -- Egy felhasználó csak egyszer jelölheti meg kedvencként ugyanazt a terméket
}

CREATE TABLE ertekeles{
    id INT PRIMARY KEY AUTO_INCREMENT,
    felhasznalo_id INT,
    termek_id INT,
    ertekeles INT CHECK (ertekeles BETWEEN 1 AND 5),
    datum TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (felhasznalo_id) REFERENCES felhasznalo(id),
    FOREIGN KEY (termek_id) REFERENCES termekek(id),
    UNIQUE KEY unique_rating (felhasznalo_id, termek_id) -- Egy felhasználó csak egyszer értékelhet egy terméket
}