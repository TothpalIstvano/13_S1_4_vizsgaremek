CREATE TABLE termekek(
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
)

INSERT INTO termekek VALUES ('nev', 'leiras', 'ar', 'mennyiseg', 'kepek', 'megjelenito_kep', 'merominta') (
    ('Fonal (A csoport)', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.', 1000, 100, 'elérési/út', 'elérési/út', '27×35'),
    ('Fonal (B csoport)', 'Lorem ipsum dolor', 1200, 80, 'elérési/út', 'elérési/út', '20×30'),
    ('Fonal (C csoport)', 'Donec rutrum efficitur interdum. ', 1300, 78, 'elérési/út', 'elérési/út', '16×24'),
    ('Fonal (D csoport)', 'Donec rutrum efficitur interdum. Sed suscipit mollis neque.', 1500, 45, 'elérési/út', 'elérési/út', '10×15'),
    ('Kalapács', 'Donec rutrum efficitur interdum. ', 2000, 30,'elérési/út', 'elérési/út'),
    ('Fűrész', 'Donec rutrum efficitur interdum. ', 4580, 24, 'elérési/út', 'elérési/út'),
)

CREATE TABLE szinek (
    id INT PRIMARY KEY AUTO_INCREMENT,
    szin_nev VARCHAR(50) NOT NULL UNIQUE,
    hex_kod VARCHAR(7)
)

INSERT INTO szinek VALUES ('szin_nev', 'hex_kod') (
    ('Piros', '#FF0000'),
    ('Kék', '#0000FF'),
    ('Zöld', '#00FF00')
)

CREATE TABLE termekek_szinek(
    id INT PRIMARY KEY AUTO_INCREMENT,
    termek_id INT,
    szin VARCHAR(50),
    FOREIGN KEY (termek_id) REFERENCES termekek(id),
    FOREIGN KEY (szin_id) REFERENCES szinek(id)
)

INSERT INTO termekek_szinek VALUES ('termek_id', 'szin') (
    (1, 1),
    (1, 2),
    (1, 3),
    (2, 2),
    (2, 3),
    (3, 1),
    (4, 2)
)

CREATE TABLE cimkek(
    id INT PRIMARY KEY AUTO_INCREMENT,
    nev VARCHAR(100) NOT NULL UNIQUE,
)

INSERT INTO cimkek VALUES ('nev') (
    ('fonal'),
    ('szerszám'),
    ('kiegészítő')
)

CREATE TABLE termekek_cimkek(
    id INT PRIMARY KEY AUTO_INCREMENT,
    termek_id INT,
    cimke_id INT,
    FOREIGN KEY (termek_id) REFERENCES termekek(id),
    FOREIGN KEY (cimke_id) REFERENCES cimkek(id)
)

INSERT INTO termekek_cimkek VALUES ('termek_id', 'cimke_id') (
    (1, 1),
    (2, 1),
    (3, 1),
    (4, 1),
    (5, 2),
    (6, 2)
)