using System;
using System.Collections.Generic;
using System.Drawing;

namespace PSIV4
{
    public class AffichageGraphe
    {
        private Graphe graphe;
        private const int RayonNoeud = 25; // Taille des cercles des stations

        // Coordonnées min/max des stations pour normalisation
        private float minLongitude, maxLongitude;
        private float minLatitude, maxLatitude;

        public AffichageGraphe(Graphe graphe)
        {
            this.graphe = graphe;
            CalculerBornesCoordonnees();
        }

        private void CalculerBornesCoordonnees()
        {
            if (graphe.Noeuds.Count == 0) return;

            minLongitude = float.MaxValue;
            maxLongitude = float.MinValue;
            minLatitude = float.MaxValue;
            maxLatitude = float.MinValue;

            foreach (var noeud in graphe.Noeuds)
            {
                if (noeud.Longitude < minLongitude) minLongitude = (float)noeud.Longitude;
                if (noeud.Longitude > maxLongitude) maxLongitude = (float)noeud.Longitude;
                if (noeud.Latitude < minLatitude) minLatitude = (float)noeud.Latitude;
                if (noeud.Latitude > maxLatitude) maxLatitude = (float)noeud.Latitude;
            }
        }

        public void Dessiner(Graphics g, List<(string NomStation, string StationPre, string StationSuiv)> connexions)
        {
            var stations = graphe.GetStations();
            int largeur = 2500;
            int hauteur = 1100;

            // --- Dessiner les liens (connexions/arcs) ---
            foreach (var connexion in connexions)
            {
                var stationActuelle = stations.FirstOrDefault(s => s.Nom == connexion.NomStation);
                var stationPre = stations.FirstOrDefault(s => s.Nom == connexion.StationPre);
                var stationSuiv = stations.FirstOrDefault(s => s.Nom == connexion.StationSuiv);

                if (stationActuelle == null) continue;
                PointF pActuelle = ConvertirCoordonnees(stationActuelle, largeur, hauteur);
                Pen pen = new Pen(stationActuelle.Couleur, 2); // Connexions colorées selon la ligne

                if (stationPre != null)
                {
                    PointF pPre = ConvertirCoordonnees(stationPre, largeur, hauteur);
                    g.DrawLine(pen, pActuelle, pPre);
                }

                if (stationSuiv != null)
                {
                    PointF pSuiv = ConvertirCoordonnees(stationSuiv, largeur, hauteur);
                    g.DrawLine(pen, pActuelle, pSuiv);
                }
            }

            // --- Dessiner les nœuds (stations) ---
            Font font = new Font("Arial", 2, FontStyle.Bold);
            StringFormat sf = new StringFormat { Alignment = StringAlignment.Center, LineAlignment = StringAlignment.Center };

            foreach (Noeud station in stations)
            {
                PointF p = ConvertirCoordonnees(station, largeur, hauteur);
                Brush brush = new SolidBrush(station.Couleur);
                g.FillEllipse(brush, p.X - RayonNoeud / 2, p.Y - RayonNoeud / 2, RayonNoeud, RayonNoeud);
                g.DrawEllipse(Pens.Black, p.X - RayonNoeud / 2, p.Y - RayonNoeud / 2, RayonNoeud, RayonNoeud);

                RectangleF rect = new RectangleF(p.X - RayonNoeud / 2, p.Y - RayonNoeud / 2, RayonNoeud, RayonNoeud);
                g.DrawString(station.Nom, font, Brushes.White, rect, sf);
            }
        }

        private float echelle = 0.9f;
        private PointF ConvertirCoordonnees(Noeud station, int largeur, int hauteur)
        {
            float longitudeRange = maxLongitude - minLongitude;
            float latitudeRange = maxLatitude - minLatitude;

            if (longitudeRange == 0) longitudeRange = 1;
            if (latitudeRange == 0) latitudeRange = 1;

            float x = (float)((station.Longitude - minLongitude) / longitudeRange * largeur * echelle);
            float y = (float)((station.Latitude - minLatitude) / latitudeRange * hauteur * echelle);

            y = hauteur * echelle - y;

            float offsetX = (largeur * (1 - echelle)) / 2;
            float offsetY = (hauteur * (1 - echelle)) / 2;

            return new PointF(x + offsetX, y + offsetY);
        }
    }
}