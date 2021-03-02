# Script d'importation et de validation des données du FIADB dans une base
# de données Postgres en local
#
# Auteur: Jean-Michel St-Pierre
#
# Objectif:
#   Ce script vise à faire l'installation de la base de données,
# l'importation des données dans les tables et la validation du succès
# de l'importation dans un environnement physique où la base de données
# n'est pas installée.
#

# 1. Initialisation ----------------------------------------------------------

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
    "stringr",
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
require("stringr")
require("tidyverse")
require("compare")
require("data.table")
require("R.utils")

# 4. Variables utilisateur ---------------------------------------------------
# mot de passe posgres
pw <- "pgadmin"

# Chemin complet de l'emplacement désiré pour le tablespace

emplacementTablespace <- "D:/testdb"

# Nom du repertoire de scripts (version du fiadb)
# Lors de la création de ce script le répertoire s'appelait :
# FIADB_PG_1_7_2_00 (version 1.7.2.00)

repFIADB <- "FIADB_PG_1_7_2_00"

nouvNomBD <- "db_DRF"

nouvNomSchema <- "drf_142332119_usda_fia"

repPG <- "C:\\Program Files\\PostgreSQL\\9.6\\bin"

versionPG <- str_extract(repPG, "\\d+\\.*\\d*")

# 5. Creation du fichier log -------------------------------------------------
# Changement de l'encodage pour autoriser les accents dans les logs
options(encoding = "UTF-8")
# Connection avec le fichier avec sink()
file.create("log_importation.txt")
conFile <- file("log_importation.txt", open = "a")
sink(conFile)
# Écriture avec fonction cat()
cat(
  paste(
    "========================================================================",
    "========\n",
    sep = ""
  ),
  file = "log_importation.txt",
  append = TRUE
)
cat(
  "Journal de l'importation de la base de données FIA (Forest Inventory
  and \nAnalysis) du USDA (United States Department of Agriculture)\n",
  file = "log_importation.txt",
  append = TRUE
  )
utilisateur <-  shell("ECHO %username%", intern = TRUE)
cat(
  paste(
    "\n\nCe fichier journal est initialisé car l'utilisateur: ",
    utilisateur,
    " a ammorcé \nl'importation de la base de données sur son ordinateur.",
    sep = ""
  ),
  file = "log_importation.txt",
  append = TRUE
)
cat(
  "\nLe journal effectura le suivi et la validation de l'importation.\n",
  file = "log_importation.txt",
  append = TRUE
)
cat(
  paste(
    "========================================================================",
    "========\n",
    sep = ""
  ),
  file = "log_importation.txt",
  append = TRUE
)
# Renvoie de la sortie vers la console pour éviter d'écrire des lignes de
# textes (messages ou avertissements à l'exécution) inutilement dans le
# fichier log
sink()

# 6. Connection avec la base de données postgreSQL ---------------------------

# chargement du driver PostgreSQL
drv <- dbDriver("PostgreSQL")

# creation de la BD

connect <-
  dbConnect(
    drv,
    dbname = "postgres",
    host = "localhost",
    port = 5432,
    user = "postgres",
    password = pw
  )


# création du Tablespace
dir.create(gsub("/", "\\", emplacementTablespace), showWarnings = FALSE)
reqTablespace <-
  paste("CREATE TABLESPACE ts_DRF LOCATION '",
        emplacementTablespace,
        "';",
        sep = "")

dbGetQuery(connect, reqTablespace)

dbGetQuery(connect, "CREATE DATABASE testdb TABLESPACE ts_DRF;")

# connection à la BD testdb
# la variable "connect" sera réutilisée pour chaque connection

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

# création des extensions
dbGetQuery(connect, "CREATE EXTENSION postgis")
dbGetQuery(connect, "CREATE EXTENSION postgis_topology")

# Ecriture dans le log
BDExiste <-
  dbGetQuery(connect, "SELECT 1 from pg_database WHERE datname='testdb'")
sink(conFile)
cat("\nPHASE DE CRÉATION DE LA BASEE DE DONNÉES:\n\n",
    file = "log_importation.txt",
    append = TRUE)
