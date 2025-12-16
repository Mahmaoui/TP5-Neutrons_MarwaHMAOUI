#include <iostream>
#include <iomanip>
#include <string>
#include <cmath>
#include <cstdlib>
#include <sstream>
#include "CLHEP/Random/MTwistEngine.h"

char randomBase(CLHEP::MTwistEngine* mt) {
    double r = mt->flat();
    if (r < 0.25) return 'A';
    else if (r < 0.5) return 'C';
    else if (r < 0.75) return 'G';
    else return 'T';
}

long tryGenerateSequence(const std::string& target, CLHEP::MTwistEngine* mt) {
    long attempts = 0;
    std::string current = "";
    
    while (current != target) {
        current = "";
        for (size_t i = 0; i < target.length(); i++) {
            current += randomBase(mt);
        }
        attempts++;
    }
    
    return attempts;
}

int main(int argc, char* argv[]) {
    CLHEP::MTwistEngine* mt = new CLHEP::MTwistEngine();
    
    std::string target = "AAATTTGCGTTCGATTAG"; // 18 bases
    const int N_REP = 40;
    
    // Mode 1 : Avec argument (Sequence Splitting pour parallélisation)
    if (argc == 2) {
        int statusNum = atoi(argv[1]);
        
        // Restauration du statut spécifique
        std::ostringstream filename;
        filename << "MTStatus-" << statusNum;
        mt->restoreStatus(filename.str().c_str());
        
        // Une seule réplication
        long attempts = tryGenerateSequence(target, mt);
        std::cout << attempts << std::endl;
    }
    // Mode 2 : Sans argument (40 réplications séquentielles)
    else {
        std::cout << "Cible : " << target << " (longueur : " 
                  << target.length() << ")" << std::endl;
        std::cout << "Probabilité théorique : 1/4^" << target.length()
                  << " = 1/" << pow(4, target.length()) << std::endl;
        
        double sum = 0, sum_sq = 0;
        
        for (int rep = 0; rep < N_REP; rep++) {
            long attempts = tryGenerateSequence(target, mt);
            sum += attempts;
            sum_sq += attempts * attempts;
            std::cout << "Rep " << rep+1 << " : " << attempts 
                      << " essais" << std::endl;
        }
        
        double mean = sum / N_REP;
        double std_dev = sqrt(sum_sq / N_REP - mean * mean);
        double ic = 1.96 * std_dev / sqrt(N_REP);
        
        std::cout << std::fixed << std::setprecision(0);
        std::cout << "\nMoyenne : " << mean << " ± " << ic << " essais" << std::endl;
        std::cout << "Probabilité estimée : 1/" << mean << std::endl;
        
        std::cout << "\n=== Extension : Génome humain ===" << std::endl;
        std::cout << "Génome humain : 3 milliards de bases" << std::endl;
        std::cout << "Probabilité : 1/4^(3×10^9) ≈ 10^(-1.8×10^9)" << std::endl;
        std::cout << "Ce nombre est infiniment plus petit que 1/(nombre d'atomes dans l'univers) ≈ 10^(-80)" << std::endl;
    }
    
    delete mt;
    return 0;
}
