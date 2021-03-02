DROP TABLE IF EXISTS liste_plotid_pres;

CREATE TABLE liste_plotid_pres AS
SELECT statecd, countycd, plot, invyr, nom_table, concat_ws('_', statecd, countycd, plot, invyr, nom_table) AS plotid, concat('_', spcd) AS spcd, 1 AS Presence
FROM
	((SELECT DISTINCT statecd, countycd, plot, to_char(spcd, 'FM0999') AS spcd, invyr, 'tree' as nom_table 
    FROM fs_fiadb.tree 
    ORDER BY statecd, countycd, plot, spcd ASC)
	UNION 
	(SELECT DISTINCT statecd, countycd, plot, to_char(spcd, 'FM0999') AS spcd, invyr, 'seedling' as nom_table 
    FROM  fs_fiadb.seedling
    ORDER BY statecd, countycd, plot, spcd ASC)
	UNION  
	(SELECT DISTINCT statecd, countycd, plot, to_char(spcd, 'FM0999') AS spcd, invyr, 'seedling_regen' as nom_table
    FROM  fs_fiadb.seedling_regen
    ORDER BY statecd, countycd, plot, spcd ASC)
    UNION  
	(SELECT DISTINCT statecd, countycd, plot, to_char(spcd, 'FM0999') AS spcd, invyr, 'sitetree' as nom_table
    FROM  fs_fiadb.sitetree
    ORDER BY statecd, countycd, plot, spcd ASC)
	) AS union_tables
    ORDER BY 1,2,3,4,5;