if (BDExiste == 1) {
  cat(
    "La base de donnée 'testdb' a été créée avec succès!\n\n",
    file = "log_importation.txt",
    append = TRUE
  )
} else{
  cat("La base de donnée 'testdb' n'existe pas.\n\n",
      file = "log_importation.txt",
      append = TRUE)
}
sink()

# 7. Importation des donnees -------------------------------------------------

# Exéccution du script d'installation
source("./installation_bd.R")

# 8. Transfert des sorties de script vers le log  ----------------------------
sink(conFile)
cat(
  "\nPHASE D'IMPORTATION DES DONNÉES AVEC LES SCRIPTS:\n",
  file = "log_importation.txt",
  append = TRUE
)
# Lecture des logs d'erreur générés à l'importation
log1 <-
  read_file(
    paste(
      ".\\",
      repFIADB,
      "\\ScriptOutputs\\output_create_tables_erreur.txt",
      sep = ""
    )
  )
cat(
  "\nMessages d'erreurs produits par la création des tables
  (createTables.bat): \n",
  file = "log_importation.txt",
  append = TRUE
)
cat(
  paste(
    "------------------------------------------------------------------------",
    "-------\n\n",
    sep = ""
  ),
  file = "log_importation.txt",
  append = TRUE
)
# Écriture du contenu du log d'erreur dans le log d'importation
cat(log1, file = "log_importation.txt", append = TRUE)

# Même procédure que pour le log 1 appliquée aux logs 2 et 3
log2 <-
  read_file(
    paste(
      ".\\",
      repFIADB,
      "\\ScriptOutputs\\output_load_reference_erreur.txt",
      sep = ""
    )
  )
cat(
  "\n\nMessages d'erreurs produits par l'importation des données dans les
  tables \nde référence (loadReferenceTables.bat): \n",
  file = "log_importation.txt",
  append = TRUE
)
cat(
  paste(
    "------------------------------------------------------------------------",
    "-------\n\n",
    sep = ""
  ),
  file = "log_importation.txt",
  append = TRUE
)
cat(log2, file = "log_importation.txt", append = TRUE)

log3 <-
  read_file(
    paste(
      ".\\",
      repFIADB,
      "\\ScriptOutputs\\output_load_data_tables_entire_erreur.txt",
      sep = ""
    )
  )
cat(
  "\n\nMessages d'erreurs produits par l'importation des données des États
  (loadDataTablesEntire.bat): \n",
  file = "log_importation.txt",
  append = TRUE
)
cat(
  paste(
    "------------------------------------------------------------------------",
    "-------\n\n",
    sep = ""
  ),
  file = "log_importation.txt",
  append = TRUE
)
cat(log3, file = "log_importation.txt", append = TRUE)
sink()

# 9. Validation du nombre de tables créées -----------------------------------

# requete pour obtenir la liste des tables dans le schéma "fs_fiadb"

reqTablesSchema <-
  "SELECT table_name FROM information_schema.tables
WHERE table_schema = 'fs_fiadb' ORDER BY table_name ASC;"

listeTablesSchema <- dbGetQuery(connect, reqTablesSchema)
listeTablesSchema <- listeTablesSchema[[1]]
nbTableSchema <-
  length(listeTablesSchema)  # nombre de tables dans le schéma


# Liste des fichiers utilisés pour la création des tables

listeScriptsTables <-
  list.files(
    path = paste(repFIADB, "/TableScripts", sep = ""),
    pattern = "^Create",
    ignore.case = TRUE,
    recursive = TRUE
  )

listeScriptsTables %<>% tolower(.) %>%
  gsub(".sql|create", "", .) %>%
  sort(.)
nbScripts <- length(listeScriptsTables)

# comparaison entre les deux listes

compScriptTable <-
  match(listeScriptsTables, listeTablesSchema, nomatch = 0)
scriptsRetPos <- grep("\\b0\\b", compScriptTable)
scriptsRet <- listeScriptsTables[scriptsRetPos]


# 10. Liste des fichiers de données CSV ---------------------------------------

# chargement des fichiers de données

options(scipen = 999)  # empêche le passage vers la notation scientifique

# Liste des fichiers CSV dans le répertoire CSV_DATA
listeCSV1 <-
  list.files(
    path = paste(repFIADB, "/CSV_DATA/", sep = ""),
    pattern = ".csv",
    ignore.case = TRUE,
    recursive = TRUE,
    full.names = TRUE
  )

