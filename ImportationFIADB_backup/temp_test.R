# Nettoyage du workspace et appel de la garbage collection
rm(list = ls())
gc()

# 2. Connection aux fichiers  ------------------------------------------------

source("./fonctions.R")

# 3. Chargement et vérification des packages ---------------------------------

listePackages <-
  c("DBI",
    "RPostgreSQL",
    "readr",
    "tidyverse",
    "compare",
    "data.table",
    "R.utils")
packagesAInstaller <-
  listePackages[!(listePackages %in% installed.packages()[, "Package"])]
if (length(packagesAInstaller) > 0)
  install.packages(packagesAInstaller)

require("DBI")
require("RPostgreSQL")
require("readr")
require("tidyverse")
require("compare")
require("data.table")
require("R.utils")


# Connexion BD ------------------------------------------------------------

pw = 'postgres'

drv <- dbDriver("PostgreSQL")

connect <-
  dbConnect(
    drv,
    dbname = "testdb",
    host = "localhost",
    port = 5432,
    user = "postgres",
    password = pw
  )
rm(pw) # enlève le mot de passe

# Modification format date ------------------------------------------------

# evalipop <- read_csv("..\\EVALIDATOR_POP_EST_1_6_1.csv")
# evalipop$MODIFIED_DATE <- as.POSIXct(evalipop$MODIFIED_DATE, format = "%m/%d/%Y %I:%M:%S %p")
# evalipop$CREATED_DATE <- as.POSIXct(evalipop$CREATED_DATE, format = "%m/%d/%Y %I:%M:%S %p")
# write_csv(evalipop, "..\\EVALIDATOR_POP_EST_1_6_1.csv", na = "")



# Tests pour valider champs problematiques --------------------------------
options(scipen = 999)
# test por table COND champ habtypcd1

load(file = paste(".\\Robjects\\", "cond", "_csv.RData", sep = ""))
load(file = paste(".\\Robjects\\", "cond", "_bd.RData", sep = ""))

compData <- compare(dataCSV, dataBD)
idenData <- identical(dataCSV, dataBD)

champCSV <- dataCSV$habtypcd1
champBD <- dataBD$habtypcd1

champCSV <- as.character(champCSV)
champBD <- as.character(champBD)

resultats <- list()
for (i in 1:length(champBD)) {
  resultats[i] <- compare(champCSV[i], champBD[i])
}

valeurs_fausses <- grep("FALSE", resultats)
resultats[grep("FALSE", resultats)]

champCSV[valeurs_fausses]
champBD[valeurs_fausses]

fichier_csv <- read_csv(".\\FIADB_PG_1_7_2_00\\CSV_DATA\\COND.csv", col_names = TRUE, na = "")
names(fichier_csv) <- fichier_csv %>%
  colnames() %>%
  tolower() %>%
  c()
fichier_csv$cn <- as.character(fichier_csv$cn)
fichier_csv <- fichier_csv[order(fichier_csv$cn),]
fichier_csv$habtypcd1[valeurs_fausses]
dataBD$habtypcd1[valeurs_fausses]

valeur_champ_bd <- dbGetQuery(connect, "select habtypcd1 from fs_fiadb.cond where cn = '301899733489998'")

rm(dataCSV, dataBD, compData, idenData, champBD, champCSV, resultats, i, fichier_csv, valeurs_fausses)
gc()

# test pour la table sitetree

load(file = paste(".\\Robjects\\", "sitetree", "_csv.RData", sep = ""))
load(file = paste(".\\Robjects\\", "sitetree", "_bd.RData", sep = ""))

champCSV <- dataCSV$site_tree_method_pnwrs
champBD <- dataBD$site_tree_method_pnwrs

resultats <- list()
for (i in 1:length(champBD)) {
  resultats[i] <- compare(champCSV[i], champBD[i])
}

valeurs_fausses <- grep("FALSE", resultats)
champCSV[valeurs_fausses]
champBD[valeurs_fausses]

rm(dataCSV, dataBD, champBD, champCSV, resultats, i, valeurs_fausses)
gc()


killDbConnections()
