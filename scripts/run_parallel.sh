#!/bin/bash
# ----------------------------------------------------------------------
# Script d'exécution parallèle (SPMD) et de calcul de l'Intervalle de Confiance.
# ----------------------------------------------------------------------

# Variables d'exécution
NUM_REPLICATIONS=30
EXEC_SIMU="./bin/simu_parallel"

echo "Lancement des $NUM_REPLICATIONS réplications en parallèle (SPMD)..."
mkdir -p Results

START_TIME=$(date +%s)

# Lancement des réplications en tâche de fond
for i in $(seq 1 $NUM_REPLICATIONS); do
    STATUS_FILE="MTStatus-$i"
    OUTPUT_FILE="Results/Simu-$i.out"
    
    # Lancement en tâche de fond (&)
    "$EXEC_SIMU" "$STATUS_FILE" "$i" > "$OUTPUT_FILE" & 
done

# Attendre la fin de tous les processus
wait

END_TIME=$(date +%s)
ELAPSED_TIME=$((END_TIME - START_TIME))

echo "----------------------------------------------------"
echo "Toutes les $NUM_REPLICATIONS réplications sont terminées."
echo "Temps réel écoulé (Wall Clock Time): $ELAPSED_TIME secondes."
echo "----------------------------------------------------"

# --- Agrégation des résultats et calcul des statistiques (Question 3) ---

echo "Calcul des moyennes et des rayons de confiance (Intervalle de Confiance 95%)..."

# Création d'un fichier temporaire contenant les données brutes
cat Results/Simu-*.out > Results/all_data.tmp

awk -v N="$NUM_REPLICATIONS" '
BEGIN { 
    Z_SCORE = 2.0; 
}
{
    sum_esc += $2; 
    sum_abs += $3;
    sum_bounces += $4;
    
    data_esc[NR] = $2; 
    data_abs[NR] = $3;
    data_bounces[NR] = $4;
}
END {
    # 1. Calcul des Moyennes
    avg_esc = sum_esc / N;
    avg_abs = sum_abs / N;
    avg_bounces = sum_bounces / N;
    
    # 2. Calcul de la Somme des Carrés des Déviations (utiliser la multiplication simple)
    sum_sq_dev_esc = 0;
    sum_sq_dev_abs = 0;
    sum_sq_dev_bounces = 0;
    
    for (i = 1; i <= N; i++) {
        # Utilisation de (x * x) pour la robustesse
        sum_sq_dev_esc += (data_esc[i] - avg_esc) * (data_esc[i] - avg_esc);
        sum_sq_dev_abs += (data_abs[i] - avg_abs) * (data_abs[i] - avg_abs);
        sum_sq_dev_bounces += (data_bounces[i] - avg_bounces) * (data_bounces[i] - avg_bounces);
    }
    
    # 3. Calcul de l\Écart-Type du Cample (std_dev = sqrt(somme_sq_dev / (N-1)))
    std_dev_esc = sqrt(sum_sq_dev_esc / (N - 1));
    std_dev_abs = sqrt(sum_sq_dev_abs / (N - 1));
    std_dev_bounces = sqrt(sum_sq_dev_bounces / (N - 1));
    
    # 4. Calcul du Rayon de Confiance (IC = Z * (std_dev / sqrt(N)))
    ic_esc = Z_SCORE * (std_dev_esc / sqrt(N));
    ic_abs = Z_SCORE * (std_dev_abs / sqrt(N));
    ic_bounces = Z_SCORE * (std_dev_bounces / sqrt(N));

    printf("Resultats Finaux (Intervalle de Confiance 95%%):\n");
    printf("  Neutrons ECHAPPES: %.2f +/- %.2f\n", avg_esc, ic_esc);
    printf("  Neutrons ABSORBES: %.2f +/- %.2f\n", avg_abs, ic_abs);
    printf("  Nombre de REBONDS: %.2f +/- %.2f\n", avg_bounces, ic_bounces);

}' Results/all_data.tmp

rm Results/all_data.tmp 