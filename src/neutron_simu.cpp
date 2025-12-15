#include <iostream>
#include <fstream> // Toujours utile pour cerr
#include <cmath>
#include <vector>
#include <numeric>
#include <algorithm>
#include <iomanip>
#include <string>

// Bibliothèque CLHEP
#include "CLHEP/Random/MTwistEngine.h"
#include "CLHEP/Random/Random.h" 

using namespace std;
using namespace CLHEP;

// ---- Constantes de Simulation 
const double MATERIAL_THICKNESS = 30.0; 
const double MEAN_FREE_PATH     = 2.86; 
const double P_SCAT             = 0.7;   
const double P_ABS              = 0.3;   

// Déclaration du générateur CLHEP
MTwistEngine* rng = nullptr; 

/** ---------------------------------------------------------------------- *
  * monteCarloSimu()                                                       *
  * *
  * @brief  Exécute une seule réplication de la simulation de neutrons 1D. *
  * @param  numOfNeutrons Le nombre de neutrons à simuler (1M).            *
  * @param  escaped       Compteur de neutrons échappés (sortie).          *
  * @param  absorbed      Compteur de neutrons absorbés (sortie).          *
  * @param  bounces       Compteur de rebonds (sortie).                    *
  * ---------------------------------------------------------------------- **/
void monteCarloSimu(int numOfNeutrons, int& escaped, int& absorbed, int& bounces) 
{
    escaped = 0;
    absorbed = 0;
    bounces = 0;

    if (!rng) {
        cerr << "Erreur: Generateur CLHEP non initialise." << endl;
        exit(1);
    }
    
    for (int i = 0; i < numOfNeutrons; ++i) 
    {
        double x_position = 0.0; 
        
        while (true) 
        {
            // 1. Échantillonnage de la distance (distribution exponentielle)
            double distance = -MEAN_FREE_PATH * log(rng->flat()); 
            
            x_position += distance;

            // 2. Évasion
            if (x_position >= MATERIAL_THICKNESS) 
            {
                escaped++;
                break;
            }

            // 3. Interaction: Absorption ou Scattering
            if (rng->flat() < P_ABS)
            {
                absorbed++;
                break;
            } 
            else 
            {
                // Scattering (rebond 1D)
                if (rng->flat() < 0.5) 
                {
                    // Le neutron repart en arrière
                    x_position = max(0.0, x_position - 2 * distance);  
                    bounces++; 
                }
            }
        }
    }
}

/** ---------------------------------------------------------------------- *
  * main() : Gère le Sequence Splitting par l'argument de statut.          *
  * ---------------------------------------------------------------------- **/
int main(int argc, char* argv[]) 
{
    // Nécessite 3 arguments pour l'approche parallèle SPMD
    if (argc != 3) {
        cerr << "Usage: " << argv[0] << " <Statut_MT_File> <Replication_ID>" << endl;
        return 1;
    }

    const char* status_file = argv[1];
    int replication_id = stoi(argv[2]);
    const int NUM_NEUTRONS_PER_REPLICATION = 1000000; 

    // 1. Initialisation et restauration du statut (Sequence Splitting)
    rng = new MTwistEngine();
    
    // CLHEP gère l'ouverture et la fermeture du fichier de statut.
    rng->restoreStatus(status_file); 
    
    // 2. Exécution de la simulation
    int escaped_neutrons, absorbed_neutrons, numOfBouncing;
    monteCarloSimu(NUM_NEUTRONS_PER_REPLICATION, escaped_neutrons, absorbed_neutrons, numOfBouncing);

    // 3. Affichage des résultats (Format pour traitement statistique)
    cout << replication_id << " "
         << escaped_neutrons << " "
         << absorbed_neutrons << " "
         << numOfBouncing << endl;

    delete rng;
    return 0;
}