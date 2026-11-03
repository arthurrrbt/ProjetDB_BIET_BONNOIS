-- ============================================================
-- CAREFREI - Mini Projet 2
-- Fichier 4 : interrogation de la base
--
-- Scenario (detaille dans le README) :
-- Claire est responsable des achats (service approvisionnement) chez
-- CAREFREI. Elle prepare le plan d'achat de pieces pour l'annee 2027.
-- Elle doit savoir quels modeles et moteurs sont produits, quelles
-- pieces il faut commander, chez quels fournisseurs, et reperer les
-- risques (piece livree par un seul fournisseur, pieces inutilisees...).
-- ============================================================

USE CAREFREI;


-- ============================================================
-- PARTIE A : PROJECTIONS ET SELECTIONS
-- (tri, DISTINCT, LIKE, IN, BETWEEN)
-- ============================================================

-- A1. Liste des modeles, du plus recent au plus ancien
--     (pour savoir quels modeles sont en debut de production)
SELECT code_modele, nom_modele, date_lancement
FROM MODELE
ORDER BY date_lancement DESC;

-- A2. Liste des pays des fournisseurs, sans doublon
SELECT DISTINCT pays
FROM FOURNISSEUR
ORDER BY pays;

-- A3. Pieces liees aux sieges (masque avec LIKE)
SELECT ref_piece, designation
FROM PIECE
WHERE designation LIKE '%siege%';

-- A4. Fournisseurs situes en Allemagne, en Italie ou en Espagne (IN)
SELECT raison_sociale, pays
FROM FOURNISSEUR
WHERE pays IN ('Allemagne', 'Italie', 'Espagne')
ORDER BY pays, raison_sociale;

-- A5. Voitures fabriquees pendant l'annee 2025 (BETWEEN sur des dates)
SELECT vin, date_fabrication, code_modele
FROM VOITURE
WHERE date_fabrication BETWEEN '2025-01-01' AND '2025-12-31'
ORDER BY date_fabrication;

-- A6. Pieces qui pesent entre 1 kg et 10 kg, de la plus lourde a la plus legere
SELECT ref_piece, designation, poids_piece
FROM PIECE
WHERE poids_piece BETWEEN 1000 AND 10000
ORDER BY poids_piece DESC;

-- A7. Noms des moteurs de plus de 100 kW, sans doublon
--     (un meme moteur apparait une fois par modele)
SELECT DISTINCT nom_moteur, puissance
FROM MOTEUR
WHERE puissance > 100
ORDER BY puissance DESC;


-- ============================================================
-- PARTIE B : FONCTIONS D'AGREGATION
-- (COUNT, SUM, AVG, MIN, MAX avec GROUP BY et HAVING)
-- ============================================================

-- B1. Nombre total de voitures produites
SELECT COUNT(*) AS nb_voitures
FROM VOITURE;

-- B2. Nombre de voitures produites pour chaque modele
SELECT code_modele, COUNT(*) AS nb_voitures
FROM VOITURE
GROUP BY code_modele
ORDER BY nb_voitures DESC;

-- B3. Modeles qui proposent au moins 3 moteurs (HAVING)
SELECT code_modele, COUNT(*) AS nb_moteurs
FROM MOTEUR
GROUP BY code_modele
HAVING COUNT(*) >= 3;

-- B4. Puissance minimum, moyenne et maximum par type de cylindre
SELECT type_cylindre,
       MIN(puissance) AS puissance_min,
       ROUND(AVG(puissance), 1) AS puissance_moyenne,
       MAX(puissance) AS puissance_max
FROM MOTEUR
GROUP BY type_cylindre;

-- B5. Fournisseurs qui livrent plus de 5 pieces differentes
--     (les plus gros fournisseurs, a negocier en priorite)
SELECT siret, COUNT(*) AS nb_pieces
FROM LIVRE
GROUP BY siret
HAVING COUNT(*) > 5
ORDER BY nb_pieces DESC;

-- B6. Nombre de voitures produites par annee, seulement les annees
--     avec au moins 8 voitures
SELECT YEAR(date_fabrication) AS annee, COUNT(*) AS nb_voitures
FROM VOITURE
GROUP BY YEAR(date_fabrication)
HAVING COUNT(*) >= 8
ORDER BY annee;

-- B7. Nombre d'options par type d'option
SELECT type_option, COUNT(*) AS nb_options
FROM OPTIONS
GROUP BY type_option;


-- ============================================================
-- PARTIE C : JOINTURES
-- (internes, externes, simples, multiples, auto-jointure)
-- ============================================================

-- C1. Jointure simple : chaque modele avec son type de carrosserie
SELECT M.nom_modele, C.type_carrosserie
FROM MODELE M
JOIN CARROSSERIE C ON C.code_modele = M.code_modele;

-- C2. Jointure multiple (3 tables) : chaque voiture avec le nom
--     de son modele et le nom de son moteur
SELECT V.vin, MO.nom_modele, MT.nom_moteur, V.date_fabrication
FROM VOITURE V
JOIN MODELE MO ON MO.code_modele = V.code_modele
JOIN MOTEUR MT ON MT.code_modele = V.code_modele
              AND MT.code_moteur = V.code_moteur
ORDER BY MO.nom_modele, V.date_fabrication;

-- C3. Jointure multiple (3 tables) : qui livre chaque piece ?
SELECT P.designation, F.raison_sociale, F.pays
FROM PIECE P
JOIN LIVRE L       ON L.ref_piece = P.ref_piece
JOIN FOURNISSEUR F ON F.siret = L.siret
ORDER BY P.designation;