# Liste des fichiers CSV dans le répertoire CSV_PERM
listeCSV2 <-
  list.files(
    path = paste(repFIADB, "/CSV_PERM/", sep = ""),
    pattern = ".csv",
    ignore.case = TRUE,
    recursive = TRUE,
    full.names = TRUE
  )

# Concaténation des deux listes
listeFichiersCSV <- c(listeCSV1, listeCSV2)

# Tri croissant effectué sur la liste en omettant le nom des répertoires
listeFichiersCSV <-
  listeFichiersCSV[order(as.character(gsub(
    paste(repFIADB, "/CSV_DATA/|", repFIADB, "/CSV_PERM/", sep = ""),
    "",
    listeFichiersCSV
  )))]

# Retrait des deux listes intermédiaires
rm(listeCSV1, listeCSV2)

# Retrait des fichiers desuets

listeFichiersCSV <- listeFichiersCSV[-grep("retired", listeFichiersCSV, ignore.case = TRUE)]

# Remplacement des chaines des caractères superflues pour avoir la liste
# contenant uniquement les noms des fichiers CSV
listeNomCSV <-
  gsub(
    paste(
      repFIADB,
      "/CSV_DATA/|",
      repFIADB,
      "/CSV_PERM/|.csv|.CSV",
      sep = ""
    ),
    "",
    listeFichiersCSV
  ) %>% tolower() %>% sort()

nbFichiersCSV <- length(listeFichiersCSV)

# Comparaison entre la liste des tables et la liste des noms de fichiers
compTableCSV <- match(listeTablesSchema, listeNomCSV, nomatch = 0)
# Recherche des tables pour lesquelles il n'y a pas de CSV associé
tablesRetPos <- grep("\\b0\\b", compTableCSV)
# Liste des tables sans fichiers de données
tablesRet <- listeTablesSchema[tablesRetPos]
# Retrait des tables sans données pour créer la liste des tables
# pertinentes
listeTablesDonnees <- listeTablesSchema[-tablesRetPos]

# 11. Retrait des tables et fichiers CSV vides --------------------------------

# Dataframe du nombre de lignes pour chaque fichier CSV (prends un certain
# temps à exécuter)
nbLignesCSV <- list()
for (i in 1:length(listeFichiersCSV)) {
  nbLignesCSV[i] <-
    length(count_fields(listeFichiersCSV[i], tokenizer = tokenizer_csv(), skip = 1))
  # l'option "skip = 1" permet de tenir compte des entêtes de fichier
}

# Recherche des fichiers sans données
fichiersVidesPos <- grep("\\b0\\b", nbLignesCSV)
fichiersVides <- listeNomCSV[fichiersVidesPos]
# Retrait des fichiers vides de la liste des fichiers CSV
listeFichiersCSV <- listeFichiersCSV[-fichiersVidesPos]
listeNomCSV <- listeNomCSV[-fichiersVidesPos]

# Dataframe du nombre de lignes de données pour chaque tables
nbLignesBD <- list()
for (i in 1:length(listeTablesDonnees)) {
  nbLignesBD[i] <-
    dbGetQuery(connect,
               paste("SELECT COUNT(*) FROM fs_fiadb.",
                     listeTablesDonnees[i], sep = ""))
}
# Recherche des tables sans données
tablesVidesPos <- grep("\\b0\\b", nbLignesBD)
tablesVides <- listeTablesDonnees[tablesVidesPos]
# Retrait des tables sans données de la liste
listeTablesDonnees <- listeTablesDonnees[-tablesVidesPos]

# 12. Envoi du warning vers le log --------------------------------------------

sink(conFile)
cat("\n\n ********** AVERTISSEMENTS ********** ",
    file = "log_importation.txt",
    append = TRUE)
cat(
  "\nVoici une liste d'avertissements à observer avant la validation plus
  détaillée\n",
  file = "log_importation.txt",
  append = TRUE
)

# Nombre de fichiers de chaque types
cat(
  paste(
    "\n\n La base de données et le répertoire d'installation comprends:
    \n\n",
    nbScripts,
    " scripts SQL de création de tables\n",
    nbTableSchema,
    " tables dans le schéma de la base de données\n",
    nbFichiersCSV,
    " fichiers de données CSV\n",
    sep = ""
  ),
  file = "log_importation.txt",
  append = TRUE
)

