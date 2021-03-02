DROP TABLE IF EXISTS tableau_PA_complet;

CREATE TABLE tableau_PA_complet AS
SELECT distinct * FROM tableau_presence_absence
INNER JOIN (SELECT statecd, countycd, plot, invyr, lon, lat, nom_table, plotid AS ident FROM liste_plotid_pres_lat_lon) AS attributs_colonne
ON tableau_presence_absence.plotid = attributs_colonne.ident
ORDER BY statecd, countycd, plot, invyr, lon, lat, nom_table