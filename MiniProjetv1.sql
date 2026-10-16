-- ============================================================
-- CAREFREI - Base de donnees technique et industrielle
-- Script SQL genere a partir du MCD fourni (syntaxe MySQL / MariaDB)
--
-- Regles de passage MCD -> tables appliquees :
--  * chaque entite devient une table (son identifiant = cle primaire)
--  * association avec une patte (1,1) : cle etrangere dans l'entite cote (1,1)
--  * association (x,n)-(x,n) : table avec les deux cles etrangeres
--  * identifiant relatif (1,1)(R) : la cle de l'entite parente entre dans la
--    cle primaire de l'entite dependante
-- Note : la table OPTION du MCD s'appelle OPTIONS ici, car OPTION est un
-- mot reserve en MySQL.
-- ============================================================

-- ---------- Base de donnees ----------

DROP DATABASE IF EXISTS CAREFREI;

CREATE DATABASE IF NOT EXISTS CAREFREI
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_general_ci;

USE CAREFREI;

-- ---------- Entites ----------

CREATE TABLE MODELE (
    code_modele         VARCHAR(6)  NOT NULL,
    nom_modele          VARCHAR(30) NOT NULL,
    nb_places           INT         NOT NULL,
    nb_portes           INT         NOT NULL,
    longueur            INT         NOT NULL,
    empattement         INT         NOT NULL,
    date_lancement      DATE        NOT NULL,
    PRIMARY KEY (code_modele)
);

-- Association AVOIR : la patte (1,1) est cote CARROSSERIE,
-- la cle etrangere vers MODELE est donc dans CARROSSERIE.
CREATE TABLE CARROSSERIE (
    type_carrosserie    VARCHAR(20) NOT NULL,
    code_modele         VARCHAR(6)  NOT NULL,
    PRIMARY KEY (type_carrosserie),
    FOREIGN KEY (code_modele) REFERENCES MODELE (code_modele)
);

CREATE TABLE CYLINDRE (
    type_cylindre       VARCHAR(20) NOT NULL,
    PRIMARY KEY (type_cylindre)
);

CREATE TABLE ENERGIE (
    energie_moteur      VARCHAR(15) NOT NULL,
    PRIMARY KEY (energie_moteur)
);

-- Association PROPOSE : MOTEUR est en (1,1)(R), son identifiant est relatif
-- a MODELE (cle primaire composee). Association CONTIENT : (1,1) cote MOTEUR,
-- donc cle etrangere vers CYLINDRE dans MOTEUR.
CREATE TABLE MOTEUR (
    code_modele         VARCHAR(6)  NOT NULL,
    code_moteur         VARCHAR(8)  NOT NULL,
    nom_moteur          VARCHAR(30) NOT NULL,
    puissance           INT         NOT NULL,
    type_cylindre       VARCHAR(20) NOT NULL,
    PRIMARY KEY (code_modele, code_moteur),
    FOREIGN KEY (code_modele)   REFERENCES MODELE (code_modele),
    FOREIGN KEY (type_cylindre) REFERENCES CYLINDRE (type_cylindre)
);

-- Association APPARTIENT : la patte (1,1) est cote VOITURE,
-- la cle etrangere (composee) vers MOTEUR est dans VOITURE.
CREATE TABLE VOITURE (
    vin                 CHAR(17)    NOT NULL,
    date_fabrication    DATE        NOT NULL,
    code_modele         VARCHAR(6)  NOT NULL,
    code_moteur         VARCHAR(8)  NOT NULL,
    PRIMARY KEY (vin),
    FOREIGN KEY (code_modele, code_moteur)
        REFERENCES MOTEUR (code_modele, code_moteur)
);

CREATE TABLE PIECE (
    ref_piece           VARCHAR(15) NOT NULL,
    designation         VARCHAR(60) NOT NULL,
    poids_piece         INT         NOT NULL,
    PRIMARY KEY (ref_piece)
);

CREATE TABLE FOURNISSEUR (
    siret               CHAR(14)    NOT NULL,
    raison_sociale      VARCHAR(50) NOT NULL,
    pays                VARCHAR(30) NOT NULL,
    PRIMARY KEY (siret)
);

