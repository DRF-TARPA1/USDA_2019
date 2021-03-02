/*  Fichier SQL de création de l'architecture de la base de données vascan
    
    But: Créer tablespace, base de données, extension, shéma et tables 
        (avec contraintes) nécessaires à recevoir les données du vascan
        
    Executer les sections manuellement en copiant leur contenu dans le query tool de postgres
    
    Les sections 1-9 doivent etre executees dans la base de donnees 'Postgres'
    Les sections 10 et plus doivent etre executees dans la base de donnees 'db_DRF' schema 'vascan'
    
*/

-- Section 1

-- Création du TABLESPACE pour les donnees de la DRF
CREATE TABLESPACE "tbsDRF"
OWNER postgres
LOCATION 'D:\tbsDRF';

-- Section 2

ALTER TABLESPACE "tbsDRF"
OWNER TO postgres;
COMMENT ON TABLESPACE "tbsDRF"
IS 'Tablespace des données de la DRF';

-- Création de la dB vascan pour les projets
-- -- object: db_DRF | type: DATABASE --

-- Section 3

DROP DATABASE IF EXISTS "db_DRF"

-- Section 4

CREATE DATABASE "db_DRF" 
WITH 
OWNER = postgres
TABLESPACE "tbsDRF"
ENCODING = 'UTF8'
CONNECTION LIMIT = -1;

-- Section 5

COMMENT ON DATABASE "db_DRF"
IS 'Base de données de la DRF';

-- Section 6

CREATE EXTENSION postgis; 

-- Création du schema: vascan

-- Section 7

DROP SCHEMA IF EXISTS db_DRF.vascan CASCADE;

-- Section 8

CREATE SCHEMA vascan AUTHORIZATION postgres;

-- Section 9

COMMENT ON SCHEMA vascan
    IS 'dB du VASCAN liste des essences vasculaires';

SET search_path TO pg_catalog,public,vascan;


-- Section 10

-------------------------------------------------------------------
-- Creation des tables pour la donnee du VASCAN --

-- object: vascan.taxon | type: TABLE --

DROP TABLE IF EXISTS vascan.taxon CASCADE;
CREATE TABLE vascan.taxon(
	id varchar(100),
	taxonID varchar(100),
	acceptedNameUsageID varchar(100), 
	parentNameUsageID varchar(100), 
	nameAccordingToID varchar(150),
	scientificName varchar(120),
	acceptedNameUsage varchar(150),
	parentNameUsage varchar(100),
	nameAccordingTo text,
	higherClassification text,
  class varchar(150),
	plantOrder varchar(150),
	family varchar(150),
	genus varchar(150),
	subgenus varchar(150),
	specificEpiteth varchar(100),
	infraspecificEpithet varchar(100),
	taxonRank varchar(50),
	scientificNameAuthorship varchar(100),
	taxonomicStatus varchar(50),
	modified time,
	license varchar(100),
	bibliographicCitation text,
	plantReferences varchar(50)
);

ALTER TABLE vascan.taxon OWNER TO postgres;
COMMENT ON COLUMN vascan.taxon.id 
    IS 'A unique identifier for the taxon record';
COMMENT ON COLUMN vascan.taxon.taxonID 
    IS 'An identifier for the set of taxon information (data associated with the Taxon class). May be a global unique identifier or an identifier specific to the data set';
COMMENT ON COLUMN vascan.taxon.acceptedNameUsageID 
    IS 'An identifier for the name usage (documented meaning of the name according to a source) of the currently valid (zoological) or accepted (botanical) taxon';
COMMENT ON COLUMN vascan.taxon.parentNameUsageID 
    IS 'An identifier for the name usage (documented meaning of the name according to a source) of the direct, most proximate higher-rank parent taxon (in a classification) of the most specific element of the scientificName';
COMMENT ON COLUMN vascan.taxon.nameAccordingToID 
    IS 'An identifier for the source in which the specific taxon concept circumscription is defined or implied. See nameAccordingTo';
COMMENT ON COLUMN vascan.taxon.scientificName 
    IS 'The full scientific name, with authorship and date information if known. When forming part of an Identification, this should be the name in lowest level taxonomic rank that can be determined. This term should not contain identification qualifications, which should instead be supplied in the IdentificationQualifier term';
COMMENT ON COLUMN vascan.taxon.acceptedNameUsage 
    IS 'The full name, with authorship and date information if known, of the currently valid (zoological) or accepted (botanical) taxon';
COMMENT ON COLUMN vascan.taxon.parentNameUsage 
    IS 'The full name, with authorship and date information if known, of the direct, most proximate higher-rank parent taxon (in a classification) of the most specific element of the scientificName';
--COMMENT ON TABLE vascan.taxon.nameAccordingTo
--    IS 'The reference to the source in which the specific taxon concept circumscription is defined or implied - traditionally signified by the Latin "sensu" or "sec." (from secundum, meaning "according to"). For taxa that result from identifications, a reference to the keys, monographs, experts and other sources should be given';
COMMENT ON COLUMN vascan.taxon.higherClassification 
    IS 'A list (concatenated and separated) of taxa names terminating at the rank immediately superior to the taxon referenced in the taxon record';