if (length(scriptsRet) > 0) {
  cat(
    paste(
      "\n La table ",
      scriptsRet,
      "n'a pas été créée malgré le script SQL 'CreateTable' du même nom.",
      sep = "\t"
    ),
    file = "log_importation.txt",
    append = TRUE
  )
}
cat("\n",
    file = "log_importation.txt",
    append = TRUE)

if (length(tablesRet) > 0) {
  cat(
    paste(
      "\n La table ",
      tablesRet,
      "est vide car elle n'a aucun fichier de données associé.",
      sep = "\t"
    ),
    file = "log_importation.txt",
    append = TRUE
  )
}
cat("\n",
    file = "log_importation.txt",
    append = TRUE)
if (length(fichiersVides) > 0) {
  cat(
    paste(
      "\n Le fichier de données ",
      fichiersVides,
      "ne contient pas de données.",
      sep = "\t"
    ),
    file = "log_importation.txt",
    append = TRUE
  )
}
cat("\n",
    file = "log_importation.txt",
    append = TRUE)
if (length(tablesVides) > 0) {
  cat(
    paste("\n La table ",
          tablesVides,
          "ne contient pas de données.",
          sep = "\t"),
    file = "log_importation.txt",
    append = TRUE
  )
}
cat(
  paste(
    "\n\nLes ",
    length(listeTablesDonnees),
    " fichiers de données suivants seront comparés aux tables pour valider l'importation:\n",
    sep = ""
  ),
  file = "log_importation.txt",
  append = TRUE
)
for (i in 1:length(listeTablesDonnees)) {
  cat(paste(listeTablesDonnees[i], "\n"),
      file = "log_importation.txt",
      append = TRUE)
  
}

cat("\n\n ")

sink()

# 13. Requete noms de colonnes et types de colonnes tables --------------------

# Requête dans la table "information_schema" de la base de données pour
# obtenir la liste des champs et le type de données pour chaque table
typesNomColTables <- list()
for (i in 1:length(listeTablesDonnees)) {
  typesNomColTables[[i]] <-
    dbGetQuery(
      connect,
      paste(
        "SELECT column_name, data_type FROM information_schema.columns
        WHERE table_name = '",
        listeTablesDonnees[i],
        "';",
        sep = ""
      )
    )
}

# Modification des types dans le dataframe précédent pour remplacer les
# types postgres par des types reconnus par R
for (i in 1:length(listeTablesDonnees)) {
  typesNomColTables[[i]][, 2] <-
    gsub("character varying", "character", typesNomColTables[[i]][, 2])
}

for (i in 1:length(listeTablesDonnees)) {
  typesNomColTables[[i]][, 2] <-
    gsub("smallint", "integer", typesNomColTables[[i]][, 2])
}

for (i in 1:length(listeTablesDonnees)) {
  typesNomColTables[[i]][, 2] <-
    gsub("double precision", "numeric", typesNomColTables[[i]][, 2])
}

for (i in 1:length(listeTablesDonnees)) {
  typesNomColTables[[i]][, 2] <-
    gsub("timestamp without time zone", "Date", typesNomColTables[[i]][, 2])
}

for (i in 1:length(listeTablesDonnees)) {
  typesNomColTables[[i]][, 2] <-
    gsub("bigint", "numeric", typesNomColTables[[i]][, 2])
}

# 14. Importation des dataframes CSV ------------------------------------------