CREATE TABLE OPTIONS (
    code_option         VARCHAR(8)  NOT NULL,
    libelle_option      VARCHAR(60) NOT NULL,
    type_option         VARCHAR(20) NOT NULL,
    PRIMARY KEY (code_option)
);

-- ---------- Tables issues des associations ----------

-- DISPONIBLE : MODELE (0,n) - OPTION (0,n)
CREATE TABLE DISPONIBLE (
    code_modele         VARCHAR(6)  NOT NULL,
    code_option         VARCHAR(8)  NOT NULL,
    PRIMARY KEY (code_modele, code_option),
    FOREIGN KEY (code_modele) REFERENCES MODELE (code_modele),
    FOREIGN KEY (code_option) REFERENCES OPTIONS (code_option)
);

-- NECESSITE : OPTION (1,n) - PIECE (0,n)
CREATE TABLE NECESSITE (
    code_option         VARCHAR(8)  NOT NULL,
    ref_piece           VARCHAR(15) NOT NULL,
    PRIMARY KEY (code_option, ref_piece),
    FOREIGN KEY (code_option) REFERENCES OPTIONS (code_option),
    FOREIGN KEY (ref_piece)   REFERENCES PIECE (ref_piece)
);

-- COMPOSE : PIECE (0,n) - MOTEUR (0,n)
CREATE TABLE COMPOSE (
    code_modele         VARCHAR(6)  NOT NULL,
    code_moteur         VARCHAR(8)  NOT NULL,
    ref_piece           VARCHAR(15) NOT NULL,
    PRIMARY KEY (code_modele, code_moteur, ref_piece),
    FOREIGN KEY (code_modele, code_moteur)
        REFERENCES MOTEUR (code_modele, code_moteur),
    FOREIGN KEY (ref_piece) REFERENCES PIECE (ref_piece)
);

-- FONCTIONNE : MOTEUR (0,n) - ENERGIE (0,n)
CREATE TABLE FONCTIONNE (
    code_modele         VARCHAR(6)  NOT NULL,
    code_moteur         VARCHAR(8)  NOT NULL,
    energie_moteur      VARCHAR(15) NOT NULL,
    PRIMARY KEY (code_modele, code_moteur, energie_moteur),
    FOREIGN KEY (code_modele, code_moteur)
        REFERENCES MOTEUR (code_modele, code_moteur),
    FOREIGN KEY (energie_moteur) REFERENCES ENERGIE (energie_moteur)
);

-- LIVRE : PIECE (1,n) - FOURNISSEUR (1,n)
CREATE TABLE LIVRE (
    siret               CHAR(14)    NOT NULL,
    ref_piece           VARCHAR(15) NOT NULL,
    PRIMARY KEY (siret, ref_piece),
    FOREIGN KEY (siret)     REFERENCES FOURNISSEUR (siret),
    FOREIGN KEY (ref_piece) REFERENCES PIECE (ref_piece)
);


-- ============================================================
-- JEU D'ESSAI (donnees fictives)
-- Ordre d'insertion : parents avant enfants
-- ============================================================

INSERT INTO MODELE (code_modele, nom_modele, nb_places, nb_portes, longueur, empattement, date_lancement) VALUES
    ('CF1001', 'Aria',  4, 5, 3990, 2540, '2022-03-15'),
    ('CF2001', 'Borea', 5, 5, 4650, 2790, '2021-09-01'),
    ('CF3001', 'Cyrus', 5, 5, 4420, 2680, '2023-05-10'),
    ('CF4001', 'Dolce', 5, 5, 4780, 2820, '2020-11-20');

-- Chaque type de carrosserie est rattache a un seul modele (cf. AVOIR dans le MCD)
INSERT INTO CARROSSERIE (type_carrosserie, code_modele) VALUES
    ('Citadine', 'CF1001'),
    ('Berline',  'CF2001'),
    ('SUV',      'CF3001'),
    ('Break',    'CF4001');

INSERT INTO CYLINDRE (type_cylindre) VALUES
    ('Aucun'), ('3 cylindres'), ('4 cylindres');

INSERT INTO ENERGIE (energie_moteur) VALUES
    ('essence'), ('diesel'), ('hybride'), ('electrique');

