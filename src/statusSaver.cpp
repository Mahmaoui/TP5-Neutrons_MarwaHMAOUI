#include <iostream>
#include <sstream>
#include "CLHEP/Random/MTwistEngine.h"

int main() {
    CLHEP::MTwistEngine* mt = new CLHEP::MTwistEngine();
    const int N_STATUS = 30;
    const long JUMP_SIZE = 10000000; // 10^7 tirages entre chaque statut
    
    std::cout << "Génération de " << N_STATUS << " statuts séparés de " 
              << JUMP_SIZE << " tirages..." << std::endl;
    
    for (int i = 0; i < N_STATUS; i++) {
        // Création du nom de fichier
        std::ostringstream filename;
        filename << "MTStatus-" << i;
        
        // Sauvegarde du statut
        mt->saveStatus(filename.str().c_str());
        std::cout << "Statut " << i << " sauvegardé : " << filename.str() << std::endl;
        
        // Avancer le générateur de JUMP_SIZE tirages
        for (long j = 0; j < JUMP_SIZE; j++) {
            mt->flat();
        }
    }
    
    delete mt;
    std::cout << "\nTous les statuts ont été générés avec succès !" << std::endl;
    return 0;
}
