REM -- Changement de l'encodage pour les sorties de scripts
chcp 1252 

REM -- le script sera lu par R et le parametre "pourcent s" sera remplace par un string avec sprintf
CD %s

REM -- Modification des permissions des dossiers de données
cacls ..\CSV_DATA /t /e /g "Tout le monde":f
cacls ..\CSV_PERM /t /e /g "Tout le monde":f
cacls ..\evalidatorFunctions /t /e /g "Tout le monde":f
cacls ..\..\ExportTables /t /e /g "Tout le monde":f

REM -- Appel des scripts de la FIADB pour l'importation des données dans la BD
call "createTables.bat" > ..\ScriptOutputs\output_create_tables.txt 2> ..\ScriptOutputs\output_create_tables_erreur.txt | "%s\psql" -h localhost -p 5432 -U postgres -d testdb
call "loadReferenceTables.bat" > ..\ScriptOutputs\output_load_reference_tables.txt 2> ..\ScriptOutputs\output_load_reference_tables_erreur.txt | "%s\psql" -h localhost -p 5432 -U postgres -d testdb
call "loadDataTablesEntire.bat" > ..\ScriptOutputs\output_load_data_tables_entire.txt 2> ..\ScriptOutputs\output_load_data_tables_entire_erreur.txt | "%s\psql" -h localhost -p 5432 -U postgres -d testdb

echo Importation terminee!