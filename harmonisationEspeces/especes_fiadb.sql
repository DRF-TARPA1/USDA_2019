SELECT * FROM 
(SELECT genus AS usda_genus, species AS usda_species, CONCAT(SUBSTRING(genus FROM 1 FOR 2), SUBSTRING(species FROM 1 FOR 3)) AS usda_cc_bio, 
symbol_type AS usda_symbol_type, symbol AS usda_symbol, spcd AS usda_code, scientific_name as usda_scientific_name, new_symbol AS usda_new_symbol, 
new_scientific_name AS usda_new_scientific_name FROM 
	(SELECT symbol_type, symbol, scientific_name, new_symbol, new_scientific_name, common_name, genus, species 
         FROM fs_fiadb.ref_plant_dictionary
         WHERE genus != ''
         AND species != '') 
	AS plant_ccbio LEFT JOIN (SELECT spcd, species_symbol FROM fs_fiadb.ref_species)
               AS code_ref_species
               ON (plant_ccbio.symbol = code_ref_species.species_symbol))
               AS select_total
ORDER BY usda_genus, usda_species ASC;
