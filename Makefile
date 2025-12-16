# Makefile pour TP5 - Simulation Stochastique Parallèle
# Auteur : Marwa HMAOUI - ISIMA ZZ3

# ============================================================================
# CONFIGURATION
# ============================================================================

CXX = g++
CXXFLAGS = -std=c++11 -O3 -Wall
CLHEP_DIR = ./CLHEP
INCLUDES = -I$(CLHEP_DIR)/include
LIBS = -L$(CLHEP_DIR)/lib -lCLHEP-Random-2.1.0.0

# Répertoires
SRCDIR = src
BINDIR = bin
SCRIPTDIR = scripts

# ============================================================================
# CIBLES PRINCIPALES
# ============================================================================

.PHONY: all clean clean_all info test prepare
.PHONY: run_seq_sphere run_seq_neutrons run_par_sphere run_par_neutrons
.PHONY: run_adn run_all benchmark

# Compilation de tous les programmes
all: $(BINDIR)/testStatus $(BINDIR)/statusSaver $(BINDIR)/simu_sphere $(BINDIR)/simu_neutrons $(BINDIR)/simu_adn

# ============================================================================
# COMPILATION DES PROGRAMMES
# ============================================================================

# Créer le répertoire bin si nécessaire
$(BINDIR):
	@mkdir -p $(BINDIR)
	@echo "✓ Répertoire bin/ créé"

# Question 2 : Test de reproductibilité
$(BINDIR)/testStatus: $(SRCDIR)/testStatus.cpp | $(BINDIR)
	@echo "Compilation de testStatus..."
	$(CXX) $(CXXFLAGS) $< $(INCLUDES) $(LIBS) -o $@
	@echo "✓ testStatus compilé"

# Question 4 : Génération des statuts
$(BINDIR)/statusSaver: $(SRCDIR)/statusSaver.cpp | $(BINDIR)
	@echo "Compilation de statusSaver..."
	$(CXX) $(CXXFLAGS) $< $(INCLUDES) $(LIBS) -o $@
	@echo "✓ statusSaver compilé"

# Question 3-N1 : Volume de la sphère
$(BINDIR)/simu_sphere: $(SRCDIR)/simu_sphere.cpp | $(BINDIR)
	@echo "Compilation de simu_sphere..."
	$(CXX) $(CXXFLAGS) $< $(INCLUDES) $(LIBS) -o $@
	@echo "✓ simu_sphere compilé"

# Question 3-N2 : Transport de neutrons
$(BINDIR)/simu_neutrons: $(SRCDIR)/simu_neutrons.cpp | $(BINDIR)
	@echo "Compilation de simu_neutrons..."
	$(CXX) $(CXXFLAGS) $< $(INCLUDES) $(LIBS) -o $@
	@echo "✓ simu_neutrons compilé"

# Question 7 : Bioinformatique (optionnel)
$(BINDIR)/simu_adn: $(SRCDIR)/simu_adn.cpp | $(BINDIR)
	@echo "Compilation de simu_adn..."
	$(CXX) $(CXXFLAGS) $< $(INCLUDES) $(LIBS) -o $@
	@echo "✓ simu_adn compilé"

# ============================================================================
# INFORMATIONS
# ============================================================================

info:
	@echo "=========================================="
	@echo "    Informations Installation CLHEP"
	@echo "=========================================="
	@echo "Répertoire CLHEP : $(CLHEP_DIR)"
	@echo ""
	@echo "Bibliothèques installées :"
	@ls -lh $(CLHEP_DIR)/lib/libCLHEP* 2>/dev/null || echo "⚠ ERREUR: Bibliothèques CLHEP non trouvées!"
	@echo ""
	@echo "Programmes compilés :"
	@ls -lh $(BINDIR)/ 2>/dev/null || echo "Aucun programme compilé"
	@echo ""
	@echo "Statuts générés :"
	@ls MTStatus-* 2>/dev/null | wc -l | xargs echo "Nombre de statuts :"
	@echo "=========================================="

# ============================================================================
# QUESTION 2 : TEST DE REPRODUCTIBILITÉ
# ============================================================================

test: $(BINDIR)/testStatus
	@echo ""
	@echo "=========================================="
	@echo "  Question 2 : Test de Reproductibilité"
	@echo "=========================================="
	@./$(BINDIR)/testStatus
	@echo ""
	@echo "✓ Si les deux séquences de 10 nombres sont identiques,"
	@echo "  la reproductibilité fonctionne correctement!"
	@echo "=========================================="

# ============================================================================
# QUESTION 4 : GÉNÉRATION DES STATUTS
# ============================================================================

