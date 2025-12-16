#!/bin/bash
# Script de parallélisation pour simulation du transport de neutrons
# Question 5 : Parallélisation avec SPMD (Single Program Multiple Data)

N_REP=30
BATCH_SIZE=20

# Fonction pour lancer un paquet de simulations en parallèle
launch_batch() {
    local start=$1
    local end=$2
    
    echo "Lancement du paquet : simulations $start à $end"
    
    for i in $(seq $start $end); do
        ./bin/simu_neutrons $i > result_neutrons_$i.txt &
    done
    
    # Attendre que toutes les tâches du paquet se terminent
    wait
    
    echo "Paquet $start-$end terminé"
}

# Nettoyage des anciens résultats
rm -f result_neutrons_*.txt

echo "=========================================="
echo "Parallélisation - Transport de Neutrons"
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
# Format de sortie : escaped absorbed totalBounces
awk '{
    sum_esc += $1;
    sum_abs += $2;
    sum_bounces += $3;
    sumsq_esc += $1 * $1;
    sumsq_abs += $2 * $2;
    sumsq_bounces += $3 * $3;
} 
END {
    n = NR;
    
    mean_esc = sum_esc / n;
    mean_abs = sum_abs / n;
    mean_bounces = sum_bounces / n;
    
    std_esc = sqrt(sumsq_esc / n - mean_esc * mean_esc);
    std_abs = sqrt(sumsq_abs / n - mean_abs * mean_abs);
    std_bounces = sqrt(sumsq_bounces / n - mean_bounces * mean_bounces);
    
    ic_esc = 1.96 * std_esc / sqrt(n);
    ic_abs = 1.96 * std_abs / sqrt(n);
    ic_bounces = 1.96 * std_bounces / sqrt(n);
    
    printf "Nombre de réplications : %d\n", n;
    printf "\nNeutrons échappés : %.2f ± %.2f\n", mean_esc, ic_esc;
    printf "Neutrons absorbés : %.2f ± %.2f\n", mean_abs, ic_abs;
    printf "Rebonds totaux : %.2f ± %.2f\n", mean_bounces, ic_bounces;
}' result_neutrons_*.txt

echo ""
echo "Résultats individuels sauvegardés dans result_neutrons_*.txt"
