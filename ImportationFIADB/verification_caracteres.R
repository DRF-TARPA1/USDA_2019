# Code qui permet de valider une serie de tables potentiellement problematiques
# 
# Ne doit pas etre executé au complet séquentiellement, non automatisé, ce script fournit
#   simplement des outils pour examiner plus attentivement des tables qui sont retourne
#   FALSE dans le Log pour deceler ce qui a posé probleme a la validation
# 
# Necessite une connexion avec la base de donnes deja instanciee 

# Liste des tables concernées ---------------------------------------------
listeNomERR <- c("ref_habtyp_descriptions", "plotsnap")

# chargement des dataframes des deux sources ------------------------------
# tableERR <- dbGetQuery(connect, sprintf("SELECT cn, countynm FROM fs_fiadb.%s ORDER BY 1", listeNomERR[2]))

# fichierERR <- read_csv(sprintf(".\\FIADB_PG_1_8_0_00\\CSV_DATA\\%s.csv", listeNomERR[2]), col_names = T, na = c("NA"), locale = locale(encoding = 'ibm850'))
# fichierERR <- fread(sprintf(".\\FIADB_PG_1_8_0_00\\CSV_DATA\\%s.csv", listeNomERR[2]), header = T, stringsAsFactors = F)
# fichierERR <- read.csv(sprintf(".\\FIADB_PG_1_8_0_00\\CSV_DATA\\%s.csv", listeNomERR[1]), header = T, stringsAsFactors = F)

# comparaison de deux CSV
csv1 <- fread(sprintf(".\\Copie\\CSV_DATA\\%s.csv", listeNomERR[1]), header = T, stringsAsFactors = F)
csv2 <- fread(sprintf(".\\FIADB_PG_1_8_0_00\\CSV_DATA\\%s.csv", listeNomERR[1]), header = T, stringsAsFactors = F)

names(csv1) <- csv1 %>%
  colnames() %>%
  tolower() %>%
  c()

names(csv2) <- csv2 %>%
  colnames() %>%
  tolower() %>%
  c()

csv1$cn <- as.character(csv1$cn)
csv1 <- csv1[order(csv1$cn),]

csv2$cn <- as.character(csv2$cn)
csv2 <- csv2[order(csv2$cn),]
# fichierERR <- fichierERR[order(fichierERR$cn, fichierERR$eval_grp_cn),]

# Comparaison -------------------------------------------------------------
champ1 <- csv1$ecosubcd
champ1 <- trimws(champ1, which = "both")
champ2 <- csv2$ecosubcd

long1 <- length(champ1)
long2 <- length(champ2)

resultats <- list()
for (i in 1:long1) {
  resultats[i] <- compare(champ1[i], champ2[i])
}

valeurs_fausses <- grep("FALSE", resultats)
length(valeurs_fausses)

# Détail ------------------------------------------------------------------
valeurs_fausses
champ1[valeurs_fausses]
champ1[1:2]
champ2[valeurs_fausses]
champ2[1:2]
fix(valeurs_fausses)

rm(fichierERR, tableERR, resultats, champF, champT, LF, LT, valeurs_fausses)
gc()

# Validation de l'identifiant de parcelle ---------------------------------
plotID <- dbGetQuery(connect, "SELECT DISTINCT statecd, countycd, plot, invyr FROM fs_fiadb.seedling_regen ORDER BY 1,2,3 ASC")

# Validation pour statecd

identState <- plotID$statecd
identStateTrim <- trimws(identState, which = "both")
diffTailleState <- list()
for (i in 1:nrow(plotID)) {
  diffTailleState[i] <- (length(identState[i]) - length(identStateTrim[i]))
}
valeursDiffState <- grep(TRUE, which(diffTailleState > 0))

# validation pour countycd

identCounty <- plotID$countycd
identCountyTrim <- trimws(identCounty, which = "both")
diffTailleCounty <- list()
for (i in 1:nrow(plotID)) {
  diffTailleCounty[i] <- (length(identCounty[i]) - length(identCountyTrim[i]))
}
valeursDiffCounty <- grep(TRUE, which(diffTailleCounty > 0))

# validation pour plot

identPlot <- plotID$plot
identPlotTrim <- trimws(identPlot, which = "both")
diffTaillePlot <- list()
for (i in 1:nrow(plotID)) {
  diffTaillePlot[i] <- (length(identPlot[i]) - length(identPlotTrim[i]))
}
valeursDiffPlot <- grep(TRUE, which(diffTaillePlot > 0))

# validation pour invyr

identInvyr <- plotID$invyr
identInvyrTrim <- trimws(identInvyr, which = "both")
diffTailleInvyr <- list()
for (i in 1:nrow(plotID)) {
  diffTailleInvyr[i] <- (length(identInvyr[i]) - length(identInvyrTrim[i]))
}
valeursDiffInvyr <- grep(TRUE, which(diffTailleInvyr > 0))


# Validation pour les especes ---------------------------------------------
# validation pour spcd de la table tree

spcdTree <- dbGetQuery(connect, "SELECT distinct spcd from fs_fiadb.tree order by 1")
spcdTrimTree <- trimws(spcdTree[[1]], which = "both")
diffTaillespcdTree <- list()
for (i in 1:nrow(spcdTree)) {
  diffTaillespcdTree[i] <- (length(spcdTree[[1]][i]) - length(spcdTrimTree[[i]]))
}
valeursDiffspcdTree <- grep(TRUE, which(diffTaillespcdTree > 0))

# validation pour la table sitetree

spcdSite <- dbGetQuery(connect, "SELECT distinct spcd from fs_fiadb.sitetree order by 1")
spcdTrimSite <- trimws(spcdSite[[1]], which = "both")
diffTaillespcdSite <- list()
for (i in 1:nrow(spcdSite)) {
  diffTaillespcdSite[i] <- (length(spcdSite[[1]][i]) - length(spcdTrimSite[[i]]))
}
valeursDiffspcdSite <- grep(TRUE, which(diffTaillespcdSite > 0))

# validation pour la table seedling

spcdSeed <- dbGetQuery(connect, "SELECT distinct spcd from fs_fiadb.seedling order by 1")
spcdTrimSeed <- trimws(spcdSeed[[1]], which = "both")
diffTaillespcdSeed <- list()
for (i in 1:nrow(spcdSeed)) {
  diffTaillespcdSeed[i] <- (length(spcdSeed[[1]][i]) - length(spcdTrimSeed[[i]]))
}
valeursDiffspcdSeed <- grep(TRUE, which(diffTaillespcdSeed > 0))

# validation pour la table seedling_regen

spcdRegen <- dbGetQuery(connect, "SELECT distinct spcd from fs_fiadb.seedling_regen order by 1")
spcdTrimRegen <- trimws(spcdRegen[[1]], which = "both")
diffTaillespcdRegen <- list()
for (i in 1:nrow(spcdRegen)) {
  diffTaillespcdRegen[i] <- (length(spcdRegen[[1]][i]) - length(spcdTrimRegen[[i]]))
}
valeursDiffspcdRegen <- grep(TRUE, which(diffTaillespcdRegen > 0))



# Traitement des fichiers avec R ------------------------------------------

fichier1 <- read_file(sprintf(".\\Copie\\CSV_DATA\\%s.csv", listeNomERR[1]))