prepare: $(BINDIR)/statusSaver
	@echo ""
	@echo "=========================================="
	@echo "  Question 4 : Génération des Statuts"
	@echo "=========================================="
	@./$(BINDIR)/statusSaver
	@echo ""
	@echo "Statuts créés :"
	@ls -lh MTStatus-* 2>/dev/null | head -5
	@echo "..."
	@ls MTStatus-* 2>/dev/null | wc -l | xargs echo "Total :"
	@echo "=========================================="

# ============================================================================
# QUESTION 3 : SIMULATIONS SÉQUENTIELLES
# ============================================================================

run_seq_sphere: $(BINDIR)/simu_sphere
	@echo ""
	@echo "=========================================="
	@echo "  Question 3-N1 : Volume de la Sphère"
	@echo "=========================================="
	@./$(BINDIR)/simu_sphere
	@echo "=========================================="

run_seq_neutrons: $(BINDIR)/simu_neutrons
	@echo ""
	@echo "=========================================="
	@echo "  Question 3-N2 : Transport de Neutrons"
	@echo "=========================================="
	@./$(BINDIR)/simu_neutrons
	@echo "=========================================="

# ============================================================================
# QUESTION 5 : PARALLÉLISATION
# ============================================================================

run_par_sphere: $(BINDIR)/simu_sphere prepare
	@echo ""
	@echo "=========================================="
	@echo "  Question 5 : Parallélisation Sphère"
	@echo "=========================================="
	@if [ ! -f $(SCRIPTDIR)/run_parallel_sphere.sh ]; then \
		echo "⚠ Script $(SCRIPTDIR)/run_parallel_sphere.sh non trouvé!"; \
		echo "Exécution manuelle en parallèle..."; \
		$(MAKE) run_par_sphere_manual; \
	else \
		bash $(SCRIPTDIR)/run_parallel_sphere.sh; \
	fi

run_par_neutrons: $(BINDIR)/simu_neutrons prepare
	@echo ""
	@echo "=========================================="
	@echo "  Question 5 : Parallélisation Neutrons"
	@echo "=========================================="
	@if [ ! -f $(SCRIPTDIR)/run_parallel_neutrons.sh ]; then \
		echo "⚠ Script $(SCRIPTDIR)/run_parallel_neutrons.sh non trouvé!"; \
		echo "Exécution manuelle en parallèle..."; \
		$(MAKE) run_par_neutrons_manual; \
	else \
		bash $(SCRIPTDIR)/run_parallel_neutrons.sh; \
	fi

# Exécution manuelle si script manquant (sphère)
run_par_sphere_manual:
	@rm -f result_sphere_*.txt
	@echo "Lancement de 20 simulations en parallèle (0-19)..."
	@for i in $$(seq 0 19); do \
		./$(BINDIR)/simu_sphere $$i > result_sphere_$$i.txt & \
	done; \
	wait
	@echo "Lancement de 10 simulations en parallèle (20-29)..."
	@for i in $$(seq 20 29); do \
		./$(BINDIR)/simu_sphere $$i > result_sphere_$$i.txt & \
	done; \
	wait
	@echo ""
	@echo "=== Analyse des résultats ==="
	@awk '{sum+=$$1; sumsq+=$$1*$$1} END { \
		mean=sum/NR; \
		var=sumsq/NR-mean*mean; \
		stddev=sqrt(var); \
		ic=1.96*stddev/sqrt(NR); \
		printf "Nombre de réplications : %d\n", NR; \
		printf "Moyenne : %.6f\n", mean; \
		printf "Écart-type : %.6f\n", stddev; \
		printf "IC 95%% : [%.6f, %.6f]\n", mean-ic, mean+ic; \
		printf "Valeur théorique : 4.188790\n"; \
		printf "Erreur relative : %.4f%%\n", abs(mean-4.18879)/4.18879*100; \
	}' result_sphere_*.txt

# Exécution manuelle si script manquant (neutrons)
run_par_neutrons_manual:
	@rm -f result_neutrons_*.txt
	@echo "Lancement de 20 simulations en parallèle (0-19)..."
	@for i in $$(seq 0 19); do \
		./$(BINDIR)/simu_neutrons $$i > result_neutrons_$$i.txt & \
	done; \
	wait
	@echo "Lancement de 10 simulations en parallèle (20-29)..."
	@for i in $$(seq 20 29); do \
		./$(BINDIR)/simu_neutrons $$i > result_neutrons_$$i.txt & \
	done; \
	wait
	@echo ""
	@echo "=== Analyse des résultats ==="
	@awk '{sum_esc+=$$1; sum_abs+=$$2; sum_bounces+=$$3; \
		sumsq_esc+=$$1*$$1; sumsq_abs+=$$2*$$2; sumsq_bounces+=$$3*$$3} \
	END { \
		n=NR; \
		mean_esc=sum_esc/n; mean_abs=sum_abs/n; mean_bounces=sum_bounces/n; \
		std_esc=sqrt(sumsq_esc/n-mean_esc*mean_esc); \
		std_abs=sqrt(sumsq_abs/n-mean_abs*mean_abs); \
		std_bounces=sqrt(sumsq_bounces/n-mean_bounces*mean_bounces); \
		ic_esc=1.96*std_esc/sqrt(n); \
		ic_abs=1.96*std_abs/sqrt(n); \
		ic_bounces=1.96*std_bounces/sqrt(n); \
		printf "Neutrons échappés : %.2f ± %.2f\n", mean_esc, ic_esc; \
		printf "Neutrons absorbés : %.2f ± %.2f\n", mean_abs, ic_abs; \
		printf "Rebonds totaux : %.2f ± %.2f\n", mean_bounces, ic_bounces; \
	}' result_neutrons_*.txt

