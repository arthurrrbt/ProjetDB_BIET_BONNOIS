using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PSIV4
{
    public class Lien
    {
        public int Station1 { get; }
        public int Station2 { get; }

        public Lien(int station1, int station2)
        {
            Station1 = station1;
            Station2 = station2;
        }
    }
}
