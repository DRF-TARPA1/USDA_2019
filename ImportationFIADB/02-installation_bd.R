#Script de téléchargement et chargement des données dans la BD
#
#
# Auteur: Jean-Michel St-Pierre
#
# Objectif:
#   Créer l'arborescemce du projet qui reçoit les données,
#   télécharger les données, modifier les scripts selon le format de date
#   et la version de Postgres, et exécuter les scripts.
#

# 1. Telechargement des fichiers pour importation de la base de donne --------

# Création du répertoire de téléchargement pour les données physiques
dir.create("./Telechargements")

# Lien pour téléchargement du dossier d'installation de la base de données
# fourni par le USDA
urlPostgres = "https://apps.fs.usda.gov/fia/datamart/images/FIADB_PG.zip"
# Répertoire de téléchargement
postgresTele = paste("./Telechargements/", repFIADB, ".zip", sep = "")
# Répertoire cible pour le contenu du dossier (répertoire de travail)
postgresRep = getwd()
# trycatch pour le dossier d'installation de la base de données
succesTele <- FALSE
compteur <- 0
while (succesTele == FALSE) {
  tryCatch({
    download.file(urlPostgres, postgresTele, mode = "wb")
    succesTele <- TRUE
  },
  error = function(err_message) {
    succesTele <- FALSE
    # message(sprintf("Erreur lors du telechargement: %s", urlPostgres))
    message(err_message)
    message("Le programme va reessayer le telechargement sous peu")
  },
  finally = {
    compteur <- compteur + 1
    if (compteur > 5) {
      stop("Le telechargement est impossible, erreur de connexion")
    }
  })
}
if (succesTele) {
  unzip(postgresTele, exdir = postgresRep)
}

refRep = paste("./", repFIADB, "/CSV_DATA", sep = "")

if (length(list.files(refRep)) != 0) {
  invisible(do.call(file.remove, list(list.files(
    refRep, full.names = T
  ))))
}

# 2. Telechargement des fichiers de donnees de reference ---------------------

# Voir la premiere section pour le détail des commandes
urlRef = "https://apps.fs.usda.gov/fia/datamart/CSV/FIADB_REFERENCE.zip"
refTele = "./Telechargements/FIADB_REFERENCE.zip"

# trycatch pour les donnees de reference
succesTele <- FALSE
compteur <- 0
while (succesTele == FALSE) {
  tryCatch({
    download.file(urlRef, refTele, mode = "wb")
    succesTele <- TRUE
  },
  error = function(err_message) {
    succesTele <- FALSE
    message(sprintf("Erreur lors du telechargement: %s", urlRef))
    message(err_message)
    message("Le programme va reesayer le telechargement sous peu")
  },
  finally = {
    compteur <- compteur + 1
    if (compteur > 5) {
      stop("Le telechargement est impossible, erreur de connexion")
    }
  })
}
if (succesTele) {
  unzip(refTele, exdir = refRep)
}

# 3. Telechargement des fichiers de donnees des tables -----------------------

# Voir la premièere section pour le détail des commandes
urlData = "https://apps.fs.usda.gov/fia/datamart/CSV/ENTIRE.zip"
dataTele = "./Telechargements/ENTIRE.zip"
# trycatch pour les données
succesTele <- FALSE
compteur <- 0
while (succesTele == FALSE) {
  tryCatch({
    download.file(urlData, dataTele, mode = "wb")
    succesTele <- TRUE
  },
  error = function(err_message) {
    succesTele <- FALSE
    message(sprintf("Erreur lors du telechargement: %s", urlData))
    message(err_message)
    message("Le programme va reesayer le telechargement sous peu")
  },
  finally = {
    compteur <- compteur + 1
    if (compteur > 5) {
      stop("Le telechargement est impossible, erreur de connexion")
    }
  })
}

if (succesTele) {
  unzip(dataTele, exdir = refRep)
}

# 4. Creation des repertoires ---------------------------------------------

# Création du répertoire qui reçoit les sorties des scripts
dir.create(paste("./", repFIADB, "/ScriptOutputs", sep = ""))
# Création du répertoire où sonrt exportées les tables
dir.create("./ExportTables")
dir.create("./RObjects")

# creation du repertoire de copie des fichiers
dir.create("./Copie")
dir.create("./Copie/CSV_DATA")
dir.create("./Copie/CSV_PERM")


# 5. Liste des fichiers CSV -----------------------------------------------

# chargement des fichiers de données

options(scipen = 999)  # empêche la notation scientifique

# Liste des fichiers CSV dans le répertoire CSV_DATA
listeCSV1 <-
  list.files(
    path = paste0("./", repFIADB, "/CSV_DATA/"),
    pattern = ".csv$",
    ignore.case = TRUE,
    recursive = FALSE,
    full.names = TRUE
  )

