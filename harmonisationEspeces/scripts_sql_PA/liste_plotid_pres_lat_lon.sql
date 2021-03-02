DROP TABLE IF EXISTS liste_plotid_pres_lat_lon;

CREATE TABLE liste_plotid_pres_lat_lon AS
SELECT liste_plotid_pres.statecd, 
liste_plotid_pres.countycd, 
liste_plotid_pres.plot, 
liste_plotid_pres.invyr,
liste_plotid_pres.plotid,
lat_lon_plot.lat,
lat_lon_plot.lon,
liste_plotid_pres.nom_table, 
liste_plotid_pres.spcd, 
liste_plotid_pres.Presence 
FROM liste_plotid_pres
JOIN (SELECT plot.statecd,
      plot.countycd, 
      plot.plot, plot.lat, 
      plot.lon 
      FROM fs_fiadb.plot) AS lat_lon_plot 
    ON lat_lon_plot.statecd = liste_plotid_pres.statecd
    AND lat_lon_plot.countycd = liste_plotid_pres.countycd
    AND lat_lon_plot.plot = liste_plotid_pres.plot
ORDER BY 1, 2, 3, 4;