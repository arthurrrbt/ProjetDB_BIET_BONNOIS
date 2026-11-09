-- ============================================================
-- CAREFREI - Mini Projet 2
-- ============================================================

DROP DATABASE IF EXISTS CAREFREI;
CREATE DATABASE CAREFREI;
USE CAREFREI;


-- ---------- 1) Tables sans cle etrangere ----------

CREATE TABLE MODELE (
    code_modele     VARCHAR(6)  NOT NULL,
    nom_modele      VARCHAR(30) NOT NULL,
    nb_places       INT         NOT NULL,
    nb_portes       INT         NOT NULL,
    longueur        INT         NOT NULL,   -- en mm
    empattement     INT         NOT NULL,   -- en mm
    date_lancement  DATE        NOT NULL,
    PRIMARY KEY (code_modele)
);

CREATE TABLE CYLINDRE (
    type_cylindre   VARCHAR(20) NOT NULL,
    PRIMARY KEY (type_cylindre)
);

CREATE TABLE ENERGIE (
    energie_moteur  VARCHAR(15) NOT NULL,
    PRIMARY KEY (energie_moteur)
);

CREATE TABLE PIECE (
    ref_piece       VARCHAR(15) NOT NULL,
    designation     VARCHAR(60) NOT NULL,
    poids_piece     INT         NOT NULL,   -- en grammes
    PRIMARY KEY (ref_piece)
);

CREATE TABLE FOURNISSEUR (
    siret           CHAR(14)    NOT NULL,
    raison_sociale  VARCHAR(50) NOT NULL,
    pays            VARCHAR(30) NOT NULL,
    PRIMARY KEY (siret)
);

CREATE TABLE OPTIONS (
    code_option     VARCHAR(8)  NOT NULL,
    libelle_option  VARCHAR(60) NOT NULL,
    type_option     VARCHAR(20) NOT NULL,
    PRIMARY KEY (code_option)
);


-- ---------- 2) Tables avec cle(s) etrangere(s) ----------

-- Association AVOIR : une carrosserie appartient a un modele
CREATE TABLE CARROSSERIE (
    type_carrosserie VARCHAR(20) NOT NULL,
    code_modele      VARCHAR(6)  NOT NULL,
    PRIMARY KEY (type_carrosserie),
    FOREIGN KEY (code_modele) REFERENCES MODELE (code_modele)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Association PROPOSE (identifiant relatif) : un moteur est identifie
-- par son modele + son code. Association CONTIENT : type de cylindre.
CREATE TABLE MOTEUR (
    code_modele     VARCHAR(6)  NOT NULL,
    code_moteur     VARCHAR(8)  NOT NULL,
    nom_moteur      VARCHAR(30) NOT NULL,
    puissance       INT         NOT NULL,   -- en kW
    type_cylindre   VARCHAR(20) NOT NULL,
    PRIMARY KEY (code_modele, code_moteur),
    FOREIGN KEY (code_modele) REFERENCES MODELE (code_modele)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (type_cylindre) REFERENCES CYLINDRE (type_cylindre)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Association APPARTIENT : une voiture a un seul moteur (d'un modele).
-- La cle etrangere composee garantit que le moteur est bien propose
-- pour ce modele.
CREATE TABLE VOITURE (
    vin              CHAR(17)   NOT NULL,
    date_fabrication DATE       NOT NULL,
    code_modele      VARCHAR(6) NOT NULL,
    code_moteur      VARCHAR(8) NOT NULL,
    PRIMARY KEY (vin),
    FOREIGN KEY (code_modele, code_moteur) REFERENCES MOTEUR (code_modele, code_moteur)
        ON DELETE CASCADE ON UPDATE CASCADE
);


-- ---------- 3) Tables issues des associations (n,n) ----------

-- DISPONIBLE : quelles options sont disponibles sur quel modele
CREATE TABLE DISPONIBLE (
    code_modele     VARCHAR(6) NOT NULL,
    code_option     VARCHAR(8) NOT NULL,
    PRIMARY KEY (code_modele, code_option),
    FOREIGN KEY (code_modele) REFERENCES MODELE (code_modele)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (code_option) REFERENCES OPTIONS (code_option)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- NECESSITE : pieces necessaires au montage d'une option
CREATE TABLE NECESSITE (
    code_option     VARCHAR(8)  NOT NULL,
    ref_piece       VARCHAR(15) NOT NULL,
    PRIMARY KEY (code_option, ref_piece),
    FOREIGN KEY (code_option) REFERENCES OPTIONS (code_option)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ref_piece) REFERENCES PIECE (ref_piece)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- COMPOSE : pieces qui composent un moteur
CREATE TABLE COMPOSE (
    code_modele     VARCHAR(6)  NOT NULL,
    code_moteur     VARCHAR(8)  NOT NULL,
    ref_piece       VARCHAR(15) NOT NULL,
    PRIMARY KEY (code_modele, code_moteur, ref_piece),
    FOREIGN KEY (code_modele, code_moteur) REFERENCES MOTEUR (code_modele, code_moteur)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ref_piece) REFERENCES PIECE (ref_piece)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- FONCTIONNE : energie(s) utilisee(s) par un moteur
CREATE TABLE FONCTIONNE (
    code_modele     VARCHAR(6)  NOT NULL,
    code_moteur     VARCHAR(8)  NOT NULL,
    energie_moteur  VARCHAR(15) NOT NULL,
    PRIMARY KEY (code_modele, code_moteur, energie_moteur),
    FOREIGN KEY (code_modele, code_moteur) REFERENCES MOTEUR (code_modele, code_moteur)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (energie_moteur) REFERENCES ENERGIE (energie_moteur)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- LIVRE : quel fournisseur livre quelle piece
CREATE TABLE LIVRE (
    siret           CHAR(14)    NOT NULL,
    ref_piece       VARCHAR(15) NOT NULL,
    PRIMARY KEY (siret, ref_piece),
    FOREIGN KEY (siret) REFERENCES FOURNISSEUR (siret)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ref_piece) REFERENCES PIECE (ref_piece)
        ON DELETE CASCADE ON UPDATE CASCADE
);
