using System;
using System.Drawing;
using System.Linq;
using System.Windows.Forms;
using System.Runtime.InteropServices;
using System.Collections.Generic;

namespace PSIV4
{
    public partial class GrapheForm : Form
    {
        private Graphe graphe;
        private AffichageGraphe affichageGraphe;
        private List<(string NomStation, string StationPre, string StationSuiv)> connexions;
        private float zoomFactor = 1.0f;
        private PointF translation = new PointF(0, 0);
        private Panel panelAffichage;

        // Variables pour le déplacement
        private bool isDragging = false;
        private Point lastMousePosition;

        [DllImport("kernel32.dll")]
        static extern bool AllocConsole();

        public GrapheForm()
        {
            InitializeComponent();

            // Création du panel d'affichage avec DoubleBuffering pour éviter le scintillement
            panelAffichage = new Panel { Dock = DockStyle.Fill };
            typeof(Panel).InvokeMember("DoubleBuffered",
                System.Reflection.BindingFlags.SetProperty | System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.NonPublic,
                null, panelAffichage, new object[] { true });

            this.Controls.Add(panelAffichage);

            // Initialisation du graphe
            graphe = new Graphe();
            AllocConsole();

            // Chargement des données
            graphe.ImporterStationsDepuisExcel();
            connexions = graphe.RecupererConnexions();

            // Affichage console (vérification)
            AfficherConnexionsConsole();

            // Préparation affichage graphique
            affichageGraphe = new AffichageGraphe(graphe);
            this.WindowState = FormWindowState.Maximized;
            this.Text = "Affichage du Graphe";

            // Événements
            panelAffichage.Paint += new PaintEventHandler(Dessine);
            panelAffichage.MouseWheel += new MouseEventHandler(Zoom);
            panelAffichage.MouseDown += new MouseEventHandler(MousePressed);
            panelAffichage.MouseMove += new MouseEventHandler(MouseMoved);
            panelAffichage.MouseUp += new MouseEventHandler(MouseReleased);
        }

        private void AfficherConnexionsConsole()
        {
            Console.Clear();
            Console.WriteLine("Liste des connexions :\n");
            Console.WriteLine("Station\t\tPrécédent\tSuivant");
            Console.WriteLine("---------------------------------");

            foreach (var connexion in connexions)
            {
                Console.WriteLine($"{connexion.NomStation.PadRight(15)}\t{connexion.StationPre.PadRight(10)}\t{connexion.StationSuiv.PadRight(10)}");
            }

            Console.WriteLine($"\nTotal connexions chargées : {connexions.Count}");
        }

        private void Dessine(object sender, PaintEventArgs e)
        {
            Graphics g = e.Graphics;

            // Appliquer les transformations
            g.TranslateTransform(translation.X, translation.Y);
            g.ScaleTransform(zoomFactor, zoomFactor);

            // Dessin du graphe
            affichageGraphe.Dessiner(g, connexions);
        }

        private void Zoom(object sender, MouseEventArgs e)
        {
            const float zoomStep = 0.1f;
            float oldZoomFactor = zoomFactor;
            float newZoomFactor = (e.Delta > 0) ? zoomFactor * (1 + zoomStep) : zoomFactor / (1 + zoomStep);

            if (newZoomFactor < 0.2f || newZoomFactor > 5f)
                return; // Empêche un zoom trop petit ou trop grand

            // Coordonnées du curseur avant le zoom (converties dans le repère du graphe)
            float mouseXBefore = (e.X - translation.X) / oldZoomFactor;
            float mouseYBefore = (e.Y - translation.Y) / oldZoomFactor;

            // Appliquer le nouveau facteur de zoom
            zoomFactor = newZoomFactor;

            // Recalcul du décalage pour garder le point sous le curseur fixe
            translation.X = e.X - (mouseXBefore * zoomFactor);
            translation.Y = e.Y - (mouseYBefore * zoomFactor);

            panelAffichage.Invalidate(); // Redessiner uniquement le panel
        }

        private void MousePressed(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left)
            {
                isDragging = true;
                lastMousePosition = e.Location;
            }
        }

        private void MouseMoved(object sender, MouseEventArgs e)
        {
            if (isDragging)
            {
                translation.X += e.X - lastMousePosition.X;
                translation.Y += e.Y - lastMousePosition.Y;
                lastMousePosition = e.Location;

                panelAffichage.Invalidate(); // Redessiner après déplacement
            }
        }

        private void MouseReleased(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left)
            {
                isDragging = false;
            }
        }
    }
}
