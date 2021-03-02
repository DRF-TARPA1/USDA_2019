
# Fonctions ---------------------------------------------------------------

# Titre: getSQL
#
# Auteur: "Matt Jewett"
# Source: https://stackoverflow.com/questions/44853322/how-to-read-the-contents-of-an-sql-file-into-an-r-script-to-run-a-query
# 
# But: Formatter les requêtes SQL qui proviennent de fichiers .sql en une chaine de caractères utilisable dans R 
# (permet d'utiliser une requête provenant d'un fichier SQL comme argument dans une fonction du package RPostgreSQL)
# 
# Paramètre d'entrée: filepath -- chemin vers le fichier .sql contenant la requête à traiter
# 
# Paramètre de sortie: sql.string -- chaine de caractères contenant la requête
# 
getSQL <- function(filepath)
{
  con = file(filepath, "r")
  sql.string <- ""
  
  while ( TRUE )
  {
    line <- readLines(con, n = 1)
    if ( length(line) == 0 ) { break }
    
    line <- gsub("\\t", " ", line)
    
    if(grepl("--",line) == TRUE)
    {
      line <- paste(sub("--","/*",line),"*/")
    }
    
    sql.string <- paste(sql.string, line)
  }
  
  close(con)
  return(sql.string)
}


# Titre: killDbConnections
# 
# Auteur: "ThankGoat"
# Source: Adaptation RPostgreSQL de la fonction suivante (originalement conçue pour RMySQL)
# https://stackoverflow.com/questions/32139596/cannot-allocate-a-new-connection-16-connections-already-opened-rmysql
# 
# But: Terminer les connection établies avec la base de données Postgresql
# 
# Paramètre d'entrée: Aucun
# 
# Paramètre de sortie: Aucun, imprime la liste de connection qui ont été teminées
# 
killDbConnections <- function () {
  
  all_cons <- dbListConnections(PostgreSQL())
  
  if (length(all_cons) > 0){
    print(all_cons)
  }
  
  for(con in all_cons)
    +  dbDisconnect(con)
  
  print(paste(length(all_cons), " connections killed."))
  
}


# Titre: getSQLTableTypes
# 
# Auteur: Jean-Michel St-Pierre
# 
# But: Determiner la chaine de caractères des types R associés à une table postgres à partir du fichier createTable SQL du USDA-FIA
# 
# Paramètres d'entrée: - cheminFichier : string contenant le path vers le fichier ".sql"
# 
# Paramètre de sortie: - extrant : dataframe 1X2 qui contient le nom de la table (col. 1) et la string des types (col. 2)
# 
getSQLTableTypes <- function(cheminFichier) {
  repertoire <- unlist(strsplit(cheminFichier, "/"))
  repertoire <- paste(repertoire[1:(length(repertoire) - 1)], collapse = "/")
  nom_sql <- gsub(paste0(repertoire, "/"), "", cheminFichier)
  nom_table <- gsub(paste0(repertoire, "/Create"), "", cheminFichier) %>%  gsub(".sql", "", .) %>% tolower(.)
  
  
  sqlstr <- getSQL(cheminFichier)
  sql_split <- str_split(sqlstr, pattern = ";")
  sql_split <- sql_split[[1]][1]
  
  query_split <- str_split(sql_split, pattern = " ")
  commandes <- vector()
  for (i in 1:length(query_split[[1]])) {
    if(query_split[[1]][i] != ""){
      commandes <- append(commandes, query_split[[1]][i]) 
    }
  }
  nom_col <- c()
  extrant <- data.frame(Table=character(1), Types=character(1), stringsAsFactors=FALSE)
  str_classes <- ""
  type_col <- ""
  position_debut <- grep("\\(", commandes)[1]
  if(commandes[(position_debut - 2)] == "table") {
    if (commandes[length(commandes)] == ")"){
      commandes <- commandes[(position_debut + 1):(length(commandes)-1)]
    } else {
      commandes <- commandes[(position_debut + 1):(length(commandes))]
    }
    pos_nom_champs <- c(1, (grep(",$", commandes) + 1))
    pos_nom_champs_types <- sort(c(pos_nom_champs, (pos_nom_champs + 1)))
    commandes <- commandes[pos_nom_champs_types]
    for (i in 1:length(commandes)) {
      if (i %% 2 != 0) {
        nom_col <- append(nom_col, commandes[i]) # pour future utilisation
      } else {
        if(grepl("CHAR", commandes[i])){
          type_col <- "c"
        } 
        else if(grepl("INT", commandes[i])){
          type_col <- "i"
        } 
        else if(grepl("DOUBLE", commandes[i])){
          type_col <- "d"
        } 
        else if(grepl("TIMESTAMP", commandes[i])){
          type_col <- "D"
        } 
        else if(grepl("DECIMAL", commandes[i])){
          type_col <- "d"
        } 
        else {
          type_col <- ""
        }
        str_classes <- paste0(str_classes, type_col)
      }
    }
    extrant[1,1] <- nom_table
    extrant[1,2] <- str_classes
  } else{
    cat(paste0(cheminFichier, " n'est un script 'createTable'"))
  }
  return(extrant)
}


# Title: getScriptsNames
# 
# Author: Jean-Michel St-Pierre
# 
# Objective: Extract the names of scripts called by the batch scripts of the usda
# 
# Input : filepath - path to the script to parse
# 
# Output : calledScriptName - verctor containing all the names of called scripts


getScriptsNames <- function(filepath) {
  file <- read_lines(filepath, progress = FALSE)
  if (length(file) == 0){
    cat("Invalid filepath\n")
  } else {
    calledScriptName <- c()
    for (i in 1:length(file)) {
      a <- str_split(file[i], " ")[[1]][9] %>% str_split(., "/") %>% unlist() %>% .[3]
      if (a %like% "^Create"){
        calledScriptName <- gsub("Create|.sql", "", a) %>% tolower(.) %>% append(calledScriptName, .)
      }
    }
  }
  return(calledScriptName)
}



# Title: setEncoding
# 
# Author: adapted from https://stackoverflow.com/questions/21392786/utf-8-unicode-text-encoding-with-rpostgresql
# 
# Objective: Encode character entries within dataframe with the desired character encoding 
# 
# Input : x         - a dataframe containing entries to encode
#         encoding  - a string specifying the desired encoding
# 
# Output : x - the now encoded dataframe


setEncoding <- function(x, encoding) {
  # select character columns
  chr <- sapply(x, is.character)
  # apply UTF-8 encoding 
  x[, chr] <- lapply(x[, chr, drop = FALSE], `Encoding<-`, encoding)
  # apply encoding to column names
  Encoding(names(x)) <- encoding
  return(x)
}

# Title: str2VectorTypes
# 
# Author: Jean-Michel St-Pierre
# 
# Objective: Recuperate compact types string (like produced in function getSQLTypes) 
# and convert it into a vector of types for R
# 
# Input : string       - string of compact types to convert
#         vectorTypes  - a vector containing the types corresponding to those of the input string 
# 
# Output : x - the now encoded dataframe

str2VectorTypes <- function(string){
  string <- unlist(str_split(string, pattern = ""))
  vectorTypes <- c()
  for (i in 1:length(string)) {
    if(string[i] == "c") {
      vectorTypes <- append(vectorTypes, "character")
    } else if (string[i] == "i") {
      vectorTypes <- append(vectorTypes, "integer")
    } else if (string[i] == "d") {
      vectorTypes <- append(vectorTypes, "double")
    } else if (string[i] == "D") {
      vectorTypes <- append(vectorTypes, "date")
    } 
  }
  return(vectorTypes)
}
