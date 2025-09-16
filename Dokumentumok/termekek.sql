CREATE TABLE termekek{
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
}

INSERT INTO termekek VALUES ('cimke_id', 'nev', 'leiras', 'ar', 'mennyiseg', 'kepek', 'megjelenito_kep', 'merominta') {
    ('F', 'Fonal (A csoport)', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse cursus mi diam, quis feugiat diam aliquam nec. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Quisque lobortis lorem eget quam tristique, eleifend tempor elit lobortis. Suspendisse vel porta arcu. In hac habitasse platea dictumst. In iaculis enim rutrum, ultrices diam non, interdum erat. Mauris tincidunt rhoncus augue, vitae mollis dui gravida eget. Ut at quam molestie, efficitur purus ut, porta lectus. Vivamus non enim elit. In pretium eget mauris id tincidunt. Sed lobortis erat tincidunt luctus consectetur.', 1000, 100, 'elérési/út', 'elérési/út', '27×35'),
    ('F', 'Fonal (B csoport)', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse cursus mi diam, quis feugiat diam aliquam nec. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Quisque lobortis lorem eget quam tristique, eleifend tempor elit lobortis.', 1200, 80, 'elérési/út', 'elérési/út', '20×30'),
    ('F', 'Fonal (C csoport)', 'Donec rutrum efficitur interdum. Sed suscipit mollis neque. Nam vestibulum sit amet lacus eget semper. Ut convallis mattis massa in dictum. Mauris placerat, odio feugiat rutrum tincidunt, ante lectus efficitur nisl, at sagittis felis nisi vel dui. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Nullam eu erat a lectus posuere tincidunt. Etiam sem urna, hendrerit at sapien rhoncus, elementum mattis metus. Donec porttitor ligula lorem, a fringilla dui gravida ut.', 1300, 78, 'elérési/út', 'elérési/út', '16×24'),
    ('F', 'Fonal (D csoport)', 'Donec rutrum efficitur interdum. Sed suscipit mollis neque. Nam vestibulum sit amet lacus eget semper. Ut convallis mattis massa in dictum. Mauris placerat, odio feugiat rutrum tincidunt, ante lectus efficitur nisl, at sagittis felis nisi vel dui. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.', 1500, 45, 'elérési/út', 'elérési/út', '10×15'),
    ('B', 'Kalapács', 'Donec rutrum efficitur interdum. Sed suscipit mollis neque. Nam vestibulum sit amet lacus eget semper. Ut convallis mattis massa in dictum. Mauris placerat, odio feugiat rutrum tincidunt, ante lectus efficitur nisl, at sagittis felis nisi vel dui. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.', 2000, 30,'elérési/út', 'elérési/út'),
    ('B', 'Fűrész', 'Donec rutrum efficitur interdum. Sed suscipit mollis neque. Nam vestibulum sit amet lacus eget semper. Ut convallis mattis massa in dictum. Mauris placerat, odio feugiat rutrum tincidunt, ante lectus efficitur nisl, at sagittis felis nisi vel dui.', 4580, 24, 'elérési/út', 'elérési/út'),
}