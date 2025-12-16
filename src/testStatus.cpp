#include <iostream>
#include "CLHEP/Random/MTwistEngine.h"

int main() {
    CLHEP::MTwistEngine* mt = new CLHEP::MTwistEngine();
    
    // Génération initiale
    std::cout << "=== Séquence initiale ===" << std::endl;
    for (int i = 0; i < 5; i++) {
        std::cout << mt->flat() << std::endl;
    }
    
    // Sauvegarde du statut
    mt->saveStatus("status_test.txt");
    
    // Génération de 10 nombres
    std::cout << "\n=== 10 nombres suivants ===" << std::endl;
    for (int i = 0; i < 10; i++) {
        std::cout << mt->flat() << std::endl;
    }
    
    // Restauration du statut
    mt->restoreStatus("status_test.txt");
    
    // Vérification : on retrouve les mêmes 10 nombres
    std::cout << "\n=== Après restauration (identique) ===" << std::endl;
    for (int i = 0; i < 10; i++) {
        std::cout << mt->flat() << std::endl;
    }
    
    delete mt;
    return 0;
}
