/**
 * simu_adn.cpp
 * Simulation de génération aléatoire de séquences d'ADN
 * Question 7 (Optionnelle) du TP5 - Application à la bioinformatique
 * 
 * Principe: Tirer au hasard des bases nucléiques (A, C, G, T)
 * jusqu'à obtenir une séquence cible spécifique
 */

#include <iostream>
#include <iomanip>
#include <string>
#include <cmath>
#include <cstdlib>
#include <sstream>
#include "CLHEP/Random/MTwistEngine.h"

// Génération d'une base nucléique aléatoire
char randomBase(CLHEP::MTwistEngine* mt) {
    double r = mt->flat();
    if(r < 0.25) return 'A';
    else if(r < 0.5) return 'C';
    else if(r < 0.75) return 'G';
    else return 'T';
}

// Génération d'une séquence aléatoire de longueur n
std::string randomSequence(int length, CLHEP::MTwistEngine* mt) {
    std::string seq = "";
    for(int i = 0; i < length; i++) {
        seq += randomBase(mt);
    }
    return seq;
}

// Tentative de générer une séquence cible
long long tryGenerateSequence(const std::string& target, 
                              CLHEP::MTwistEngine* mt) {
    long long attempts = 0;
    std::string current;
    
    do {
        current = randomSequence(target.length(), mt);
        attempts++;
        
        // Affichage progressif pour les longues recherches
        if(attempts % 1000000 == 0) {
            std::cout << "  ... " << attempts / 1000000 << "M essais" << std::endl;
        }
    } while(current != target);
    
    return attempts;
}

// Calcul de la probabilité théorique
double theoreticalProbability(int length) {
    return pow(4.0, -length);
}

// Mode parallèle : une seule réplication
int parallelMode(int statusNum, const std::string& target) {
    std::ostringstream filename;
    filename << "MTStatus-" << statusNum;
    
    CLHEP::MTwistEngine* mt = new CLHEP::MTwistEngine();
    mt->restoreStatus(filename.str());
    
    long long attempts = tryGenerateSequence(target, mt);
    std::cout << attempts << std::endl;
    
    delete mt;
    return 0;
}

// Mode séquentiel : analyse complète
int sequentialMode() {
    CLHEP::MTwistEngine* mt = new CLHEP::MTwistEngine();
    
    // Séquences à tester (par ordre de difficulté croissante)
    std::string sequences[] = {
        "GATTACA",                    // 7 bases
        "AAATTTGCGTTCGATTAG",         // 18 bases
        "ATCGATCGATCG"                // 12 bases
    };
    
    for(int seq_idx = 0; seq_idx < 3; seq_idx++) {
        std::string target = sequences[seq_idx];
        int length = target.length();
        double prob_theo = theoreticalProbability(length);
        
        std::cout << "\n==============================================" << std::endl;
        std::cout << "=== Séquence: " << target << " ===" << std::endl;
        std::cout << "==============================================" << std::endl;
        std::cout << "Longueur            : " << length << " bases" << std::endl;
        std::cout << "Probabilité théorique: 1/4^" << length << " = " << prob_theo << std::endl;
        std::cout << "Essais théoriques   : " << std::scientific << 1.0 / prob_theo << std::endl;
        
        // Estimation si la simulation est faisable
        if(length > 10) {
            std::cout << "\n⚠️  ATTENTION: Cette séquence est très longue !" << std::endl;
            std::cout << "Le nombre d'essais attendu dépasse largement les capacités." << std::endl;
            std::cout << "Simulation non lancée pour cette séquence." << std::endl;
            continue;
        }
        
        // Réplications pour séquences courtes uniquement
        const int N_REP = (length <= 8) ? 40 : 10;
        std::cout << "\n=== Lancement de " << N_REP << " réplications ===" << std::endl;
        
        double sum = 0, sum_sq = 0;
        
        for(int rep = 0; rep < N_REP; rep++) {
            std::cout << "\nRéplication " << (rep + 1) << "/" << N_REP << ":" << std::endl;
            long long attempts = tryGenerateSequence(target, mt);
            sum += attempts;
            sum_sq += attempts * attempts;
            
            std::cout << "  ✓ Succès après " << attempts << " essais" << std::endl;
        }
        
        // Statistiques
        double mean = sum / N_REP;
        double variance = (sum_sq / N_REP) - (mean * mean);
        double std_dev = sqrt(variance);
        double conf_radius = 1.96 * std_dev / sqrt(N_REP);
        double prob_est = 1.0 / mean;
        
        std::cout << "\n=== Résultats Statistiques ===" << std::endl;
        std::cout << std::fixed << std::setprecision(2);
        std::cout << "Nombre moyen d'essais: " << mean << " ± " << conf_radius << std::endl;
        std::cout << "Écart-type           : " << std_dev << std::endl;
        std::cout << "IC 95%               : [" << (mean - conf_radius) 
                  << ", " << (mean + conf_radius) << "]" << std::endl;
        std::cout << std::scientific;
        std::cout << "Probabilité estimée  : " << prob_est << std::endl;
        std::cout << "Probabilité théorique: " << prob_theo << std::endl;
        std::cout << std::fixed << std::setprecision(2);
        std::cout << "Erreur relative      : " 
                  << fabs(prob_est - prob_theo) / prob_theo * 100.0 << "%" << std::endl;
    }
    
    delete mt;
    return 0;
}

