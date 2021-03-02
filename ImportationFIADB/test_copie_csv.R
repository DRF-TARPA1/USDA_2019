# Test pour valider l'integrite de la copie des fichiers CSV


# 1. comparaison des deux listes de fichiers ------------------------------

i <- 4

dataOG <-
  fread(
    listeFichiersCSV[i],
    na.strings = c("","NA"),
    stringsAsFactors = FALSE,
    showProgress = FALSE
  )

dataCOPY <- 
  fread(
  listeCSVCopy[i],
  na.strings = c("","NA"),
  stringsAsFactors = FALSE,
  showProgress = FALSE
)

compare(dataOG, dataCOPY)
identical(dataOG, dataCOPY)


# fin ---------------------------------------------------------------------

rm(dataOG, dataCOPY)
gc()