# Lecture des fichiers de données CSV en appliquant les types de chaque
# colonnes selon la requête précédente et sauvegarde en Robject
for (i in 1:length(listeFichiersCSV)) {
  dataCSV <-
    fread(
      listeFichiersCSV[i],
      colClasses = typesNomColTables[[i]][, 2],
      stringsAsFactors = FALSE,
      showProgress = FALSE
    )
  # Noms de colonnes en minuscule
  names(dataCSV) <- dataCSV %>%
    colnames() %>%
    tolower() %>%
    c()
  # Tri croissant
  if (listeNomCSV[i] == "plotsnap") {
    dataCSV <- dataCSV[order(dataCSV[, 1], dataCSV[, 51]), ]
  } else{
    dataCSV <- dataCSV[order(dataCSV[, 1]), ]
  }
  
  # Cas spécial pour la table TREE, elle est scindée en deux parties
  # avant d'être sauvegardée en deux Robjects
  if (listeNomCSV[i] == "tree") {
    nbR <- nrow(dataCSV)
    n <- nbR / 2
    dataCSV <-
      split(dataCSV, rep(1:ceiling(nbR / n), each = n, length.out = nbR))
    a <- dataCSV[[1]]
    b <- dataCSV[[2]]
    save(a,
         file = paste(".\\Robjects\\", listeNomCSV[i], "_A_csv.RData", sep = ""))
    save(b,
         file = paste(".\\Robjects\\", listeNomCSV[i], "_B_csv.RData", sep = ""))
  } else {
    save(dataCSV,
         file = paste(".\\Robjects\\", listeNomCSV[i], "_csv.RData", sep = ""))
  }
  rm(dataCSV, a, b, nbR, n)
  gc()
}

# 15. Exportation des tables en CSV -------------------------------------------
# Écriture du fichier SQL qui fera la copie du contenu des tables dans des
# fichiers CSV pour la future comparaison

# Répertoire où sauvegarder les fichier CSV
cheminRep <- "%cd%\\..\\ExportTables\\"
sink("exportTables.sql")
for (j in 1:length(listeTablesDonnees)) {
  cat(
    paste(
      "\\copy fs_fiadb.",
      listeTablesDonnees[j],
      " TO '",
      cheminRep,
      listeTablesDonnees[j],
      "_db.csv' DELIMITER ',' CSV HEADER;\n",
      sep = ""
    ),
    file = "exportTables.sql",
    append = TRUE
  )
}
sink()

# correction de la version postgres

# si la version de l'utilisateur est différente de Postgres 10 le code suivant 
# modifie le script

if (versionPG != 10){
  
  lignesBatchExp <- read_lines("exportTables.bat")
  lignesModifBatchExp <-
    gsub(
      "10",
      versionPG,
      lignesBatchExp
    )
  cat(lignesModifBatchExp, file = "exportTablesMod.bat", sep = "\n")
  
}

# Execution du script batch qui initie l'exportation
if (versionPG != 10){
  shell("exportTablesMod.bat", wait = TRUE, intern = TRUE)
} else{
  shell("exportTables.bat", wait = TRUE, intern = TRUE)
}

# 16. Importation des dataframes postgres a partir des CSV --------------------

# Liste des fichiers de données dans le répertoire ExportTables
listeExportTable <-
  list.files(
    path = "ExportTables/",
    pattern = ".csv",
    ignore.case = TRUE,
    recursive = TRUE,
    full.names = TRUE
  )
# Liste des noms de fichiers uniquement
listeNomTablesExport <-
  gsub("ExportTables/|.csv|.CSV|_db", "", listeExportTable) %>%
  tolower() %>% sort()

# Comparaison*** (à valider)
comparaisonBD <-
  match(listeNomTablesExport, listeTablesSchema, nomatch = 0)
listeTablesExportTri <- vector()
for (i in 1:length(comparaisonBD)) {
  if (comparaisonBD[i] != 0) {
    listeTablesExportTri <- c(listeTablesExportTri, listeExportTable[i])
  }
}
listeTablesExportTri <-
  listeTablesExportTri[order(as.character(
    gsub("ExportTables/|.csv|.CSV|_db", "", listeTablesExportTri)
  ))]

listeNomTablesExportOrd <-
  gsub("ExportTables/|.csv|.CSV|_db", "", listeTablesExportTri) %>%
  tolower() %>% sort()

