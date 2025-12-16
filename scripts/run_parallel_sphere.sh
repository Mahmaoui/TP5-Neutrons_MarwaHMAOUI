#!/bin/bash
# Script de parallélisation pour simulation du volume de la sphère
# Question 5 : Parallélisation avec SPMD (Single Program Multiple Data)

N_REP=30
BATCH_SIZE=20

# Fonction pour lancer un paquet de simulations en parallèle
launch_batch() {
    local start=$1
    local end=$2
    
    echo "Lancement du paquet : simulations $start à $end"
    
    for i in $(seq $start $end); do
        ./bin/simu_sphere $i > result_sphere_$i.txt &
    done
    
    # Attendre que toutes les tâches du paquet se terminent
    wait
    
    echo "Paquet $start-$end terminé"
}

# Nettoyage des anciens résultats
rm -f result_sphere_*.txt

echo "=========================================="
echo "Parallélisation - Volume de la Sphère"
echo "=========================================="
echo "Nombre total de réplications : $N_REP"
echo "Taille des paquets : $BATCH_SIZE"
echo ""

# Mesure du temps total
time {
    # Premier paquet (0-19)
    launch_batch 0 19
    
    # Deuxième paquet (20-29)
    launch_batch 20 29
}

echo ""
echo "=========================================="
echo "Analyse statistique des résultats"
echo "=========================================="

# Analyse des résultats avec awk
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

echo ""
echo "Résultats individuels sauvegardés dans result_sphere_*.txt"
