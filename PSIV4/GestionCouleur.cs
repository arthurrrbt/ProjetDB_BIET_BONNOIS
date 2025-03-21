using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PSIV4
{
    public static class GestionCouleursLignes
    {
        public static Color GetCouleurLigne(string ligne)
        {
            return ligne switch
            {
                "1" or "Ligne 1" => Color.Yellow,
                "2" or "Ligne 2" => Color.Blue,
                "3" or "Ligne 3" => Color.Green,
                "4" or "Ligne 4" => Color.Red,
                "5" or "Ligne 5" => Color.Orange,
                "6" or "Ligne 6" => Color.LightGreen,
                "7" or "Ligne 7" => Color.Purple,
                "8" or "Ligne 8" => Color.Pink,
                "9" or "Ligne 9" => Color.Brown,
                "10" or "Ligne 10" => Color.Gold,
                "11" or "Ligne 11" => Color.Gray,
                "12" or "Ligne 12" => Color.DarkGreen,
                "13" or "Ligne 13" => Color.LightBlue,
                "14" or "Ligne 14" => Color.DarkViolet,
                _ => Color.Black,
            };
        }
    }
}
