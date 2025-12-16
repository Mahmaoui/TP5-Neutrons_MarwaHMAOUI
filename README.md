# TP5 : Simulation Stochastique Parallèle avec CLHEP

**ISIMA - ZZ3 - Informatique pour la Modélisation**

---

##  Vue d'ensemble

Ce TP explore la simulation Monte-Carlo parallèle avec :
- Bibliothèque professionnelle **CLHEP** (CERN)
- Générateur **Mersenne Twister** (MT19937)
- Technique du **Sequence Splitting**
- Parallélisation avec processus Unix (SPMD)

---

##  Structure du Projet

```
TP5/
├── CLHEP-Random.tgz          # Archive CLHEP (fournie)
├── src/                       # Codes sources C++
│   ├── testStatus.cpp         # Q2: Test reproductibilité
│   ├── statusSaver.cpp        # Q4: Génération statuts
│   ├── simu_sphere.cpp        # Q3-N1: Volume sphère
│   ├── simu_neutrons.cpp      # Q3-N2: Transport neutrons
│   └── simu_adn.cpp           # Q7: Bioinformatique (optionnel)
├── scripts/
│   ├── run_sequential_sphere.sh    # Q4: Exécution séquentielle
│   ├── run_parallel_sphere.sh      # Q5: Parallélisation
│   └── run_parallel_neutrons.sh    # Q5: Parallélisation neutrons
├── bin/                       # Exécutables (créé automatiquement)
├── CLHEP/                     # Bibliothèque (créée après installation)
├── Makefile
└── README.md
```

---

##  Installation et Compilation

### Étape 1 : Installer CLHEP

```bash
# Extraire l'archive
tar zxvf CLHEP-Random.tgz

# Aller dans le répertoire créé
cd Random

# Configuration
./configure --prefix=$PWD

# Compilation parallèle (ajuster selon vos cœurs)
time make -j8

# Installation
make install

# Retour au répertoire principal
cd ..
```

**Vérification :**
```bash
ls -lh CLHEP/lib/
# Vous devez voir : libCLHEP-Random-2.1.0.0.a et libCLHEP-Random-2.1.0.0.so
```

### Étape 2 : Compiler les Programmes

```bash
# Créer les répertoires nécessaires
mkdir -p bin

# Compiler tous les programmes
make all

# Vérifier la compilation
ls -lh bin/
```

**Programmes créés :**
- `bin/testStatus` - Test de reproductibilité
- `bin/statusSaver` - Génération des statuts MT
- `bin/simu_sphere` - Simulation volume sphère
- `bin/simu_neutrons` - Simulation transport neutrons
- `bin/simu_adn` - Génération séquences ADN (optionnel)

---

##  Exécution des Questions

### Question 1 : Installation de CLHEP

 Déjà fait à l'étape d'installation ci-dessus

**Commandes utiles :**
```bash
# Voir les informations d'installation
make info

# Temps de compilation séquentielle vs parallèle
time make clean && time make      # Séquentiel (~45s)
time make clean && time make -j8  # Parallèle (~8s)
```

---

### Question 2 : Test de Reproductibilité

```bash
make test
```

**Ce qui est testé :**
- Génération de 5 nombres aléatoires
- Sauvegarde du statut avec `saveStatus()`
- Génération de 10 nombres supplémentaires
- Restauration du statut avec `restoreStatus()`
- Re-génération des mêmes 10 nombres (bit-à-bit identiques)

**Résultat attendu :**
```
=== Séquence initiale ===
0.417022
0.720324
...

=== 10 nombres suivants ===
0.000114
0.302333
...

=== Après restauration (identique) ===
0.000114    ← Identique !
0.302333    ← Identique !
...
```

---

### Question 3 : Simulations Monte-Carlo avec Réplications

#### N1 - Volume de la Sphère

```bash
make run_seq_sphere
```

**Principe :** Estimer le volume d'une sphère de rayon 1 par méthode de rejet
- Générer des points dans un cube [-1,1]³
- Compter ceux dans la sphère (x²+y²+z² ≤ 1)
- Volume estimé = 8 × (points_intérieur / points_total)

**Résultats attendus :**

| N points | Volume moyen | IC 95%     | Erreur    |
|----------|--------------|------------|-----------|
| 10³      | ~4.193       | ±0.145     | 0.10%     |
| 10⁶      | ~4.1887      | ±0.0046    | 0.002%    |
| 10⁹      | ~4.188795    | ±0.000015  | <0.001%   |

Valeur théorique : **4π/3 ≈ 4.18879**

#### N2 - Transport de Neutrons

```bash
make run_seq_neutrons
```

**Modèle physique 1D :**
- Épaisseur du milieu : L = 30
- Libre parcours moyen : λ = 2.86
- Probabilité d'absorption : P_abs = 0.3

**Résultats attendus (10⁶ neutrons) :**
```
Échappés : ~5000 ± 23
Absorbés : ~995000 ± 23
Rebonds : ~1160000 ± 591
```

---

### Question 4 : Sequence Splitting

```bash
make prepare
```

**Ce qui est fait :**
- Génération de 30 statuts du générateur MT
- Chaque statut est séparé de 10⁷ tirages
- Sauvegarde dans `MTStatus-0` à `MTStatus-29`

