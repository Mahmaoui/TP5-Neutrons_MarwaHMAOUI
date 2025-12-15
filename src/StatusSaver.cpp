#include <iostream>
#include <fstream> 
#include <string>
#include "CLHEP/Random/MTwistEngine.h"
#include "CLHEP/Random/Random.h" 

using namespace std;
using namespace CLHEP;

// Nombre de statuts à générer (30 réplications)
const int NUM_STATUS = 30;

// Saut très grand pour assurer l'indépendance statistique des flux 
// (10 millions de tirages entre chaque statut)
const long JUMP_SIZE = 10000000; 

int main() 
{
    // Utilisation de la graine par défaut (ou une fixe) pour initialiser la séquence
    MTwistEngine rng(19910905L); // Graine fixe (ex: date de promotion)
    
    cout << "--- Preparation des statuts CLHEP pour Sequence Splitting ---" << endl;
    cout << "Generation de " << NUM_STATUS << " statuts avec un saut de " << JUMP_SIZE << " tirages entre chacun." << endl;

    for (int i = 1; i <= NUM_STATUS; ++i) 
    {
        string filename = "MTStatus-" + to_string(i);
        
        // CLHEP gère l'ouverture et la fermeture du fichier.
        rng.saveStatus(filename.c_str()); 

        // Faire avancer le générateur du JUMP_SIZE de tirages
        for (long j = 0; j < JUMP_SIZE; ++j) {
            rng.flat(); 
        }
        
        cout << "Statut cree: " << filename << endl;
    }
    cout << "--- Fin de la preparation ---" << endl;
    return 0;
}