-- Un moteur est identifie par (modele, code moteur) : le meme code peut
-- apparaitre sur plusieurs modeles, mais ce sont des lignes distinctes.
INSERT INTO MOTEUR (code_modele, code_moteur, nom_moteur, puissance, type_cylindre) VALUES
    ('CF1001', 'E-ES10', '1.0 essence 75',    55, '3 cylindres'),
    ('CF1001', 'E-ES12', '1.2 essence 100',   74, '3 cylindres'),
    ('CF1001', 'E-EL01', 'Electrique 100 kW', 100, 'Aucun'),
    ('CF2001', 'E-ES15', '1.5 essence 130',   96, '4 cylindres'),
    ('CF2001', 'E-DI15', '1.5 diesel 115',    85, '4 cylindres'),
    ('CF2001', 'E-HY15', '1.5 hybride 136',  100, '4 cylindres'),
    ('CF3001', 'E-ES12', '1.2 essence 100',   74, '3 cylindres'),
    ('CF3001', 'E-DI15', '1.5 diesel 115',    85, '4 cylindres'),
    ('CF3001', 'E-EL01', 'Electrique 100 kW', 100, 'Aucun'),
    ('CF4001', 'E-DI15', '1.5 diesel 115',    85, '4 cylindres'),
    ('CF4001', 'E-DI20', '2.0 diesel 150',   110, '4 cylindres'),
    ('CF4001', 'E-HY15', '1.5 hybride 136',  100, '4 cylindres');

INSERT INTO VOITURE (vin, date_fabrication, code_modele, code_moteur) VALUES
    ('VFCF1001A00000001', '2024-04-12', 'CF1001', 'E-ES12'),
    ('VFCF1001A00000002', '2024-06-03', 'CF1001', 'E-EL01'),
    ('VFCF2001B00000001', '2023-02-20', 'CF2001', 'E-DI15'),
    ('VFCF2001B00000002', '2023-09-14', 'CF2001', 'E-HY15'),
    ('VFCF3001C00000001', '2024-07-01', 'CF3001', 'E-ES12'),
    ('VFCF3001C00000002', '2024-09-18', 'CF3001', 'E-EL01'),
    ('VFCF3001C00000003', '2025-01-27', 'CF3001', 'E-DI15'),
    ('VFCF4001D00000001', '2022-05-09', 'CF4001', 'E-DI20');

INSERT INTO PIECE (ref_piece, designation, poids_piece) VALUES
    ('P-BOUGIE',   'Bougie d allumage',              45),
    ('P-SOUPAPE',  'Soupape',                        60),
    ('P-PISTON',   'Piston',                        350),
    ('P-INJECT',   'Injecteur',                     120),
    ('P-TURBO',    'Turbocompresseur',             5200),
    ('P-FILTRE',   'Filtre a particules',          3800),
    ('P-MELEC',    'Moteur electrique',           85000),
    ('P-BATT',     'Batterie haute tension',     280000),
    ('P-SUPBAT',   'Support de batterie renforce',  6500),
    ('P-RESERV',   'Reservoir 45 L',                9500),
    ('P-JANTE19',  'Jante alliage 19 pouces',       9800),
    ('P-TOITOUV',  'Mecanisme de toit ouvrant',    14000),
    ('P-TOITPAN',  'Panneau de toit panoramique',  22000),
    ('P-RADAR',    'Radar avant',                    350),
    ('P-CAMERA',   'Camera de recul',                150),
    ('P-ECRAN',    'Ecran tactile 10 pouces',        900),
    ('P-HP',       'Haut-parleur premium',           600),
    ('P-SIEGCH',   'Resistance de siege chauffant',  120),
    ('P-ATTELAGE', 'Rotule d attelage',             4500);

INSERT INTO FOURNISSEUR (siret, raison_sociale, pays) VALUES
    ('73210548600011', 'MotoDrive SA',         'France'),
    ('48911237400029', 'Kolben GmbH',          'Allemagne'),
    ('35248896100037', 'Iberpiezas SL',        'Espagne'),
    ('81250364900018', 'Electropower SAS',     'France'),
    ('52764019300046', 'Carrosserie Lorraine', 'France');

