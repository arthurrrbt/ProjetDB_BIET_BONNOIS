using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using DocumentFormat.OpenXml.Vml;

namespace PSIV4
{
    public class Noeud
    {
        public int Id { get; private set; }
        public string Nom { get; private set; }
        public double Latitude { get; private set; }
        public double Longitude { get; private set; }
        public string Ligne { get; private set; }
        public Color Couleur { get; private set; }

        public Noeud(int id, string nom, double lat, double lon, string ligne)
        {
            Id = id;
            Nom = nom;
            Latitude = lat;
            Longitude = lon;
            Ligne = ligne;
            Couleur = GestionCouleursLignes.GetCouleurLigne(ligne);
        }
    }

    
}
