#!/bin/bash
# Script d'exécution séquentielle pour mesurer le temps de référence
# Question 4 : Mesure du temps séquentiel

N_REP=30

# Nettoyage des anciens résultats
rm -f result_sphere_*.txt

echo "=========================================="
echo "Exécution Séquentielle - Volume de la Sphère"
echo "=========================================="
echo "Nombre de réplications : $N_REP"
echo ""

# Mesure du temps séquentiel
time {
    for i in $(seq 0 $((N_REP-1))); do
        echo "Exécution de la réplication $i..."
        ./bin/simu_sphere $i > result_sphere_$i.txt
    done
}

echo ""
echo "=========================================="
echo "Analyse statistique des résultats"
echo "=========================================="

# Analyse des résultats
awk '{
    sum += $1;
    sumsq += $1 * $1;
} 
END {
    mean = sum / NR;
    variance = sumsq / NR - mean * mean;
    stddev = sqrt(variance);
    ic = 1.96 * stddev / sqrt(NR);
    
    printf "Nombre de réplications : %d\n", NR;
    printf "Moyenne : %.6f\n", mean;
    printf "Écart-type : %.6f\n", stddev;
    printf "IC 95%% : [%.6f, %.6f]\n", mean - ic, mean + ic;
    printf "Rayon de confiance : ± %.6f\n", ic;
    printf "Valeur théorique : 4.188790\n";
    printf "Erreur relative : %.4f%%\n", (mean - 4.18879) / 4.18879 * 100;
}' result_sphere_*.txt
