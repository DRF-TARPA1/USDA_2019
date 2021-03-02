SELECT CONCAT(SUBSTRING(genus FROM 1 FOR 2), SUBSTRING(species FROM 1 FOR 3)) AS code_ccbio, genus, species, common_name, species_symbol, spcd, nb_parcelles, lat_max FROM 
	(SELECT genus, species, common_name, ref_species.species_symbol, ref_species.spcd, ref_species.variety, ref_species.subspecies, nb_parcelles, lat_max FROM fs_fiadb.ref_species 
		JOIN (SELECT DISTINCT spcd, count(plot) AS nb_parcelles, max(lat) AS lat_max FROM 
				(SELECT spcd, plot.plot, plot.lat FROM   
					(SELECT DISTINCT spcd, plot from fs_fiadb.tree
					WHERE statecd = 1 
					OR statecd = 5
					OR statecd = 9
					OR statecd = 10
					OR statecd = 11
					OR statecd = 12
					OR statecd = 13
					OR statecd = 17
					OR statecd = 18
					OR statecd = 19
					OR statecd = 21
					OR statecd = 23
					OR statecd = 24
					OR statecd = 25
					OR statecd = 26
					OR statecd = 27
					OR statecd = 28
					OR statecd = 29
					OR statecd = 33
					OR statecd = 34
					OR statecd = 36
					OR statecd = 37
					OR statecd = 39
					OR statecd = 42
					OR statecd = 44
					OR statecd = 45
					OR statecd = 47
					OR statecd = 50
					OR statecd = 51
					OR statecd = 54
					OR statecd = 55) AS select_tree 
				JOIN fs_fiadb.plot ON (select_tree.plot = plot.plot) GROUP BY spcd, plot.plot, plot.lat) 
		AS jointure_plot 
		GROUP BY spcd)
	AS plot_lat_calc ON (ref_species.spcd = plot_lat_calc.spcd)
	WHERE ref_species.subspecies = ''
	AND ref_species.variety = ''
	AND species != 'spp.') 
AS select_total
ORDER BY code_ccbio ASC;