# Liste des fichiers CSV dans le répertoire CSV_PERM
listeCSV2 <-
  list.files(
    path = paste0("./", repFIADB, "/CSV_PERM/"),
    pattern = ".csv$",
    ignore.case = TRUE,
    recursive = FALSE,
    full.names = TRUE
  )

# retrait des fichiers desuets

if (length(grep("retired", listeCSV1, ignore.case = TRUE)) != 0) {
  listeCSV1 <-
    listeCSV1[-grep("retired", listeCSV1, ignore.case = TRUE)]
}

if (length(grep("retired", listeCSV2, ignore.case = TRUE)) != 0) {
  listeCSV2 <-
    listeCSV2[-grep("retired", listeCSV2, ignore.case = TRUE)]
}

# Concaténation des deux listes
listeFichiersCSV <- c(listeCSV1, listeCSV2)

# Tri croissant effectué sur la liste en omettant le nom des répertoires
listeFichiersCSV <-
  listeFichiersCSV[order(as.character(gsub(
    paste0(repFIADB, "/CSV_DATA/|", repFIADB, "/CSV_PERM/"),
    "",
    listeFichiersCSV
  )))]

# Remplacement des chaines des caractères superflues pour avoir la liste
# contenant uniquement les noms des fichiers CSV
listeNomCSV <-
  gsub(
    paste0(repFIADB,
           "/CSV_DATA/|",
           repFIADB,
           "/CSV_PERM/|.csv|.CSV"),
    "",
    listeFichiersCSV
  ) %>% tolower() %>% sort()

listeNomCSV <- gsub("./", "", listeNomCSV)

nbFichiersCSV <- length(listeFichiersCSV)

# 6. Backup des fichiers --------------------------------------------------

# Cette portion de code ne doit être exécutée qu'une fois
# Elle sert à faire la copie des fichiers originaux vers un répertoire
# Les fichiers originaux seront modifiés par après donc on ne doit pas les
# copier une seconde fois
# 
# Si le dossier "Copie" n'est pas vide mais qu'une erreur s'est produite
# il est recommandé de recommencer le téléchargement et la copie des fichiers 

if (is_empty(list.files(path = "./Copie", recursive = TRUE))) {
  for (i in 1:length(listeCSV1)) {
    file.copy(listeCSV1[i], "./Copie/CSV_DATA", overwrite = TRUE)
  }
  
  for (i in 1:length(listeCSV2)) {
    file.copy(listeCSV2[i], "./Copie/CSV_PERM", overwrite = TRUE)
  }
}

# 7. Parsing des types des tables -----------------------------------------

listeFichiersSQL <-
  list.files(path = "./FIADB_PG_1_8_0_00/TableScripts",
             pattern = "^Create|$.csv",
             full.names = TRUE)
typesSQL <-
  data.frame(Table = character(1),
             Types = character(1),
             stringsAsFactors = FALSE)
for (i in 1:length(listeFichiersSQL)) {
  typesSQL[i, ] <- getSQLTableTypes(listeFichiersSQL[i])
}

# 7. Lecture des CSV pour retirer les WS ----------------------------------

listeCSVCopy <-
  list.files(
    path = "./Copie",
    pattern = ".csv$",
    ignore.case = TRUE,
    recursive = TRUE,
    full.names = TRUE
  )

listeCSVCopy <-
  listeCSVCopy[order(as.character(gsub(
    "Copie/CSV_DATA/|Copie/CSV_PERM/",
    "",
    listeCSVCopy
  )))]

# indice des performances
t1 <- proc.time()[3]
temps <- c()
memo <- c()
objet <- c()
exec <- c()

# 1:length(listeCSVCopy)
# c(1:85,87:length(listeCSVCopy))
for (i in c(1:length(listeCSVCopy))) {
  pos_types <- grep(paste0("^", listeNomCSV[i], "$"), typesSQL[[1]])
  # Lecture fichier
  dataCSV <- read_csv(
    listeCSVCopy[i],
    col_names = TRUE,
    col_types = typesSQL[[2]][pos_types],
    locale = default_locale(),
    na = c("©"),
    quoted_na = TRUE,
    quote = "\"",
    comment = "",
    trim_ws = TRUE,
    progress = FALSE,
    skip_empty_rows = TRUE
  )
  
  # Ecriture fichier
  fwrite(dataCSV, listeFichiersCSV[i], quote = TRUE)
  
  # mesure de la memoire
  memo[i] <- mem_used()
  objet[i] <- object_size(dataCSV)
  temps[i] <- proc.time()[3] - t1
  rm(dataCSV)
  gc()
}

# performances

tempsTotal <- proc.time()[3] - t1