COMMENT ON COLUMN vascan.taxon.plantOrder 
    IS 'The full scientific name of the order in which the taxon is classified';
COMMENT ON COLUMN vascan.taxon.family 
    IS 'The full scientific name of the family in which the taxon is classified';
COMMENT ON COLUMN vascan.taxon.genus 
    IS 'The full scientific name of the genus in which the taxon is classified';
COMMENT ON COLUMN vascan.taxon.subgenus 
    IS 'The full scientific name of the subgenus in which the taxon is classified';
COMMENT ON COLUMN vascan.taxon.specificEpiteth
    IS 'The name of the first or species epithet of the scientificName';
COMMENT ON COLUMN vascan.taxon.infraspecificEpithet
    IS 'The name of the lowest or terminal infraspecific epithet of the scientificName, excluding any rank designation';
COMMENT ON COLUMN vascan.taxon.taxonRank
    IS 'The taxonomic rank of the most specific name in the scientificName';
COMMENT ON COLUMN vascan.taxon.scientificNameAuthorship
    IS 'The authorship information for the scientificName formatted according to the conventions of the applicable nomenclaturalCode';
COMMENT ON COLUMN vascan.taxon.taxonomicStatus
    IS 'The status of the use of the scientificName as a label for a taxon. Requires taxonomic opinion to define the scope of a taxon. Rules of priority then are used to define the taxonomic status of the nomenclature contained in that scope, combined with the experts opinion. It must be linked to a specific taxonomic reference that defines the concept';
COMMENT ON COLUMN vascan.taxon.modified
    IS 'The most recent date-time on which the resource was changed';
COMMENT ON COLUMN vascan.taxon.license
    IS 'A legal document giving official permission to do something with the resource';
COMMENT ON COLUMN vascan.taxon.bibliographicCitation
    IS 'A bibliographic reference for the resource as a statement indicating how this record should be cited (attributed) when used.';
COMMENT ON COLUMN vascan.taxon.plantReferences
    IS 'A related resource that is referenced, cited, or otherwise pointed to by the described resource';
-------------------------------------------------

-- object: vascan.vernacularname | type: TABLE --

DROP TABLE IF EXISTS vascan.vernacularname CASCADE;
CREATE TABLE vascan.vernacularname(
	coreid varchar(100),
	vernacularName varchar(100),
	source text,
	language char(2),
	isPreferredName boolean
);

ALTER TABLE vascan.vernacularname OWNER TO postgres;

COMMENT ON TABLE vascan.vernacularname 
    IS 'Table of common or vernacular names';

-------------------------------------------------

-- object: vascan.distribution | type: TABLE --

DROP TABLE IF EXISTS vascan.distribution CASCADE;
CREATE TABLE vascan.distribution(
coreid varchar(100),
	locationID char(150),
	locality varchar(50),
	countryCode varchar(5),
	occurrenceStatus varchar(50),
	establishmentMeans varchar(50),
	source text,
	occurrenceRemarks varchar(50)
);

ALTER TABLE vascan.distribution OWNER TO postgres;

COMMENT ON TABLE vascan.distribution 
    IS 'Table of the distribution of vascular plants';

-------------------------------------------------

-- object: vascan.resourcerelationship | type: TABLE --

DROP TABLE IF EXISTS vascan.resourcerelationship CASCADE;
CREATE TABLE vascan.resourcerelationship(
	coreid varchar(100),
    relatedresourceid varchar(100),
	relationshipofresource varchar(50)
);

ALTER TABLE vascan.resourcerelationship OWNER TO postgres;

COMMENT ON TABLE vascan.resourcerelationship 
    IS 'Table of the relationships between vascular plants';

-------------------------------------------------

-- object: vascan.description | type: TABLE --

DROP TABLE IF EXISTS vascan.description CASCADE;
CREATE TABLE vascan.description(
	coreid varchar(100),
	description varchar(50),
	type varchar(50)
);

ALTER TABLE vascan.description OWNER TO postgres;

COMMENT ON TABLE vascan.description 
    IS 'Table of the description of vascular plants';


-- Section 11

-- Copie des fichiers de données dans les tables --

COPY vascan.taxon FROM 'D:/ProjetEspeces/vascan/dwca-vascan-v37.6/taxon.txt'; 
COPY vascan.vernacularname FROM 'D:/ProjetEspeces/vascan/dwca-vascan-v37.6/vernacularname.txt';
COPY vascan.distribution FROM 'D:/ProjetEspeces/vascan/dwca-vascan-v37.6/distribution.txt';
COPY vascan.relationshipofresource FROM 'D:/ProjetEspeces/vascan/dwca-vascan-v37.6/relationshipofresource.txt';
COPY vascan.description FROM 'D:/ProjetEspeces/vascan/dwca-vascan-v37.6/description.txt';
