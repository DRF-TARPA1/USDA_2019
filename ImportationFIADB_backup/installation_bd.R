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
dir.create(".\\Telechargements")

# Lien pour téléchargement du dossier d'installation de la base de données
# fourni par le USDA
urlPostgres = paste("https://apps.fs.usda.gov/fia/datamart/images/",
                    repFIADB,
                    ".zip",
                    sep = "")
# Répertoire de téléchargement
postgresTele = paste(".\\Telechargements\\", repFIADB, ".zip", sep = "")
# Répertoire cible pour le contenu du dossier (répertoire de travail)
postgresRep = getwd()
# trycatch pour le dossier d'installation de la base de données
succesTele <- FALSE
compteur <- 0
while (succesTele == FALSE) {
  tryCatch(
    {
      download.file(urlPostgres, postgresTele)
      succesTele <- TRUE
    },
    error = function(err_message) {
      succesTele <- FALSE
      message(sprintf("Erreur lors du telechargement: %s", urlPostgres))
      message(err_message)
      message("Le programme va reessayer le telechargement sous peu")
    },
    finally = {
      compteur <- compteur + 1
      if (compteur > 5) {
        stop("Le telechargement est impossible, erreur de connexion")
      }
    }
  )
}
if (succesTele) {
  unzip(postgresTele, exdir = postgresRep)
}

# 2. Telechargement des fichiers de donnees de reference ---------------------

# Voir la premièere section pour le détail des commandes
urlRef = "https://apps.fs.usda.gov/fia/datamart/CSV/FIADB_REFERENCE.zip"
refTele = ".\\Telechargements\\FIADB_REFERENCE.zip"
refRep = paste(".\\", repFIADB, "\\CSV_DATA", sep = "")
# trycatch pour les donnees de reference
succesTele <- FALSE
compteur <- 0
while (succesTele == FALSE) {
  tryCatch(
    {
      download.file(urlRef, refTele)
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
    }
  )
}
if (succesTele) {
  unzip(refTele, exdir = refRep)
}

# 3. Telechargement des fichiers de donnees des tables -----------------------

# Voir la premièere section pour le détail des commandes
urlData = "https://apps.fs.usda.gov/fia/datamart/CSV/ENTIRE.zip"
dataTele = ".\\Telechargements\\ENTIRE.zip"
dataRep = refRep
# trycatch pour les données
succesTele <- FALSE
compteur <- 0
while (succesTele == FALSE) {
  tryCatch(
    {
      download.file(urlData, dataTele)
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
    }
  )
}

if (succesTele) {
  unzip(dataTele, exdir = dataRep)
}

# 4. Creation du dossier ScriptOutputs ---------------------------------------

# Création du répertoire qui reçoit les sorties des scripts
dir.create(paste(".\\", repFIADB, "\\ScriptOutputs", sep = ""))
# Création du répertoire où sonrt exportées les tables
dir.create(".\\ExportTables")
dir.create(".\\RObjects")

# 5. Copie des CSV temporairement corrigés pour remplacer ceux errones -------

locFichier1 <- "..\\DATAMART_TABLES.CSV"
locFichier2 <- "..\\EVALIDATOR_POP_EST_1_6_1.csv"

file.copy(from = locFichier1, to = sprintf(".\\%s\\CSV_PERM\\", repFIADB), overwrite = TRUE)
file.copy(from = locFichier2, to = sprintf(".\\%s\\CSV_PERM\\", repFIADB), overwrite = TRUE)

# 6. Modification du datestamp des logs d'importation ------------------------

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

# 7. Execution des batch files -----------------------------------------------

listeScriptUSDA <-
  c(
    paste(
      ".\\",
      repFIADB,
      "\\BatchScripts\\createTables.bat",
      sep = ""
    ),
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

if (versionPG != 10){
  for (f in listeScriptUSDA) {
    lignesFichier <- read_lines(f)
    lignesModif <-
      gsub(
        "10",
        versionPG,
        lignesFichier
      )
    cat(lignesModif, file = f, sep = "\n")
  }
}


lignesScriptBatch <- read_file("scriptImportation.bat")
lignesScriptBatchModif <- sprintf(lignesScriptBatch, paste(".\\", repFIADB, "\\BatchScripts", sep = ""), repPG, repPG, repPG)
write_file(lignesScriptBatchModif, "scriptImportationMod.bat")

shell("scriptImportationMod.bat", wait = TRUE, intern = FALSE)

# 8. Retour au format de date original ---------------------------------------

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