for (i in 1:length(temps)) {
  if (is.null(temps[i]) == TRUE) {
    exec[i] <- 0
  }
  if (i == 1) {
    exec[i] <- temps[i]
  } else {
    exec[i] <- temps[i] - temps[i - 1]
  }
}

# 8. Correction des formats de date ---------------------------------------

# fichiers ajoutés manuellement pour solution temporaire

# Fichiers traités: DATAMART_TABLE, EVALIDATOR_POP_EST_1_6_1

listeNomFichiersDates <-
  c(
    "DATAMART_TABLES",
    "EVALIDATOR_POP_EST_1_6_1",
    "REF_SPECIES",
    "LICHEN_SPECIES_SUMMARY",
    "REF_INVASIVE_SPECIES"
  ) %>% sort(.)
listePosFichiersDates <- c()
listePosTypes <- c()

for (i in 1:length(listeNomFichiersDates)) {
  listePosFichiersDates[i] <-
    grep(paste0("^", tolower(listeNomFichiersDates[i]), "$"), listeNomCSV)
  listePosTypes[i] <-
    grep(paste0("^", tolower(listeNomFichiersDates[i]), "$"), typesSQL[[1]])
}

for (i in 1:length(listeNomFichiersDates)) {  
  dataCSV <- read_csv(
    listeFichiersCSV[listePosFichiersDates[i]],
    col_names = TRUE,
    col_types = typesSQL[[2]][listePosTypes[i]],
    locale = default_locale(),
    na = c("©"),
    quoted_na = TRUE,
    quote = "\"",
    comment = "",
    trim_ws = TRUE,
    progress = FALSE,
    skip_empty_rows = TRUE
  )
  nom_col <- colnames(dataCSV)
  pos_dates <- grep("DATE", nom_col)
  
  for (j in 1:length(pos_dates)) {
    for (k in 1:nrow(dataCSV)) {
      if (is.na(dataCSV[k, pos_dates[j]]) != TRUE) {
        dataCSV[k, pos_dates[j]] <-
          toString(parse_date(dataCSV[k, pos_dates[j]]))
      }
    }
  }
  fwrite(dataCSV, listeFichiersCSV[listePosFichiersDates[i]], quote = T)
}

rm(dataCSV, nom_col)
gc()

# 9. Modification du datestamp des logs d'importation ------------------------

# Liste des fichiers de script du FIADB qui doivent être modifiés pour
# ajuster le format de date
fichiersScript <-
  c(
    paste(
      ".\\",
      repFIADB,
      "\\BatchScripts\\loadReferenceTables.bat",
      sep = ""
    ),
    paste(
      ".\\",
      repFIADB,
      "\\BatchScripts\\loadDataTablesEntire.bat",
      sep = ""
    )
  )

# Modification du format de date pour les scripts
for (f in fichiersScript) {
  lignesFichier <- readLines(f)
  lignesModif <-
    gsub(
      "%DATE:~10,4%_%DATE:~4,2%_%DATE:~7,2%",
      "%DATE:~0,4%_%DATE:~5,2%_%DATE:~8,2%",
      lignesFichier
    )
  cat(lignesModif, file = f, sep = "\n")
}

# 10. Execution des batch files -----------------------------------------------

listeScriptUSDA <-
  c(
    paste(".\\",
          repFIADB,
          "\\BatchScripts\\createTables.bat",
          sep = ""),
    paste(
      ".\\",
      repFIADB,
      "\\BatchScripts\\loadReferenceTables.bat",
      sep = ""
    ),
    paste(
      ".\\",
      repFIADB,
      "\\BatchScripts\\loadDataTablesEntire.bat",
      sep = ""
    )
  )

# si la version de l'utilisateur est différente de Postgres 10 le code suivant
# modifie les scripts du USDA de la liste précédente

if (versionPG != 10) {
  for (f in listeScriptUSDA) {
    lignesFichier <- read_lines(f)
    lignesModif <-
      gsub("10",
           versionPG,
           lignesFichier)
    cat(lignesModif, file = f, sep = "\n")
  }
}


lignesScriptBatch <- read_file("scriptImportation.bat")
lignesScriptBatchModif <-
  sprintf(
    lignesScriptBatch,
    paste(".\\", repFIADB, "\\BatchScripts", sep = ""),
    repPG,
    repPG,
    repPG
  )
write_file(lignesScriptBatchModif, "scriptImportationMod.bat")

shell("scriptImportationMod.bat",
      wait = TRUE,
      intern = FALSE)

# 11. Retour au format de date original ---------------------------------------

for (f in fichiersScript) {
  lignesFichier <- readLines(f)
  lignesModif <-
    gsub(
      "%DATE:~0,4%_%DATE:~5,2%_%DATE:~8,2%",
      "%DATE:~10,4%_%DATE:~4,2%_%DATE:~7,2%",
      lignesFichier
    )
  cat(lignesModif, file = f, sep = "\n")
}
