using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Windows.Forms;
using DocumentFormat.OpenXml.Bibliography;
using OfficeOpenXml;

namespace PSIV4
{
    public class Graphe
    {
        public List<Noeud> Noeuds { get; private set; } = new();

        public void AjouterNoeud(int id, string nom, double lat, double lon, string ligne)
        {
            Noeuds.Add(new Noeud(id, nom, lat, lon, ligne));
        }

        public void ImporterStationsDepuisExcel()
        {
            string cheminFichier = @"MetroParis.xlsx";

            if (!File.Exists(cheminFichier))
            {
                MessageBox.Show("Fichier Excel introuvable !", "Erreur", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            ExcelPackage.LicenseContext = OfficeOpenXml.LicenseContext.NonCommercial;

            using (var package = new ExcelPackage(new FileInfo(cheminFichier)))
            {
                var feuille = package.Workbook.Worksheets[0];
                int rowCount = feuille.Dimension.Rows;

                for (int row = 2; row <= rowCount; row++)
                {
                    var idCell = feuille.Cells[row, 1].Value;
                    var ligneCell = feuille.Cells[row, 2].Value;
                    var nomCell = feuille.Cells[row, 3].Value;
                    var lonCell = feuille.Cells[row, 4].Value;
                    var latCell = feuille.Cells[row, 5].Value;

                    if (idCell == null || nomCell == null || lonCell == null || latCell == null || ligneCell == null)
                    {
                        continue;
                    }

                    if (!int.TryParse(idCell.ToString(), out int id))
                    {
                        continue;
                    }

                    string nom = nomCell.ToString();
                    string ligne = ligneCell.ToString();
                    if (!double.TryParse(latCell.ToString(), NumberStyles.Float, CultureInfo.InvariantCulture, out double lat))
                    {
                        continue;
                    }

                    if (!double.TryParse(lonCell.ToString(), NumberStyles.Float, CultureInfo.InvariantCulture, out double lon))
                    {
                        continue;
                    }

                    AjouterNoeud(id, nom, lat, lon, ligne);
                }
            }
        }

        public List<(string NomStation, string StationPre, string StationSuiv)> RecupererConnexions()
        {
            List<(string NomStation, string StationPre, string StationSuiv)> connexions = new();
            string cheminFichier = @"MetroParis.xlsx";

            if (!File.Exists(cheminFichier))
                return connexions;

            ExcelPackage.LicenseContext = OfficeOpenXml.LicenseContext.NonCommercial;

            using (var package = new ExcelPackage(new FileInfo(cheminFichier)))
            {
                var feuille = package.Workbook.Worksheets["Arcs"];
                int rowCount = feuille.Dimension.Rows;

                for (int row = 2; row <= rowCount; row++)
                {
                    var nomStationCell = feuille.Cells[row, 2].Value;
                    var precedentCell = feuille.Cells[row, 3].Value;
                    var suivantCell = feuille.Cells[row, 4].Value;

                    string nomStation = nomStationCell?.ToString() ?? "";
                    string precedent = precedentCell?.ToString() ?? "";
                    string suivant = suivantCell?.ToString() ?? "";

                    precedent = precedent.StartsWith("=") ? "" : precedent;
                    suivant = suivant.StartsWith("=") ? "" : suivant;

                    connexions.Add((nomStation, precedent, suivant));
                }
            }

            return connexions;
        }

        public List<Noeud> GetStations()
        {
            return Noeuds;
        }
    }
}