-- C4. Jointure multiple (4 tables) : pieces a acheter pour monter
--     les options disponibles sur le modele Cyrus
SELECT O.libelle_option, P.designation
FROM MODELE M
JOIN DISPONIBLE D ON D.code_modele = M.code_modele
JOIN OPTIONS O    ON O.code_option = D.code_option
JOIN NECESSITE N  ON N.code_option = O.code_option
JOIN PIECE P      ON P.ref_piece = N.ref_piece
WHERE M.nom_modele = 'Cyrus';

-- C5. Jointure externe gauche (LEFT JOIN) : tous les modeles avec
--     leur nombre de voitures produites, meme ceux a 0
SELECT M.nom_modele, COUNT(V.vin) AS nb_voitures
FROM MODELE M
LEFT JOIN VOITURE V ON V.code_modele = M.code_modele
GROUP BY M.nom_modele
ORDER BY nb_voitures;

-- C6. Jointure externe gauche + IS NULL : options disponibles
--     sur aucun modele
SELECT O.code_option, O.libelle_option
FROM OPTIONS O
LEFT JOIN DISPONIBLE D ON D.code_option = O.code_option
WHERE D.code_modele IS NULL;

-- C7. Jointure externe droite (RIGHT JOIN) : pieces qui n'entrent
--     dans la composition d'aucun moteur
SELECT P.ref_piece, P.designation
FROM COMPOSE C
RIGHT JOIN PIECE P ON P.ref_piece = C.ref_piece
WHERE C.ref_piece IS NULL;

-- C8. Auto-jointure : paires de fournisseurs situes dans le meme pays
--     (pour trouver un fournisseur de secours proche)
SELECT F1.raison_sociale AS fournisseur_1,
       F2.raison_sociale AS fournisseur_2,
       F1.pays
FROM FOURNISSEUR F1
JOIN FOURNISSEUR F2 ON F1.pays = F2.pays
                   AND F1.siret < F2.siret;


-- ============================================================
-- PARTIE D : REQUETES IMBRIQUEES
-- (IN, NOT IN, EXISTS, NOT EXISTS, ANY, ALL)
-- ============================================================

-- D1. IN : fournisseurs qui livrent au moins une piece
--     d'un moteur electrique (code qui commence par E-EL)
SELECT raison_sociale
FROM FOURNISSEUR
WHERE siret IN (SELECT siret
                FROM LIVRE
                WHERE ref_piece IN (SELECT ref_piece
                                    FROM COMPOSE
                                    WHERE code_moteur LIKE 'E-EL%'));

-- D2. NOT IN : pieces utilisees dans aucun moteur et dans aucune option
--     (pieces a ne pas commander)
SELECT ref_piece, designation
FROM PIECE
WHERE ref_piece NOT IN (SELECT ref_piece FROM COMPOSE)
  AND ref_piece NOT IN (SELECT ref_piece FROM NECESSITE);

-- D3. IN + GROUP BY / HAVING : pieces livrees par un seul fournisseur
--     (risque de rupture d'approvisionnement)
SELECT ref_piece, designation
FROM PIECE
WHERE ref_piece IN (SELECT ref_piece
                    FROM LIVRE
                    GROUP BY ref_piece
                    HAVING COUNT(*) = 1);

-- D4. NOT EXISTS : energies utilisees par aucun moteur
SELECT E.energie_moteur
FROM ENERGIE E
WHERE NOT EXISTS (SELECT *
                  FROM FONCTIONNE F
                  WHERE F.energie_moteur = E.energie_moteur);

-- D5. EXISTS : modeles dont au moins une voiture a ete produite
--     avec un moteur electrique
SELECT M.nom_modele
FROM MODELE M
WHERE EXISTS (SELECT *
              FROM VOITURE V
              WHERE V.code_modele = M.code_modele
                AND V.code_moteur LIKE 'E-EL%');

-- D6. ALL : moteurs plus puissants que TOUS les moteurs diesel
SELECT DISTINCT nom_moteur, puissance
FROM MOTEUR
WHERE puissance > ALL (SELECT puissance
                       FROM MOTEUR
                       WHERE nom_moteur LIKE '%diesel%');

-- D7. ANY : pieces plus lourdes qu'au moins une piece livree
--     par Tokai Denso KK
SELECT designation, poids_piece
FROM PIECE
WHERE poids_piece > ANY (SELECT P.poids_piece
                         FROM PIECE P
                         JOIN LIVRE L       ON L.ref_piece = P.ref_piece
                         JOIN FOURNISSEUR F ON F.siret = L.siret
                         WHERE F.raison_sociale = 'Tokai Denso KK')
ORDER BY poids_piece;

-- D8. Sous-requete avec une fonction d'agregation : la piece la plus lourde
SELECT designation, poids_piece
FROM PIECE
WHERE poids_piece = (SELECT MAX(poids_piece) FROM PIECE);

-- D9. Sous-requete avec AVG : modeles plus longs que la moyenne
SELECT nom_modele, longueur
FROM MODELE
WHERE longueur > (SELECT AVG(longueur) FROM MODELE)
ORDER BY longueur DESC;


-- ============================================================
-- REQUETE ETUDIEE DANS LE README (plans d'execution)
-- Designation des pieces de plus de 5 kg livrees par
-- un fournisseur francais, avec le nom du fournisseur.
-- Operateurs : selection, jointure, projection
-- ============================================================

SELECT P.designation, F.raison_sociale
FROM FOURNISSEUR F
JOIN LIVRE L ON L.siret = F.siret
JOIN PIECE P ON P.ref_piece = L.ref_piece
WHERE F.pays = 'France'
  AND P.poids_piece > 5000;