**Vérification :**
```bash
ls MTStatus-* | wc -l
# Doit afficher : 30

ls -lh MTStatus-* | head -5
# Voir les 5 premiers statuts
```

**Temps séquentiel :** Mesurer le temps pour 30 réplications
```bash
bash scripts/run_sequential_sphere.sh
```

---

### Question 5 : Parallélisation SPMD

#### Sphère en Parallèle

```bash
make run_par_sphere
```

**Stratégie :**
- Paquet 1 : Lancer 20 simulations en parallèle (statuts 0-19)
- Attendre la fin du paquet
- Paquet 2 : Lancer 10 simulations en parallèle (statuts 20-29)
- Analyser les résultats avec AWK

**Résultats attendus :**
```
=== Parallélisation - Volume de la Sphère ===
Lancement du paquet : simulations 0 à 19
Paquet 0-19 terminé
Lancement du paquet : simulations 20 à 29
Paquet 20-29 terminé

real    0m7.123s    ← Temps réel parallèle
user    0m54.876s
sys     0m0.234s

=== Analyse statistique ===
Moyenne : 4.188876
IC 95% : [4.187140, 4.190612]
```

**Gain de performance :**
- Temps séquentiel : ~60s
- Temps parallèle : ~7s
- **Speedup : 8.6×** (sur machine 8 cœurs)

#### Neutrons en Parallèle

```bash
make run_par_neutrons
```

Même principe que pour la sphère, appliqué à la simulation de neutrons.

---

### Question 6 : OpenMP (Optionnel)

Utilisation d'OpenMP au lieu de processus Unix pour la parallélisation.

**Principe :** Chaque thread doit avoir son propre générateur MT !

```cpp
#pragma omp parallel for
for (int i = 0; i < N_REP; i++) {
    CLHEP::MTwistEngine mt;
    mt.restoreStatus("MTStatus-" + to_string(i));
    results[i] = estimateSpherVolume(1000000, &mt);
}
```

---

### Question 7 : Bioinformatique (Optionnel)

```bash
make run_adn
```

**Principe :** Générer une séquence ADN par tirages aléatoires
- 4 bases possibles : A, C, G, T
- Probabilité uniforme : 1/4 pour chaque base
- Compter les essais pour obtenir une séquence cible

**Séquence testée :** `AAATTTGCGTTCGATTAG` (18 bases)

**Probabilité théorique :** 1/4¹⁸ ≈ 1.46 × 10⁻¹¹

**Résultats attendus :**
```
Cible : AAATTTGCGTTCGATTAG (longueur : 18)
Rep 1 : 68451237856 essais
Rep 2 : 72384957123 essais
...
Moyenne : ~68719476736 ± ... essais
Probabilité estimée : 1/68719476736
```

**Extension génome humain :**
- 3 milliards de bases
- Probabilité : 1/4³⁰⁰⁰⁰⁰⁰⁰⁰⁰ ≈ 10⁻¹·⁸ˣ¹⁰⁹
- Infiniment plus petit que 1/(atomes dans l'univers) ≈ 10⁻⁸⁰

---

##  Makefile - Commandes Disponibles

```bash
make all              # Compiler tous les programmes
make info             # Afficher infos installation
make test             # Question 2 : Test reproductibilité
make prepare          # Question 4 : Générer les 30 statuts
make run_seq_sphere   # Question 3 : Volume sphère séquentiel
make run_seq_neutrons # Question 3 : Neutrons séquentiel
make run_par_sphere   # Question 5 : Volume sphère parallèle
make run_par_neutrons # Question 5 : Neutrons parallèle
make run_adn          # Question 7 : Bioinformatique
make run_all          # Exécuter tout le workflow (Q2, Q4, Q5)
make clean            # Nettoyer les résultats
make clean_all        # Tout nettoyer (+ CLHEP)
```

---

##  Validation des Résultats

### Critères de Réussite

 **Question 2 :** Les 10 nombres après restauration sont identiques bit-à-bit

 **Question 3 :** 
- Volume sphère : 4.188 ± 0.005 (pour N=10⁶)
- Convergence en 1/√N observée

 **Question 4 :** 30 fichiers `MTStatus-*` créés

 **Question 5 :** 
- Résultats parallèles **identiques** aux résultats séquentiels
- Speedup proche du nombre de cœurs (8× pour 8 cœurs)

---

##  Concepts Clés

**Générateur Pseudo-Aléatoire :**
- Algorithme déterministe
- État interne (statut) sauvegardable/restaurable
- Reproductibilité bit-à-bit

**Sequence Splitting :**
- Technique pour paralléliser des simulations stochastiques
- Crée des flux indépendants de nombres aléatoires
- Garantit l'absence de corrélation entre réplications

**SPMD (Single Program Multiple Data) :**
- Un seul programme lancé plusieurs fois
- Chaque instance utilise des données différentes (statut MT différent)
- Parallélisme par processus Unix (`&` et `wait`)

**Convergence Monte-Carlo :**
- Incertitude diminue en 1/√N
- Intervalle de confiance 95% : [X̄ - 1.96σ/√n, X̄ + 1.96σ/√n]

---

##  Auteur

**Marwa HMAOUI**  
ISIMA - ZZ3  
16 décembre 2025