// Fonction pour estimer la génération d'une phrase
void estimatePhrase() {
    std::string phrase = "Le hasard n ecrit pas de messages";
    int length = phrase.length();
    
    std::cout << "\n==============================================" << std::endl;
    std::cout << "=== Estimation: Phrase intelligible ===" << std::endl;
    std::cout << "==============================================" << std::endl;
    std::cout << "Phrase: \"" << phrase << "\"" << std::endl;
    std::cout << "Longueur: " << length << " caractères" << std::endl;
    
    // Avec alphabet ASCII imprimable (95 caractères)
    const int ASCII_PRINTABLE = 95;
    double prob = pow(ASCII_PRINTABLE, -length);
    
    std::cout << std::scientific;
    std::cout << "Probabilité (ASCII): 1/" << ASCII_PRINTABLE << "^" << length 
              << " = " << prob << std::endl;
    std::cout << "Essais nécessaires : " << 1.0 / prob << std::endl;
    
    // Temps estimé (1 milliard d'essais/seconde)
    double seconds = 1.0 / prob / 1e9;
    double years = seconds / (365.25 * 24 * 3600);
    
    std::cout << "Temps estimé (1G essais/s): " << years << " années" << std::endl;
    std::cout << "Âge de l'univers: ~1.38e10 années" << std::endl;
}

// Estimation génome humain
void estimateGenome() {
    std::cout << "\n==============================================" << std::endl;
    std::cout << "=== Estimation: Génome Humain ===" << std::endl;
    std::cout << "==============================================" << std::endl;
    std::cout << "Taille du génome: 3 milliards de bases (3e9)" << std::endl;
    
    // Probabilité = 1/4^(3e9)
    // Log10(P) = -3e9 * log10(4) = -3e9 * 0.602 ≈ -1.806e9
    double log_prob = -3e9 * log10(4.0);
    
    std::cout << "Probabilité: 1/4^(3e9)" << std::endl;
    std::cout << "Log10(Probabilité): " << log_prob << std::endl;
    std::cout << "\nCe nombre est infiniment plus petit que:" << std::endl;
    std::cout << "  - Nombre d'atomes dans l'univers: ~10^80" << std::endl;
    std::cout << "  - Toute grandeur physique imaginable" << std::endl;
    std::cout << "\n⚠️  CONCLUSION: La génération aléatoire d'un génome" << std::endl;
    std::cout << "   fonctionnel est mathématiquement impossible." << std::endl;
}

int main(int argc, char* argv[]) {
    std::cout << "=====================================" << std::endl;
    std::cout << "=== Simulation Bioinformatique ===" << std::endl;
    std::cout << "=====================================" << std::endl;
    
    if(argc == 1) {
        // Mode séquentiel complet
        int choice;
        std::cout << "\nChoisissez un mode:" << std::endl;
        std::cout << "1. Simulation de séquences courtes (GATTACA, etc.)" << std::endl;
        std::cout << "2. Estimation phrase intelligible" << std::endl;
        std::cout << "3. Estimation génome humain" << std::endl;
        std::cout << "4. Tout exécuter" << std::endl;
        std::cout << "Choix: ";
        std::cin >> choice;
        
        switch(choice) {
            case 1:
                return sequentialMode();
            case 2:
                estimatePhrase();
                return 0;
            case 3:
                estimateGenome();
                return 0;
            case 4:
                sequentialMode();
                estimatePhrase();
                estimateGenome();
                return 0;
            default:
                std::cerr << "Choix invalide" << std::endl;
                return 1;
        }
    } else if(argc == 3) {
        // Mode parallèle
        int statusNum = atoi(argv[1]);
        std::string target = argv[2];
        return parallelMode(statusNum, target);
    } else {
        std::cerr << "Usage:" << std::endl;
        std::cerr << "  " << argv[0] << "              (mode interactif)" << std::endl;
        std::cerr << "  " << argv[0] << " <status> <sequence>  (mode parallèle)" << std::endl;
        return 1;
    }
}