INSERT INTO OPTIONS (code_option, libelle_option, type_option) VALUES
    ('O-TOITO',  'Toit ouvrant electrique',         'confort'),
    ('O-TOITP',  'Toit panoramique',                'esthetique'),
    ('O-JANT19', 'Jantes alliage 19 pouces',        'esthetique'),
    ('O-RADAR',  'Regulateur de vitesse adaptatif', 'securite'),
    ('O-CAMER',  'Camera de recul',                 'securite'),
    ('O-AUDIO',  'Systeme audio premium',           'multimedia'),
    ('O-ECRAN',  'Ecran tactile 10 pouces',         'multimedia'),
    ('O-SIEGCH', 'Sieges chauffants',               'confort'),
    ('O-ATTEL',  'Attelage amovible',               'confort');

INSERT INTO DISPONIBLE (code_modele, code_option) VALUES
    ('CF1001', 'O-JANT19'), ('CF1001', 'O-CAMER'), ('CF1001', 'O-ECRAN'), ('CF1001', 'O-SIEGCH'),
    ('CF2001', 'O-TOITO'),  ('CF2001', 'O-JANT19'), ('CF2001', 'O-RADAR'), ('CF2001', 'O-CAMER'),
    ('CF2001', 'O-AUDIO'),  ('CF2001', 'O-ECRAN'),  ('CF2001', 'O-SIEGCH'),
    ('CF3001', 'O-TOITO'),  ('CF3001', 'O-TOITP'),  ('CF3001', 'O-JANT19'), ('CF3001', 'O-RADAR'),
    ('CF3001', 'O-CAMER'),  ('CF3001', 'O-AUDIO'),  ('CF3001', 'O-ECRAN'),  ('CF3001', 'O-SIEGCH'), ('CF3001', 'O-ATTEL'),
    ('CF4001', 'O-TOITO'),  ('CF4001', 'O-JANT19'), ('CF4001', 'O-RADAR'),  ('CF4001', 'O-CAMER'),
    ('CF4001', 'O-AUDIO'),  ('CF4001', 'O-ECRAN'),  ('CF4001', 'O-SIEGCH'), ('CF4001', 'O-ATTEL');

INSERT INTO NECESSITE (code_option, ref_piece) VALUES
    ('O-TOITO',  'P-TOITOUV'),
    ('O-TOITP',  'P-TOITPAN'),
    ('O-JANT19', 'P-JANTE19'),
    ('O-RADAR',  'P-RADAR'),
    ('O-CAMER',  'P-CAMERA'),
    ('O-AUDIO',  'P-HP'),
    ('O-ECRAN',  'P-ECRAN'),
    ('O-SIEGCH', 'P-SIEGCH'),
    ('O-ATTEL',  'P-ATTELAGE');

-- Pieces de chaque moteur : la liste (code moteur, piece) est appliquee a
-- toutes les lignes MOTEUR portant ce code, quel que soit le modele.
INSERT INTO COMPOSE (code_modele, code_moteur, ref_piece)
SELECT m.code_modele, m.code_moteur, p.ref_piece
FROM MOTEUR m
JOIN (
    SELECT 'E-ES10' AS code_moteur, 'P-BOUGIE'  AS ref_piece UNION ALL
    SELECT 'E-ES10', 'P-SOUPAPE' UNION ALL
    SELECT 'E-ES10', 'P-PISTON'  UNION ALL
    SELECT 'E-ES10', 'P-INJECT'  UNION ALL
    SELECT 'E-ES12', 'P-BOUGIE'  UNION ALL
    SELECT 'E-ES12', 'P-SOUPAPE' UNION ALL
    SELECT 'E-ES12', 'P-PISTON'  UNION ALL
    SELECT 'E-ES12', 'P-INJECT'  UNION ALL
    SELECT 'E-ES12', 'P-TURBO'   UNION ALL
    SELECT 'E-ES15', 'P-BOUGIE'  UNION ALL
    SELECT 'E-ES15', 'P-SOUPAPE' UNION ALL
    SELECT 'E-ES15', 'P-PISTON'  UNION ALL
    SELECT 'E-ES15', 'P-INJECT'  UNION ALL
    SELECT 'E-ES15', 'P-TURBO'   UNION ALL
    SELECT 'E-DI15', 'P-SOUPAPE' UNION ALL
    SELECT 'E-DI15', 'P-PISTON'  UNION ALL
    SELECT 'E-DI15', 'P-INJECT'  UNION ALL
    SELECT 'E-DI15', 'P-TURBO'   UNION ALL
    SELECT 'E-DI15', 'P-FILTRE'  UNION ALL
    SELECT 'E-DI20', 'P-SOUPAPE' UNION ALL
    SELECT 'E-DI20', 'P-PISTON'  UNION ALL
    SELECT 'E-DI20', 'P-INJECT'  UNION ALL
    SELECT 'E-DI20', 'P-TURBO'   UNION ALL
    SELECT 'E-DI20', 'P-FILTRE'  UNION ALL
    SELECT 'E-HY15', 'P-BOUGIE'  UNION ALL
    SELECT 'E-HY15', 'P-SOUPAPE' UNION ALL
    SELECT 'E-HY15', 'P-PISTON'  UNION ALL
    SELECT 'E-HY15', 'P-INJECT'  UNION ALL
    SELECT 'E-HY15', 'P-MELEC'   UNION ALL
    SELECT 'E-EL01', 'P-MELEC'
) p ON p.code_moteur = m.code_moteur;

