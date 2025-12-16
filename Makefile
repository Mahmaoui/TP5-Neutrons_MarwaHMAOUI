# Makefile pour TP5 - Simulation Stochastique Parallèle


# Variables de compilation
CXX = g++
CXXFLAGS = -std=c++11 -O3 -Wall
CLHEP_DIR = ./CLHEP
INCLUDES = -I$(CLHEP_DIR)/include
LIBS = -L$(CLHEP_DIR)/lib -lCLHEP-Random-2.1.0.0

# Répertoires
SRC_DIR = src
BIN_DIR = bin
SCRIPT_DIR = scripts

# Cibles principales
TARGETS = $(BIN_DIR)/testStatus \
          $(BIN_DIR)/statusSaver \
          $(BIN_DIR)/simu_sphere \
          $(BIN_DIR)/simu_neutrons \
          $(BIN_DIR)/simu_adn

# Règle par défaut
all: directories $(TARGETS)

# Création des répertoires nécessaires
directories:
	@mkdir -p $(BIN_DIR)

# Question 2 : Test des statuts
$(BIN_DIR)/testStatus: $(SRC_DIR)/testStatus.cpp
	$(CXX) $(CXXFLAGS) $< $(INCLUDES) $(LIBS) -o $@

# Question 4 : Générateur de statuts
$(BIN_DIR)/statusSaver: $(SRC_DIR)/statusSaver.cpp
	$(CXX) $(CXXFLAGS) $< $(INCLUDES) $(LIBS) -o $@

# Question 3-5 : Simulation du volume de la sphère
$(BIN_DIR)/simu_sphere: $(SRC_DIR)/simu_sphere.cpp
	$(CXX) $(CXXFLAGS) $< $(INCLUDES) $(LIBS) -o $@

# Question 3-5 : Simulation du transport de neutrons
$(BIN_DIR)/simu_neutrons: $(SRC_DIR)/simu_neutrons.cpp
	$(CXX) $(CXXFLAGS) $< $(INCLUDES) $(LIBS) -o $@

# Question 7 : Simulation ADN
$(BIN_DIR)/simu_adn: $(SRC_DIR)/simu_adn.cpp
	$(CXX) $(CXXFLAGS) $< $(INCLUDES) $(LIBS) -o $@

# Rendre les scripts exécutables
scripts_exec:
	@chmod +x $(SCRIPT_DIR)/*.sh
	@echo "Scripts rendus exécutables"

# Question 4 : Génération des statuts (à faire une seule fois)
prepare: $(BIN_DIR)/statusSaver
	@echo "=========================================="
	@echo "Génération des 30 statuts MT..."
	@echo "=========================================="
	./$(BIN_DIR)/statusSaver
	@echo ""
	@echo "Statuts générés avec succès !"

# Question 2 : Test de reproductibilité
test_status: $(BIN_DIR)/testStatus
	@echo "=========================================="
	@echo "Test de reproductibilité des statuts"
	@echo "=========================================="
	./$(BIN_DIR)/testStatus

# Question 3 : Simulation séquentielle sphère (mode sans argument)
test_sphere_seq: $(BIN_DIR)/simu_sphere
	@echo "=========================================="
	@echo "Simulation séquentielle - Volume sphère"
	@echo "=========================================="
	./$(BIN_DIR)/simu_sphere

# Question 3 : Simulation séquentielle neutrons (mode sans argument)
test_neutrons_seq: $(BIN_DIR)/simu_neutrons
	@echo "=========================================="
	@echo "Simulation séquentielle - Transport neutrons"
	@echo "=========================================="
	./$(BIN_DIR)/simu_neutrons

# Question 4 : Exécution séquentielle avec sequence splitting
run_seq_sphere: $(BIN_DIR)/simu_sphere prepare scripts_exec
	@echo "=========================================="
	@echo "Exécution séquentielle avec statuts"
	@echo "=========================================="
	@bash $(SCRIPT_DIR)/run_sequential_sphere.sh

# Question 5 : Exécution parallèle sphère
run_parallel_sphere: $(BIN_DIR)/simu_sphere prepare scripts_exec
	@echo "=========================================="
	@echo "Exécution parallèle - Volume sphère"
	@echo "=========================================="
	@bash $(SCRIPT_DIR)/run_parallel_sphere.sh

# Question 5 : Exécution parallèle neutrons
run_parallel_neutrons: $(BIN_DIR)/simu_neutrons prepare scripts_exec
	@echo "=========================================="
	@echo "Exécution parallèle - Transport neutrons"
	@echo "=========================================="
	@bash $(SCRIPT_DIR)/run_parallel_neutrons.sh

# Question 7 : Simulation ADN séquentielle
test_adn: $(BIN_DIR)/simu_adn
	@echo "=========================================="
	@echo "Simulation bioinformatique - Séquence ADN"
	@echo "=========================================="
	./$(BIN_DIR)/simu_adn

# Nettoyage
clean:
	rm -f $(BIN_DIR)/*
	rm -f result_*.txt
	rm -f status_test.txt
	@echo "Nettoyage effectué"

# Nettoyage complet (y compris les statuts MT)
cleanall: clean
	rm -f MTStatus-*
	@echo "Nettoyage complet effectué"

# Aide
help:
	@echo "=========================================="
	@echo "Makefile TP5 - Simulation Stochastique"
	@echo "=========================================="
	@echo ""
	@echo "Cibles disponibles :"
	@echo "  make all                  - Compile tous les programmes"
	@echo "  make prepare              - Génère les 30 statuts MT (Question 4)"
	@echo ""
	@echo "Tests individuels :"
	@echo "  make test_status          - Test reproductibilité (Question 2)"
	@echo "  make test_sphere_seq      - Simulation sphère séquentielle (Question 3)"
	@echo "  make test_neutrons_seq    - Simulation neutrons séquentielle (Question 3)"
	@echo "  make test_adn             - Simulation ADN (Question 7)"
	@echo ""
	@echo "Exécutions avec sequence splitting :"
	@echo "  make run_seq_sphere       - Exécution séquentielle sphère (Question 4)"
	@echo "  make run_parallel_sphere  - Exécution parallèle sphère (Question 5)"
	@echo "  make run_parallel_neutrons- Exécution parallèle neutrons (Question 5)"
	@echo ""
	@echo "Nettoyage :"
	@echo "  make clean                - Supprime les binaires et résultats"
	@echo "  make cleanall             - Nettoyage complet (+ statuts MT)"
	@echo ""

.PHONY: all directories scripts_exec prepare test_status test_sphere_seq test_neutrons_seq \
        run_seq_sphere run_parallel_sphere run_parallel_neutrons test_adn clean cleanall help