for (i in 1:length(listeTablesExportTri)) {
  dataBD <-
    fread(
      listeTablesExportTri[i],
      colClasses = typesNomColTables[[i]][, 2],
      stringsAsFactors = FALSE,
      showProgress = FALSE
    )
  names(dataBD) <- dataBD %>%
    colnames() %>%
    tolower() %>%
    c()
  if (listeNomTablesExportOrd[i] == "plotsnap") {
    dataBD <- dataBD[order(dataBD[, 1], dataBD[, 51]), ]
  } else{
    dataBD <- dataBD[order(dataBD[, 1]), ]
  }
  
  if (listeNomTablesExportOrd[i] == "tree") {
    nbR <- nrow(dataBD)
    n <- nbR / 2
    dataBD <-
      split(dataBD, rep(1:ceiling(nbR / n), each = n, length.out = nbR))
    a <- dataBD[[1]]
    b <- dataBD[[2]]
    save(a,
         file = paste(
           ".\\Robjects\\",
           listeNomTablesExportOrd[i],
           "_A_bd.RData",
           sep = ""
         ))
    save(b,
         file = paste(
           ".\\Robjects\\",
           listeNomTablesExportOrd[i],
           "_B_bd.RData",
           sep = ""
         ))
  } else {
    save(dataBD,
         file = paste(
           ".\\Robjects\\",
           listeNomTablesExportOrd[i],
           "_bd.RData",
           sep = ""
         ))
  }
  rm(dataBD, a, b, nbR, n)
  gc()
}

# 17. Comparaison par valeur et identitaire des datasets ----------------------

sink(conFile)
cat(
  "\n\n\nPHASE DE VALIDATION DES DONNÉES IMPORTÉES:\n\n",
  file = "log_importation.txt",
  append = TRUE
)
cat(
  "\nLa section suivante du journal fera l'énumération de chaque table
  qui contient des enregistrements et \naffichera les résultats de la
  comparaison entre le fichier de données CSV et les enregistrements dans
  la base de données\n",
  file = "log_importation.txt",
  append = TRUE
)
# Chargement en itération des Robjects créés à partir des fichiers CSV
# originaux et des exportations de la base de données pour chaque tables

