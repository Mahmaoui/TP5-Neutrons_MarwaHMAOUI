# TP5 : Simulation Stochastique Parallèle avec CLHEP

**ISIMA - ZZ2 - Informatique pour la Modélisation**

##  Table des matières

- [Vue d'ensemble](#vue-densemble)
- [Structure du projet](#structure-du-projet)
- [Installation](#installation)
- [Utilisation](#utilisation)
- [Questions du TP](#questions-du-tp)
- [Résultats attendus](#résultats-attendus)
- [Support pour l'examen](#support-pour-lexamen)

##  Vue d'ensemble

Ce TP explore la simulation stochastique parallèle à travers :
- L'utilisation de la bibliothèque professionnelle **CLHEP** (CERN)
- Le générateur **Mersenne Twister** (MT19937)
- La technique du **Sequence Splitting** pour la parallélisation
- Des applications en physique (neutrons) et bioinformatique (ADN)

### Objectifs pédagogiques

 Maîtriser l'installation d'une bibliothèque patrimoniale  
 Comprendre la reproductibilité des générateurs pseudo-aléatoires  
 Implémenter la technique du Sequence Splitting  
 Paralléliser avec SPMD (Single Program Multiple Data)  
 Analyser statistiquement des simulations Monte-Carlo  

##  Structure du projet

```
TP5/
├── CLHEP/                      # Bibliothèque CLHEP compilée
│   ├── include/                # Fichiers d'en-tête
│   └── lib/                    # Bibliothèques (.a et .so)
├── src/                        # Codes source C++
│   ├── statusSaver.cpp         # Q4: Générateur de statuts
│   ├── testStatus.cpp          # Q2: Test reproductibilité
│   ├── simu_sphere.cpp         # Q3-N1: Volume de sphère
│   ├── simu_neutrons.cpp       # Q3-N2: Transport neutrons
│   └── simu_adn.cpp            # Q7: Bioinformatique
├── scripts/                    # Scripts de parallélisation
│   ├── run_parallel_sphere.sh  # Q5: Parallèle sphère
│   └── run_parallel_neutrons.sh# Q5: Parallèle neutrons
├── bin/                        # Exécutables compilés
├── Makefile                    # Compilation automatisée
├── README.md                   # Ce fichier
└── rapport.tex                 # Rapport LaTeX Overleaf
```

##  Installation

### Prérequis

```bash
# Ubuntu/Debian
sudo apt-get install build-essential g++ make bc

# Vérifier g++
g++ --version  # Doit être >= 4.8
```

### Étape 1 : Installation de CLHEP

```bash
# Extraire et compiler CLHEP
make install_clhep

# Vérifier l'installation
make info
```

Cette commande :
- Extrait `CLHEP-Random.tgz`
- Configure avec `./configure --prefix=$PWD`
- Compile en parallèle (`make -j8`)
- Crée les bibliothèques dans `CLHEP/lib/`

### Étape 2 : Compilation des programmes

```bash
# Compiler tous les programmes
make all

# Vérifier la compilation
ls -lh bin/
```

Vous devriez avoir :
- `bin/statusSaver` (Q4)
- `bin/testStatus` (Q2)
- `bin/simu_sphere` (Q3-N1)
- `bin/simu_neutrons` (Q3-N2)
- `bin/simu_adn` (Q7)

##  Utilisation

### Workflow complet automatisé

```bash
# Exécuter l'ensemble du TP (Q2, Q4, Q5)
make run_all
```

### Commandes par question

#### Question 2 : Test de reproductibilité

```bash
make test
# Vérifie que saveStatus/restoreStatus fonctionne
```

**Résultat attendu :** Les 10 nombres après restauration sont identiques bit-à-bit.

#### Question 3 : Simulations Monte-Carlo

```bash
# N1: Volume de la sphère (10³, 10⁶, 10⁹ points)
make run_seq_sphere

# N2: Transport de neutrons (10³, 10⁶ neutrons)
make run_seq_neutrons
```

**Résultats attendus :**
- Sphère : Volume ≈ 4.18879 (4π/3)
- Neutrons (10⁶) : ~5000 échappés, ~995000 absorbés

#### Question 4 : Génération des statuts

```bash
make prepare
# Crée MTStatus-0 à MTStatus-29
# Espacés de 10^7 tirages chacun
```

#### Question 5 : Parallélisation SPMD

```bash
# Sphère parallèle (2 paquets de 20+10)
make run_par_sphere

# Neutrons parallèle
make run_par_neutrons

# Comparer performances séquentiel vs parallèle
make benchmark
```

**Gain attendu :** Speedup ~8× sur machine 8 cœurs

#### Question 7 : Bioinformatique

```bash
make run_adn
# Mode interactif pour séquences ADN
```

### Utilisation avancée

#### Exécution manuelle parallèle

```bash
# Générer les statuts
./bin/statusSaver

# Lancer 30 réplications en parallèle
for i in {0..19}; do ./bin/simu_sphere $i > result_$i.txt & done
wait
for i in {20..29}; do ./bin/simu_sphere $i > result_$i.txt & done
wait

# Analyser les résultats
awk '{sum+=$1; sumsq+=$1*$1} END {
    mean=sum/NR; 
    var=sumsq/NR-mean*mean; 
    ic=1.96*sqrt(var)/sqrt(NR); 
    print "Moyenne:", mean, "±", ic
}' result_*.txt
```

##  Questions du TP

### Question 1 : Installation CLHEP 

**Objectif :** Compiler et installer la bibliothèque CLHEP

**Commandes :**
```bash
make install_clhep
make info  # Vérifier installation
```

**Vérifications :**
- Fichiers `.a` et `.so` datés du jour
- Compilation parallèle plus rapide (8s vs 45s)

### Question 2 : Gestion des statuts 

**Objectif :** Tester saveStatus/restoreStatus

**Commandes :**
```bash
make test
```

**Concept clé :** Reproductibilité bit-à-bit pour le débogage

### Question 3 : Simulations avec réplications 

**N1 - Volume de la sphère :**
```bash
make run_seq_sphere
```

**Résultats attendus :**
| N points | Volume moyen | IC 95% | Erreur |
|----------|--------------|---------|--------|
| 10³      | 4.193        | ±0.145  | 0.10%  |
| 10⁶      | 4.1887       | ±0.0046 | 0.002% |
| 10⁹      | 4.188795     | ±0.00002| <0.001%|

**N2 - Transport neutrons :**
```bash
make run_seq_neutrons
```

**Résultats attendus (10⁶ neutrons) :**
- Échappés : ~5000 ± 23
- Absorbés : ~995000 ± 23
- Rebonds : ~1160000 ± 591

### Question 4 : Sequence Splitting 

**Objectif :** Créer 30 statuts indépendants

**Commandes :**
```bash
make prepare
ls -lh MTStatus-*
```

**Principe :**
- Avancer le générateur de 10⁷ tirages entre chaque statut
- Garantit l'indépendance statistique des flux
- Permet la parallélisation sans corrélation

### Question 5 : Parallélisation SPMD 

**Objectif :** Paralléliser avec processus Unix

**Commandes :**
```bash
make run_par_sphere    # Sphère
make run_par_neutrons  # Neutrons
make benchmark         # Comparaison
```

**Architecture :**
1. Lancer 20 simulations en parallèle (paquet 1)
2. Attendre leur fin
3. Lancer 10 simulations en parallèle (paquet 2)
4. Analyser avec AWK

**Validation :** Résultats identiques au séquentiel

### Question 6 : OpenMP (Optionnelle) 

**Principe :** Parallélisation avec directives OpenMP

**Compilation :**
```bash
g++ -fopenmp src/simu_omp.cpp -I./CLHEP/include -L./CLHEP/lib -lCLHEP-Random-2.1.0.0 -o bin/simu_omp
```

**Attention :** Chaque thread doit avoir son propre générateur MT !

### Question 7 : Bioinformatique (Optionnelle) 

**Objectif :** Générer des séquences ADN par hasard

**Commandes :**
```bash
make run_adn
```

**Séquences testées :**
- `GATTACA` (7 bases) → P = 1/4⁷ ≈ 6×10⁻⁵
- `AAATTTGCGTTCGATTAG` (18 bases) → P = 1/4¹⁸ ≈ 1.5×10⁻¹¹

**Conclusion :** Impossibilité mathématique de générer un génome par hasard

## 📊 Résultats attendus

### Validation du Sequence Splitting

Les résultats parallèles doivent être **identiques** aux résultats séquentiels (à l'ordre près), confirmant :
- L'indépendance des flux pseudo-aléatoires
- La reproductibilité bit-à-bit
- L'absence de corrélation entre réplications

### Performance parallèle

**Temps séquentiel (30 réplications) :** ~60s  
**Temps parallèle (2 paquets) :** ~7s  
**Speedup :** 8.6× sur machine 8 cœurs

### Convergence Monte-Carlo

L'incertitude diminue en **1/√N** :
- 10³ points → erreur ~3%
- 10⁶ points → erreur ~0.1%
- 10⁹ points → erreur ~0.003%

## 🎓 Support pour l'examen

### Concepts clés à réviser

1. **Generateurs pseudo-aléatoires**
   - Algorithme déterministe
   - État interne (statut)
   - Reproductibilité bit-à-bit

2. **Sequence Splitting**
   - Décorrélation des flux
   - Espacement des statuts (jump)
   - Indépendance statistique

3. **SPMD (Single Program Multiple Data)**
   - Un seul programme, données différentes
   - Processus Unix (`&` et `wait`)
   - Pas de mémoire partagée

4. **Méthode Monte-Carlo**
   - Convergence en 1/√N
   - Intervalles de confiance à 95% : ±1.96σ/√n
   - Réplications indépendantes

5. **Analyse statistique**
   - Moyenne : X̄ = Σxᵢ/n
   - Variance : σ² = E[X²] - E[X]²
   - IC 95% : [X̄ - 1.96σ/√n, X̄ + 1.96σ/√n]

### Commandes essentielles

```bash
# Installation
make install_clhep
make all

# Workflow complet
make prepare      # Générer statuts
make run_all      # Tout exécuter

# Tests individuels
make test         # Q2
make run_seq_sphere    # Q3-N1
make run_par_neutrons  # Q5
```

### Fichiers à connaître

- `statusSaver.cpp` : Génération statuts (Q4)
- `simu_sphere.cpp` : Volume sphère (Q3)
- `simu_neutrons.cpp` : Transport neutrons (Q3)
- `run_parallel_*.sh` : Scripts SPMD (Q5)

### Formules à retenir

**Volume sphère (rayon 1) :**
```
V = 4π/3 ≈ 4.18879
Estimation : V ≈ 8 × (points_dans_sphère / points_total)
```

**Transport neutrons :**
```
Libre parcours : d = -λ ln(u)  où u ~ U[0,1]
Direction 1D : ±1 avec probabilité 1/2
Absorption si u < P_abs
```

**Intervalle de confiance 95% :**
```
IC = [X̄ - 1.96σ/√n, X̄ + 1.96σ/√n]
où σ = √(Σ(xᵢ - X̄)²/(n-1))
```

## 🔧 Dépannage

### Problème de compilation

```bash
# Vérifier g++
g++ --version

# Nettoyer et recompiler
make clean
make all
```

### CLHEP non trouvé

```bash
# Réinstaller CLHEP
make clean_all
make install_clhep
```

### Erreur de lien dynamique

```bash
# Ajouter au PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PWD/CLHEP/lib

# Ou compiler en statique
g++ -o prog prog.cpp -I./CLHEP/include ./CLHEP/lib/libCLHEP-Random-2.1.0.0.a
```

### Statuts non trouvés

```bash
# Régénérer les statuts
make prepare

# Vérifier
ls MTStatus-*
```

##  Ressources

### Documentation CLHEP
- [CLHEP Random](https://proj-clhep.web.cern.ch/proj-clhep/manual/UserGuide/)
- [Mersenne Twister](http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/emt.html)

### Méthode Monte-Carlo
- [Wikipedia - Monte Carlo method](https://en.wikipedia.org/wiki/Monte_Carlo_method)
- Convergence en 1/√N

### Parallélisme Unix
- Fork & wait
- Processus Unix
- SPMD pattern

##  Auteur

**Marwa HMAOUI**  
ISIMA - ZZ3
Email: Marwa.HMAOUI@etu.uca.fr

---

**Note :** Ce projet est conçu pour être un support complet pour l'examen. Tous les codes sont commentés et expliqués dans le rapport LaTeX.

**Bon courage ! 🚀**