-- Un moteur hybride fonctionne avec deux energies (MOTEUR 0,n - ENERGIE 0,n)
INSERT INTO FONCTIONNE (code_modele, code_moteur, energie_moteur) VALUES
    ('CF1001', 'E-ES10', 'essence'),
    ('CF1001', 'E-ES12', 'essence'),
    ('CF1001', 'E-EL01', 'electrique'),
    ('CF2001', 'E-ES15', 'essence'),
    ('CF2001', 'E-DI15', 'diesel'),
    ('CF2001', 'E-HY15', 'essence'),
    ('CF2001', 'E-HY15', 'electrique'),
    ('CF3001', 'E-ES12', 'essence'),
    ('CF3001', 'E-DI15', 'diesel'),
    ('CF3001', 'E-EL01', 'electrique'),
    ('CF4001', 'E-DI15', 'diesel'),
    ('CF4001', 'E-DI20', 'diesel'),
    ('CF4001', 'E-HY15', 'essence'),
    ('CF4001', 'E-HY15', 'electrique');

INSERT INTO LIVRE (siret, ref_piece) VALUES
    ('73210548600011', 'P-BOUGIE'),
    ('73210548600011', 'P-SOUPAPE'),
    ('73210548600011', 'P-PISTON'),
    ('73210548600011', 'P-INJECT'),
    ('73210548600011', 'P-FILTRE'),
    ('48911237400029', 'P-SOUPAPE'),
    ('48911237400029', 'P-PISTON'),
    ('48911237400029', 'P-INJECT'),
    ('48911237400029', 'P-TURBO'),
    ('35248896100037', 'P-RESERV'),
    ('35248896100037', 'P-ATTELAGE'),
    ('81250364900018', 'P-BATT'),
    ('81250364900018', 'P-MELEC'),
    ('81250364900018', 'P-SUPBAT'),
    ('81250364900018', 'P-ECRAN'),
    ('81250364900018', 'P-HP'),
    ('81250364900018', 'P-RADAR'),
    ('81250364900018', 'P-CAMERA'),
    ('81250364900018', 'P-SIEGCH'),
    ('52764019300046', 'P-RESERV'),
    ('52764019300046', 'P-JANTE19'),
    ('52764019300046', 'P-TOITOUV'),
    ('52764019300046', 'P-TOITPAN'),
    ('52764019300046', 'P-ATTELAGE');


-- ============================================================
-- AFFICHAGE DES DONNEES
-- ============================================================

SELECT * FROM MODELE;
SELECT * FROM CARROSSERIE;
SELECT * FROM CYLINDRE;
SELECT * FROM ENERGIE;
SELECT * FROM MOTEUR;
SELECT * FROM VOITURE;
SELECT * FROM PIECE;
SELECT * FROM FOURNISSEUR;
SELECT * FROM OPTIONS;
SELECT * FROM DISPONIBLE;
SELECT * FROM NECESSITE;
SELECT * FROM COMPOSE;
SELECT * FROM FONCTIONNE;
SELECT * FROM LIVRE;