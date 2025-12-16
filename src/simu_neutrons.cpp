#include <iostream>
#include <iomanip>
#include <cmath>
#include <cstdlib>
#include <sstream>
#include "CLHEP/Random/MTwistEngine.h"

struct NeutronResults {
    long escaped;
    long absorbed;
    long totalBounces;
};

NeutronResults simulateNeutrons(long N, CLHEP::MTwistEngine* mt) {
    const double L = 30.0;
    const double lambda = 2.86;
    const double P_abs = 0.3;
    
    NeutronResults res = {0, 0, 0};
    
    for (long n = 0; n < N; n++) {
        double x = 0.0;
        bool escaped = false;
        bool absorbed = false;
        
        while (!escaped && !absorbed) {
            // Libre parcours
            double d = -lambda * log(mt->flat());
            
            // Direction aléatoire (1D : gauche ou droite)
            if (mt->flat() < 0.5) d = -d;
            
            x += d;
            res.totalBounces++;
            
            if (x < 0 || x > L) {
                escaped = true;
                res.escaped++;
            } else if (mt->flat() < P_abs) {
                absorbed = true;
                res.absorbed++;
            }
        }
    }
    
    return res;
}

int main(int argc, char* argv[]) {
    CLHEP::MTwistEngine* mt = new CLHEP::MTwistEngine();
    
    // Mode 1 : Avec argument (Sequence Splitting pour parallélisation)
    if (argc == 2) {
        int statusNum = atoi(argv[1]);
        
        // Restauration du statut spécifique
        std::ostringstream filename;
        filename << "MTStatus-" << statusNum;
        mt->restoreStatus(filename.str());
        
        // Simulation avec 10^6 neutrons
        NeutronResults res = simulateNeutrons(1000000, mt);
        
        // Sortie simple pour récupération par script
        std::cout << res.escaped << " " << res.absorbed << " " << res.totalBounces << std::endl;
    }
    // Mode 2 : Sans argument (30 réplications séquentielles)
    else {
        const int N_REP = 30;
        long N_neutrons[] = {1000, 1000000};
        
        for (int exp = 0; exp < 2; exp++) {
            long N = N_neutrons[exp];
            double sum_esc = 0, sum_abs = 0, sum_bounces = 0;
            double sum_sq_esc = 0, sum_sq_abs = 0, sum_sq_bounces = 0;
            
            std::cout << "\n=== Simulation de " << N << " neutrons ===" << std::endl;
            
            for (int rep = 0; rep < N_REP; rep++) {
                NeutronResults res = simulateNeutrons(N, mt);
                sum_esc += res.escaped;
                sum_abs += res.absorbed;
                sum_bounces += res.totalBounces;
                sum_sq_esc += res.escaped * res.escaped;
                sum_sq_abs += res.absorbed * res.absorbed;
                sum_sq_bounces += res.totalBounces * res.totalBounces;
            }
            
            double mean_esc = sum_esc / N_REP;
            double mean_abs = sum_abs / N_REP;
            double mean_bounces = sum_bounces / N_REP;
            
            double std_esc = sqrt(sum_sq_esc / N_REP - mean_esc * mean_esc);
            double std_abs = sqrt(sum_sq_abs / N_REP - mean_abs * mean_abs);
            double std_bounces = sqrt(sum_sq_bounces / N_REP - mean_bounces * mean_bounces);
            
            double ic_esc = 1.96 * std_esc / sqrt(N_REP);
            double ic_abs = 1.96 * std_abs / sqrt(N_REP);
            double ic_bounces = 1.96 * std_bounces / sqrt(N_REP);
            
            std::cout << std::fixed << std::setprecision(2);
            std::cout << "\nÉchappés : " << mean_esc << " ± " << ic_esc << std::endl;
            std::cout << "Absorbés : " << mean_abs << " ± " << ic_abs << std::endl;
            std::cout << "Rebonds : " << mean_bounces << " ± " << ic_bounces << std::endl;
        }
    }
    
    delete mt;
    return 0;
}
