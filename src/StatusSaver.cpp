/**
 * statusSaver.cpp
 * Génération de 30 statuts espacés pour Sequence Splitting
 * Question 4 du TP5
 */

#include <iostream>
#include <sstream>
#include <iomanip>
#include "CLHEP/Random/MTwistEngine.h"

int main() {
    CLHEP::MTwistEngine* mt = new CLHEP::MTwistEngine();
    
    const int N_STATUS = 30;
    const long JUMP_SIZE = 10000000; // 10^7 tirages entre chaque statut
    
    std::cout << "=== Génération de " << N_STATUS << " statuts MT ===" << std::endl;
    std::cout << "Espacement: " << JUMP_SIZE << " tirages" << std::endl;
    std::cout << std::endl;
    
    for(int i = 0; i < N_STATUS; i++) {
        // Création du nom de fichier
        std::ostringstream filename;
        filename << "MTStatus-" << i;
        
        // Sauvegarde du statut
        mt->saveStatus(filename.str());
        
        std::cout << "Statut " << std::setw(2) << i << " sauvegardé: " 
                  << filename.str() << std::endl;
        
        // Avancer le générateur de JUMP_SIZE tirages
        for(long j = 0; j < JUMP_SIZE; j++) {
            mt->flat();
        }
    }
    
    delete mt;
    
    std::cout << std::endl;
    std::cout << "=== Tous les statuts ont été générés avec succès ! ===" << std::endl;
    std::cout << "Fichiers créés: MTStatus-0 à MTStatus-29" << std::endl;
    
    return 0;
}
