# Comparaison des noms d'essences US-QC -----------------------------------

# Nettoyage du workspace et appel de la garbage collection
rm(list=ls())
gc()


# Connection aux fichiers -------------------------------------------------

# fichier contenant les fonctions utiles
source("fonctions.R")

# Chargement des packages -------------------------------------------------

# install("DBI")
# install("RPostgreSQL")
# install("readr")
# install("tidyverse")
# install("compare")
# install("data.table")

require("DBI")
require("RPostgreSQL")
require("readr")
require("tidyverse")
require("compare")
require("data.table")


# Connection à la BD POSTGRES ---------------------------------------------

# mot de passe
pw <- "pgadmin"

# chargement du driver PostgreSQL
drv <- dbDriver("PostgreSQL")

# connection à la BD testdb
# la variable "connect" sera réutilisée pour chaque connection

connect <- dbConnect(drv, dbname = "testdb", host = "localhost", port = 5432,
                     user = "postgres", password = pw)
rm(pw) # enlève le mot de passe


# Récupération des noms d'espèces par requête -----------------------------

reqEspeces <- getSQL("especes_tableau_ref_species.sql")
especesBD <- dbGetQuery(connect, reqEspeces)
especesBD$code_ccbio <- as.character(especesBD$code_ccbio)


# Doublons ----------------------------------------------------------------

# vérification des lignes de la table où les codes CCBIO sont dupliqués
doublons <- especesBD[(duplicated(especesBD$code_ccbio) | duplicated(especesBD$code_ccbio, fromLast = TRUE)),]
doublons <- doublons[order(doublons$code_ccbio),]
colnames(doublons) <- toupper(colnames(doublons))  # mise en majuscule des titres de colonnes
write.csv(doublons, "doublons.csv")  # écriture du fichier pour impression et consultation 

# Corrections -------------------------------------------------------------
# Cette opération est faite manuellement avec la liste des codes ccbio existants (codeESSoriginal.csv) et 
# le fichier des doublons créé dans la section précédente

# correction des doublons
especesBD$code_ccbio[11] <- "Acsaci"
especesBD$code_ccbio[36] <- "Cacars"
especesBD$code_ccbio[46] <- "Caoval"
especesBD$code_ccbio[126] <- "Piglau"
especesBD$code_ccbio[127] <- "Piglab"
especesBD$code_ccbio[133] <- "Picpun"
especesBD$code_ccbio[174] <- "Qumarg"
especesBD$code_ccbio[175] <- "Qumari"
especesBD$code_ccbio[195] <- "Saalba"

# recherche des espèces non désirées

liste <- c(1:nrow(especesBD))
liste <- liste[-sort(c(184))]

# retrait des espèces non désirées

especesBD <- especesBD[liste,]

# Merge avec les equivalents francais -------------------------------------

especesFR <- fread("liste_especes_francais_mod.csv", na.strings = c("", "NA"))
colnames(especesFR) <- tolower(colnames(especesFR))  # mise en minuscule des titres de colonnes
tableEquival <- merge(especesBD, especesFR, by="code_ccbio", all = TRUE)

# Transformation des NA en cases vides (dans le but de produire un fichier Excel et car Excel ne supporte pas "NA" comme R le fait)
tableEquivalSansNA <- sapply(tableEquival, as.character)
tableEquivalSansNA[is.na(tableEquivalSansNA)] <- ""
tableEquivalSansNA <- as.data.frame(tableEquivalSansNA)

# Écriture du fichier texte
write.csv(tableEquivalSansNA, "table_des_equivalences_especes.csv", row.names = FALSE)

# Changements apportes aux codes ccbio ------------------------------------

especesOriginalFR <- fread("codeESSoriginal.csv")
colnames(especesOriginalFR) <- tolower(colnames(especesOriginalFR))  # mise en minuscule des titres de colonnes
comparaisonCodes <- match(especesOriginalFR$code_ccbio, especesFR$code_ccbio, nomatch = 999)
comparaisonNoms <- match(especesOriginalFR$nom_latin, especesFR$nom_latin, nomatch = 999)
changementsCodes <- grep("999", comparaisonCodes)
changementsNoms <- grep("999", comparaisonNoms)
modificationsCodes <- especesOriginalFR[changementsCodes,]
modificationsNoms <- especesOriginalFR[changementsNoms,]

# cette table (tableModifications) ne soulève que les entrées dans la table des codes d'espèces où
# il y a eu des changements. La nature exacte des changements est explicitée dans 
# le fichier:  modifications_codes_ccbio.txt

tableModifications <- merge(modificationsCodes, modificationsNoms, all = TRUE)
rm(modificationsCodes, modificationsNoms)

# Déconnection ------------------------------------------------------------

killDbConnections()


