REM Script pour copier les tables importées dans la BD postgresql vers des fichiers csv dans le but de 
REM comparer les valeurs après importation avec celles dans les fichiers csv avant l'importation 

set PATH=%PATH%;C:\Program Files\PostgreSQL\10\bin

psql -h localhost -p 5432 -U postgres -d testdb -f "%cd%\exportTables.sql"
