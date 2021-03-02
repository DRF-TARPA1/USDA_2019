# nettoyage et appel de gc()
rm(list = ls())
invisible(gc())

# chargement des fonctions
# source("./fonctions.R")

# chargement des packages 
# chargement des packages 
listePackages <-
  c("DBI",
    "dbplyr",
    "odbc",
    "RPostgreSQL",
    "tidyverse",
    "stringi",
    "dbplot",
    "devtools",
    "compare",
    "data.table",
    "R.utils", 
    "parsedate",
    "pryr",
    "lubridate",
    "sf",
    "RQGIS",
    "testthat",
    "rmarkdown",
    "shiny",
    "getPass")
packagesAInstaller <-
  listePackages[!(listePackages %in% installed.packages()[, "Package"])]
if (length(packagesAInstaller) > 0)
  install.packages(packagesAInstaller)

require("DBI")
require("dbplyr")
require("odbc")
require("RPostgreSQL")
require("tidyverse")
require("dbplot")
require("devtools")
require("compare")
require("data.table")
require("R.utils")
require("parsedate")
require("pryr")
require("lubridate")
require("sf")
require("RQGIS")
require("testthat")
require("rmarkdown")
require("shiny")
require("getPass")
require("stringi")
