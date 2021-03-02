Voici la procédure à suivre pour créer le tableau de présence absence:

1) Exécuter "liste_plotid_pres.sql" (1 min.)
	- crée la liste de toutes combinaisons parcelle-espèce pour chaque année d'inventaire
	
2) Exécuter "liste_plotid_pres_lat_lon.sql" (1 min.)
	- fait la jointure entre la table précédente et la table plot pour obtenir les coordonnées de la parcelle
	
3) Exécuter "tableau_PA.sql" (1 min.)
	- requête qui fait la création de la crosstab qui contient les présences-absences
	- cette requête est générée à partir de la fonction "xtab"
		-- Le code de la fonction xtab est contenu dans "code_fonction_xtab.sql"
		-- l'appel à la fonction xtab est écrit dans "appel_fonction_xtab.sql"
		-- la fonction est utilisée pour générer la requête sans avoir à spécifier manuellement le nom de chaque colonne qui est pivotée

4) Exécuter "tableau_PA_complet.sql" (entre 35-40 min.)
	- fait la jointure entre la table de présence absence et les attributs de chaque parcelle
	- Produit final