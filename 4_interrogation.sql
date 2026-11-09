USE CAREFREI;

SELECT ref_piece, designation
FROM PIECE
WHERE designation LIKE '%siege%';

SELECT raison_sociale, pays
FROM FOURNISSEUR
WHERE pays IN ('Allemagne', 'Italie', 'Espagne')
ORDER BY pays, raison_sociale;

SELECT vin, date_fabrication, code_modele
FROM VOITURE
WHERE date_fabrication BETWEEN '2025-01-01' AND '2025-12-31'
ORDER BY date_fabrication;

SELECT DISTINCT nom_moteur, puissance
FROM MOTEUR
WHERE puissance > 100
ORDER BY puissance DESC;

SELECT code_modele, COUNT(*) AS nb_voitures
FROM VOITURE
GROUP BY code_modele
ORDER BY nb_voitures DESC;

SELECT code_modele, COUNT(*) AS nb_moteurs
FROM MOTEUR
GROUP BY code_modele
HAVING COUNT(*) >= 3;

SELECT type_cylindre,
       MIN(puissance) AS puissance_min,
       ROUND(AVG(puissance), 1) AS puissance_moyenne,
       MAX(puissance) AS puissance_max
FROM MOTEUR
GROUP BY type_cylindre;

SELECT siret, COUNT(*) AS nb_pieces
FROM LIVRE
GROUP BY siret
HAVING COUNT(*) > 5
ORDER BY nb_pieces DESC;

SELECT YEAR(date_fabrication) AS annee, COUNT(*) AS nb_voitures
FROM VOITURE
GROUP BY YEAR(date_fabrication)
HAVING COUNT(*) >= 8
ORDER BY annee;

SELECT P.designation, F.raison_sociale
FROM FOURNISSEUR F
JOIN LIVRE L ON L.siret = F.siret
JOIN PIECE P ON P.ref_piece = L.ref_piece
WHERE F.pays = 'France'
  AND P.poids_piece > 5000;
