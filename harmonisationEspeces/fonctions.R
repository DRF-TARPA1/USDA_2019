
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
  
  print(all_cons)
  
  for(con in all_cons)
    +  dbDisconnect(con)
  
  print(paste(length(all_cons), " connections killed."))
  
}