# Le premier "if" vise à appliquer une procédure spécifique pour la table
# TREE puisque son fichier est divisé en deux parties
for (i in 1:length(listeFichiersCSV)) {
  if (listeNomCSV[i] == "tree") {
    for (j in 1:2) {
      lettre <- c("A", "B")
      # Chargement des deux Robjects
      dataCSV <-
        load(file = paste(
          ".\\Robjects\\",
          listeNomCSV[i],
          "_",
          lettre[j],
          "_csv.RData",
          sep = ""
        ))
      dataBD <-
        load(file = paste(
          ".\\Robjects\\",
          listeNomCSV[i],
          "_",
          lettre[j],
          "_bd.RData",
          sep = ""
        ))
      # Conversion de types pour les dates
      if ("created_date" %in% colnames(dataCSV)) {
        dataCSV$created_date <- as.Date(as.character(dataCSV$created_date))
      }
      if ("created_date" %in% colnames(dataBD)) {
        dataBD$created_date <- as.Date(as.character(dataBD$created_date))
      }
      # Substitution de la chaine de caractères de l'heure 0 créée dans postgres
      # mais absente dans les fichiers originaux
      if ("modified_date" %in% colnames(dataBD)) {
        dataBD$modified_date <-  gsub(" 00:00:00", "", dataBD$modified_date)
      }
      # Comparaison avec compare() et identical
      compData <- compare(dataCSV, dataBD)
      idenData <- identical(dataCSV, dataBD)
      # Impression du résultat dans le log
      cat(
        paste("\n\nTable:", listeNomCSV[i], lettre[j], sep = " "),
        file = "log_importation.txt",
        append = TRUE
      )
      cat(paste("\nIdentical = ", idenData, sep = ""),
          file = "log_importation.txt",
          append = TRUE)
      
      if (compData[[1]] == TRUE) {
        cat(paste("\nCompare =", compData[[1]], sep = " "),
            file = "log_importation.txt",
            append = TRUE)
      }
      if (compData[[1]] == FALSE) {
        cat(
          paste("\nCompare =", colnames(dataCSV), compData[[2]], sep = " "),
          file = "log_importation.txt",
          append = TRUE
        )
      }
      # Supression des variables et nettoyage de la mémoire
      rm(dataCSV, dataBD, compData, idenData, a, b)
      gc()
    }
  } else{
    # Procédure de chargement standard appliquée aux autres fichiers de données
    
    # Chargement des deux RObjects
    load(file = paste(".\\Robjects\\", listeNomCSV[i], "_csv.RData", sep = ""))
    load(file = paste(".\\Robjects\\", listeNomCSV[i], "_bd.RData", sep = ""))
    # Conversion des dates dans un format commun
    if ("created_date" %in% colnames(dataCSV)) {
      dataCSV$created_date <- as.Date(as.character(dataCSV$created_date))
    }
    if ("created_date" %in% colnames(dataBD)) {
      dataBD$created_date <- as.Date(as.character(dataBD$created_date))
    }
    # Substitution de la chaine de caractères de l'heure 0
    if ("modified_date" %in% colnames(dataBD)) {
      dataBD$modified_date <-  gsub(" 00:00:00", "", dataBD$modified_date)
    }
    if ("start_date" %in% colnames(dataCSV)) {
      dataCSV$start_date <- as.Date(as.character(dataCSV$start_date))
    }
    if ("start_date" %in% colnames(dataBD)) {
      dataBD$start_date <- as.Date(as.character(dataBD$start_date))
    }
    if ("end_date" %in% colnames(dataBD)) {
      dataBD$end_date <-  gsub(" 00:00:00", "", dataBD$end_date)
    }
    if ("sample_date" %in% colnames(dataCSV)) {
      dataCSV$sample_date = as.Date(as.character(dataCSV$sample_date))
    }
    if ("sample_date" %in% colnames(dataBD)) {
      dataBD$sample_date <-  gsub(" 00:00:00", "", dataBD$sample_date)
      dataBD$sample_date = as.Date(as.character(dataBD$sample_date))
    }
    # Conversion dans un type numérique pour des chaines de chiffres
    # converties automatiquement dans Postgres mais en caractères dans
    # les fichires CSV originaux
    if (listeNomCSV[i] == "ref_lichen_spp_comments") {
      dataCSV$yearstart = as.integer(dataCSV$yearstart)
      dataBD$yearstart = as.integer(dataCSV$yearstart)
      dataCSV$yearend = as.integer(dataCSV$yearend)
      dataBD$yearend = as.integer(dataCSV$yearend)
      dataCSV$cn = as.character(dataCSV$cn)
      dataBD$cn = as.character(dataCSV$cn)
    }
    if ("updated_unknown_species_date" %in% colnames(dataBD)) {
      dataBD$updated_unknown_species_date <-
        gsub(" 00:00:00", "", dataBD$updated_unknown_species_date)
    }
    if (listeNomCSV[i] == "plotsnap") {
      dataCSV$eval_grp_cn <- as.integer(dataCSV$eval_grp_cn)
      dataBD$eval_grp_cn <- as.integer(dataBD$eval_grp_cn)
      
      dataCSV$adj_expall <- as.integer(dataCSV$adj_expall)
      dataBD$adj_expall <- as.integer(dataBD$adj_expall)
    }
    
    # Comparaison avec les fonction compare et identical
    compData <- compare(dataCSV, dataBD)
    idenData <- identical(dataCSV, dataBD)
    
    # Impression du résultat dans le fichier log
    cat(paste("\n\nTable: ", listeNomCSV[i], sep = ""),
        file = "log_importation.txt",
        append = TRUE)
    cat(paste("\nIdentical = ", idenData, sep = ""),
        file = "log_importation.txt",
        append = TRUE)
    
    if (compData[[1]] == TRUE) {
      cat(paste("\nCompare =", compData[[1]], sep = " "),
          file = "log_importation.txt",
          append = TRUE)
    }
    if (compData[[1]] == FALSE) {
      cat(
        paste("\nCompare =", colnames(dataCSV), compData[[2]], sep = " "),
        file = "log_importation.txt",
        append = TRUE
      )
    }
    
    # Supression des variables et nettoyage de la mémoire
    rm(dataCSV, dataBD, compData, idenData)
    gc()
  }
}
sink()


# 18. Création du script sql pour renommer le schéma et la BD -------------

sink("modif_schema.sql")
cat(
  paste("ALTER DATABASE testdb RENAME TO ", nouvNomBD, sep = ""),
  file = "modif_schema.sql",
  append = TRUE
)
cat(
  paste("\nALTER SCHEMA fs_fiadb RENAME TO ", nouvNomSchema, sep = ""),
  file = "modif_schema.sql",
  append = TRUE
)
sink()
# 19. Deconnection ------------------------------------------------------------
# pas essentiel mais une bonne pratique car le nombre de connections
# possible est limité

killDbConnections()