# ============================================================================
# QUESTION 7 : BIOINFORMATIQUE (OPTIONNEL)
# ============================================================================

run_adn: $(BINDIR)/simu_adn
	@echo ""
	@echo "=========================================="
	@echo "  Question 7 : Bioinformatique"
	@echo "=========================================="
	@./$(BINDIR)/simu_adn
	@echo "=========================================="

# ============================================================================
# WORKFLOW COMPLET
# ============================================================================

run_all: test prepare run_seq_sphere run_par_sphere
	@echo ""
	@echo "=========================================="
	@echo "  ✓ Workflow Complet Terminé"
	@echo "=========================================="
	@echo "Questions exécutées :"
	@echo "  ✓ Q2 : Test reproductibilité"
	@echo "  ✓ Q4 : Génération statuts"
	@echo "  ✓ Q3 : Simulation séquentielle"
	@echo "  ✓ Q5 : Parallélisation"
	@echo "=========================================="

# Comparaison performances séquentiel vs parallèle
benchmark: prepare $(BINDIR)/simu_sphere
	@echo ""
	@echo "=========================================="
	@echo "  Benchmark Séquentiel vs Parallèle"
	@echo "=========================================="
	@echo "Exécution séquentielle (30 réplications)..."
	@time -p bash -c 'for i in $$(seq 0 29); do ./$(BINDIR)/simu_sphere $$i > /dev/null; done' 2>&1 | grep real
	@echo ""
	@echo "Exécution parallèle (2 paquets)..."
	@time -p bash -c 'for i in $$(seq 0 19); do ./$(BINDIR)/simu_sphere $$i > /dev/null & done; wait; \
		for i in $$(seq 20 29); do ./$(BINDIR)/simu_sphere $$i > /dev/null & done; wait' 2>&1 | grep real
	@echo "=========================================="

# ============================================================================
# NETTOYAGE
# ============================================================================

clean:
	@echo "Nettoyage des fichiers temporaires..."
	@rm -f $(BINDIR)/*
	@rm -f result_*.txt
	@rm -f MTStatus-*
	@rm -f status_test.txt
	@echo "✓ Nettoyage terminé"

clean_all: clean
	@echo "Nettoyage complet (+ CLHEP)..."
	@rm -rf CLHEP Random
	@rm -f *.tgz
	@echo "✓ Nettoyage complet terminé"

# ============================================================================
# AIDE
# ============================================================================

help:
	@echo ""
	@echo "=========================================="
	@echo "  Makefile TP5 - Commandes Disponibles"
	@echo "=========================================="
	@echo ""
	@echo "COMPILATION :"
	@echo "  make all              - Compiler tous les programmes"
	@echo "  make info             - Afficher les informations"
	@echo ""
	@echo "EXÉCUTION PAR QUESTION :"
	@echo "  make test             - Q2: Test reproductibilité"
	@echo "  make prepare          - Q4: Générer les 30 statuts"
	@echo "  make run_seq_sphere   - Q3: Volume sphère (séquentiel)"
	@echo "  make run_seq_neutrons - Q3: Neutrons (séquentiel)"
	@echo "  make run_par_sphere   - Q5: Volume sphère (parallèle)"
	@echo "  make run_par_neutrons - Q5: Neutrons (parallèle)"
	@echo "  make run_adn          - Q7: Bioinformatique"
	@echo ""
	@echo "WORKFLOWS :"
	@echo "  make run_all          - Exécuter tout (Q2+Q4+Q5)"
	@echo "  make benchmark        - Comparer séquentiel vs parallèle"
	@echo ""
	@echo "NETTOYAGE :"
	@echo "  make clean            - Nettoyer résultats"
	@echo "  make clean_all        - Tout nettoyer (+ CLHEP)"
	@echo ""
	@echo "=========================================="
