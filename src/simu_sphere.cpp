#include <iostream>
#include <iomanip>
#include <cmath>
#include <cstdlib>
#include <sstream>
#include "CLHEP/Random/MTwistEngine.h"

double estimateSpherVolume(long N, CLHEP::MTwistEngine* mt) {
    long inside = 0;
    for (long i = 0; i < N; i++) {
        double x = 2.0 * mt->flat() - 1.0;
        double y = 2.0 * mt->flat() - 1.0;
        double z = 2.0 * mt->flat() - 1.0;
        if (x*x + y*y + z*z <= 1.0) inside++;
    }
    return 8.0 * inside / N;
}

int main(int argc, char* argv[]) {
    CLHEP::MTwistEngine* mt = new CLHEP::MTwistEngine();
    
    // Mode 1 : Avec argument (Sequence Splitting pour parallélisation)
    if (argc == 2) {
        int statusNum = atoi(argv[1]);
        
        // Restauration du statut spécifique
        std::ostringstream filename;
        filename << "MTStatus-" << statusNum;
        mt->restoreStatus(filename.str().c_str());
        
        // Simulation avec 10^6 points
        double volume = estimateSpherVolume(1000000, mt);
        
        // Sortie simple pour récupération par script
        std::cout << volume << std::endl;
    }
    // Mode 2 : Sans argument (30 réplications séquentielles)
    else {
        const int N_REP = 30;
        long N_points[] = {1000, 1000000, 1000000000};
        
        for (int exp = 0; exp < 3; exp++) {
            long N = N_points[exp];
            double sum = 0, sum_sq = 0;
            
            std::cout << "\n=== Simulation avec N = " << N << " ===" << std::endl;
            
            for (int rep = 0; rep < N_REP; rep++) {
                double V = estimateSpherVolume(N, mt);
                sum += V;
                sum_sq += V * V;
                std::cout << "Rep " << rep+1 << " : V = " << V << std::endl;
            }
            
            double mean = sum / N_REP;
            double variance = (sum_sq / N_REP) - (mean * mean);
            double std_dev = sqrt(variance);
            double conf_radius = 1.96 * std_dev / sqrt(N_REP);
            
            std::cout << std::fixed << std::setprecision(6);
            std::cout << "\nMoyenne : " << mean << std::endl;
            std::cout << "Écart-type : " << std_dev << std::endl;
            std::cout << "IC 95%: [" << mean - conf_radius 
                      << ", " << mean + conf_radius << "]" << std::endl;
            std::cout << "Rayon de confiance : +/- " << conf_radius << std::endl;
            std::cout << "Erreur relative : " << fabs(mean - 4.18879) / 4.18879 * 100 
                      << "%" << std::endl;
        }
    }
    
    delete mt;
    return 0;
}
