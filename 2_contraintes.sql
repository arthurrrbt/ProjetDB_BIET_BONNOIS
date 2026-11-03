-- ============================================================
-- CAREFREI - Mini Projet 2
-- Fichier 2 : contraintes de validation (regles metier)
-- A executer APRES 1_creation.sql
--
-- Types de contraintes utilises (vus en cours) :
--   CHECK avec comparaison      ( > , < , <= ... )
--   CHECK avec BETWEEN          (intervalle de valeurs)
--   CHECK avec IN               (liste de valeurs autorisees)
--   CHECK avec LIKE / REGEXP    (format d'une donnee)
--   CHECK entre deux colonnes   (empattement < longueur)
--   UNIQUE                      (pas de doublon)
--   DEFAULT                     (valeur par defaut)
--
-- Remarque MySQL : on ne peut pas mettre de CHECK sur une colonne qui
-- sert de cle etrangere avec ON DELETE/UPDATE CASCADE. Les CHECK sont
-- donc poses dans la table "parente" (ex : le format du code modele
-- est verifie dans MODELE, pas dans VOITURE).
-- ============================================================

USE CAREFREI;


-- ---------- MODELE ----------

-- Le code modele commence par CF suivi de 4 caracteres (ex : CF1001)
ALTER TABLE MODELE
    ADD CONSTRAINT chk_modele_code CHECK (code_modele LIKE 'CF____');

-- Deux modeles ne peuvent pas avoir le meme nom commercial
ALTER TABLE MODELE
    ADD CONSTRAINT uq_modele_nom UNIQUE (nom_modele);

-- Une voiture a entre 2 et 9 places (dictionnaire : 1 chiffre)
ALTER TABLE MODELE
    ADD CONSTRAINT chk_modele_places CHECK (nb_places BETWEEN 2 AND 9);

-- Nombre de portes autorise
ALTER TABLE MODELE
    ADD CONSTRAINT chk_modele_portes CHECK (nb_portes IN (2, 3, 4, 5));

-- Longueur en mm (dictionnaire : 4 chiffres)
ALTER TABLE MODELE
    ADD CONSTRAINT chk_modele_longueur CHECK (longueur BETWEEN 2500 AND 6000);

-- L'empattement (distance entre les roues) est plus petit que la longueur
ALTER TABLE MODELE
    ADD CONSTRAINT chk_modele_empattement CHECK (empattement > 0 AND empattement < longueur);

-- Pas de modele lance avant 2000
ALTER TABLE MODELE
    ADD CONSTRAINT chk_modele_lancement CHECK (date_lancement >= '2000-01-01');


-- ---------- ENERGIE et CYLINDRE ----------

-- Les 4 energies de la regle de gestion
ALTER TABLE ENERGIE
    ADD CONSTRAINT chk_energie CHECK (energie_moteur IN ('essence', 'diesel', 'hybride', 'electrique'));

ALTER TABLE CYLINDRE
    ADD CONSTRAINT chk_cylindre CHECK (type_cylindre IN ('Aucun', '3 cylindres', '4 cylindres', '6 cylindres', '8 cylindres'));


-- ---------- MOTEUR ----------

-- Puissance en kW, strictement positive (dictionnaire : 3 chiffres)
ALTER TABLE MOTEUR
    ADD CONSTRAINT chk_moteur_puissance CHECK (puissance > 0 AND puissance <= 999);


-- ---------- VOITURE ----------

-- Un numero VIN fait exactement 17 caracteres
ALTER TABLE VOITURE
    ADD CONSTRAINT chk_voiture_vin CHECK (CHAR_LENGTH(vin) = 17);

-- Pas de date de fabrication avant 2015
ALTER TABLE VOITURE
    ADD CONSTRAINT chk_voiture_date CHECK (date_fabrication >= '2015-01-01');


-- ---------- PIECE ----------

-- La reference interne commence par P-
ALTER TABLE PIECE
    ADD CONSTRAINT chk_piece_ref CHECK (ref_piece LIKE 'P-%');

-- Poids en grammes, positif (dictionnaire : 6 chiffres max)
ALTER TABLE PIECE
    ADD CONSTRAINT chk_piece_poids CHECK (poids_piece BETWEEN 1 AND 999999);


-- ---------- FOURNISSEUR ----------

-- Le SIRET est compose de 14 chiffres exactement
ALTER TABLE FOURNISSEUR
    ADD CONSTRAINT chk_fournisseur_siret CHECK (siret REGEXP '^[0-9]{14}$');

-- Deux fournisseurs ne peuvent pas avoir la meme raison sociale
ALTER TABLE FOURNISSEUR
    ADD CONSTRAINT uq_fournisseur_nom UNIQUE (raison_sociale);

-- Si on ne precise pas le pays, c'est la France
ALTER TABLE FOURNISSEUR
    ALTER pays SET DEFAULT 'France';


-- ---------- OPTIONS ----------

-- Le code option commence par O-
ALTER TABLE OPTIONS
    ADD CONSTRAINT chk_option_code CHECK (code_option LIKE 'O-%');

-- Les types d'options de la regle de gestion
ALTER TABLE OPTIONS
    ADD CONSTRAINT chk_option_type CHECK (type_option IN ('confort', 'securite', 'esthetique', 'multimedia'));
