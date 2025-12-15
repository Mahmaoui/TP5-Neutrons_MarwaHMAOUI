# --- Configuration CLHEP ---
CLHEP_INCLUDE_PATH := -I/usr/local/include 
CLHEP_LIB_PATH     := -L/usr/local/lib
CLHEP_LIBS         := -lCLHEP-Random-2.1.0.0

# --- Paramètres de compilation ---
CXX      := g++
CXXFLAGS := -Wall -Wextra -std=c++11 -O3 $(CLHEP_INCLUDE_PATH)
LDFLAGS  := $(CLHEP_LIB_PATH) $(CLHEP_LIBS)

# --- Exécutables ---
BIN_DIR := bin
EXEC_SIMU := $(BIN_DIR)/simu_parallel
EXEC_STATUS := $(BIN_DIR)/StatusSaver

# --- Objectifs Principaux ---
.PHONY: all clean prepare run

all: $(EXEC_SIMU) $(EXEC_STATUS)

# Objectif pour le simulateur principal (Question 3 & 5)
$(EXEC_SIMU): src/neutron_simu.cpp
	@mkdir -p $(BIN_DIR)
	$(CXX) $(CXXFLAGS) $< -o $@ $(LDFLAGS)
	@echo "=> Compilation de $^ [OK]"

# Objectif pour le générateur de statuts (Question 4)
$(EXEC_STATUS): src/StatusSaver.cpp
	@mkdir -p $(BIN_DIR)
	$(CXX) $(CXXFLAGS) $< -o $@ $(LDFLAGS)
	@echo "=> Compilation de $^ [OK]"

# Objectif pour préparer les 30 statuts aléatoires
prepare: $(EXEC_STATUS)
	@echo "Lancement de la préparation des statuts..."
	./$(EXEC_STATUS)

# Objectif pour lancer la simulation complète
run: prepare $(EXEC_SIMU)
	@scripts/run_parallel.sh

clean:
	@rm -rf $(BIN_DIR) $(EXEC_STATUS) $(EXEC_SIMU)
	@rm -rf Results/*.out
	@rm -f MTStatus-*
	@echo "Nettoyage terminé."