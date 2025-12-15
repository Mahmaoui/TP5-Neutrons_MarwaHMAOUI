# TP5: Simulation Monte-Carlo 1D de Transport de Neutrons
## Validation de l'Architecture Stochastique Parallèle (Sequence Splitting)

Ce projet implémente une simulation de transport de $30 \times 10^6$ neutrons dans un milieu 1D en utilisant la méthode Monte-Carlo. L'objectif principal est de démontrer la maîtrise du **Sequence Splitting** pour assurer l'indépendance statistique des réplications parallèles et garantir une faible variance.

Le projet a été développé en C++ avec la librairie professionnelle **CLHEP** (CERN Library for High Energy Physics).

---

## Méthodologie et Parallélisme

### 1. Modèle Physique
* **Milieu :** Milieu 1D d'épaisseur $L = 30.0$ et Longueur de Libre Parcours Moyenne $\lambda = 2.86$.
* **Interactions :** Probabilité d'Absorption $P_{abs} = 0.3$, Probabilité de Diffusion $P_{scat} = 0.7$.
* **Objectif :** Estimer le taux de neutrons échappés et absorbés.

### 2. Sequence Splitting (Décorrélation)
La précision est garantie par l'exécution de $N_{rep}=30$ réplications, chacune simulant $10^6$ particules, lancées en parallèle (mode SPMD).

* Le programme `StatusSaver` prépare 30 états initiaux de l'aléatoire.
* Chaque état est avancé de `JUMP_SIZE` $= 10^7$ tirages, garantissant que les séquences aléatoires utilisées par chaque réplication sont **disjointes et statistiquement indépendantes**.

### 3. Architecture Logicielle
Le projet utilise un workflow standard pour la simulation distribuée :

| Composant | Rôle |
| :--- | :--- |
| `src/StatusSaver.cpp` | Générateur maître : Crée les 30 statuts aléatoires (`MTStatus-i`). |
| `src/neutron_simu.cpp` | Programme esclave : Restaure un statut donné et exécute $10^6$ vols de neutrons. |
| `scripts/run_parallel.sh` | Orchestration parallèle (`&` et `wait`) et post-traitement des résultats via `AWK`. |

---

## Résultats Statistiques Clés

Les résultats agrégés proviennent de l'analyse des 30 réplications indépendantes. La faible incertitude confirme la réussite de la technique de Sequence Splitting.

| Grandeur Physique | Estimation Moyenne ($\bar{X}$) | Rayon de Confiance (IC 95\%) | Précision Relative |
| :--- | :--- | :--- | :--- |
| Neutrons Échappés | $4954.47$ | $\pm 23.07$ | $0.47\%$ |
| Neutrons Absorbés | $995045.53$ | $\pm 23.07$ | $< 0.003\%$ |
| Nombre de Rebonds | $1160864.97$ | $\pm 590.85$ | $0.05\%$ |

Le temps d'exécution réel (Wall Clock Time) a été mesuré à **4 secondes** pour les 30 réplications en parallèle.

---

## Reproduction du Projet

### Prérequis
* Compilateur C++ (g++)
* Environnement Linux/Unix (recommandé : Ubuntu)
* Librairie **CLHEP 2.1.0.0** (incluant le module `CLHEP-Random`)
* Outil d'analyse `AWK`

### Compilation et Exécution

La compilation et le lancement de la simulation sont gérés par le `Makefile` pour assurer la reproductibilité et la bonne liaison des librairies CLHEP.

1.  **Compiler les Exécutables :**
    ```bash
    make all
    ```
    *(Ceci crée `bin/StatusSaver` et `bin/simu_parallel`.)*

2.  **Préparer les Statuts Aléatoires (Sequence Splitting) :**
    ```bash
    make prepare
    ```
    *(Ceci exécute `StatusSaver` et crée les 30 fichiers `MTStatus-i` dans le répertoire courant.)*

3.  **Lancer l'Exécution Parallèle et l'Analyse Statistique :**
    ```bash
    make run
    ```
    *(Ceci lance le script `scripts/run_parallel.sh`, qui exécute les 30 simulations en parallèle et affiche le tableau des résultats finaux avec l'IC 95\%.)*

### Documentation
Le rapport technique complet, détaillant la méthodologie, les corrections d'interface CLHEP et l'analyse statistique, se trouve dans le fichier :
[Rapport TP5](rapport_tp5.pdf)

---
*Développé par Marwa HMAOUI. Clermont-Ferrand.*
