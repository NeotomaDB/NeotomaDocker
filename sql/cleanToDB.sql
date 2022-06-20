-- For some reason the samples don't have a cascade on datasets.
    ALTER TABLE ndb.samples
        DROP CONSTRAINT fk_samples_datasets;
    ALTER TABLE ndb.samples
        ADD CONSTRAINT fk_samples_datasets
        FOREIGN KEY (datasetid) REFERENCES ndb.datasets(datasetid) ON DELETE CASCADE;
-- We also have an issue with specimen dates:
    ALTER TABLE ndb.specimendates
        DROP CONSTRAINT sd_smpid;
    ALTER TABLE ndb.specimendates
        ADD CONSTRAINT sd_smpid
        FOREIGN KEY (sampleid) REFERENCES ndb.samples(sampleid) ON DELETE CASCADE;
-- And in geochronologies:
    ALTER TABLE ndb.geochroncontrols
        DROP CONSTRAINT fk_geochroncontrols_geochronology;
    ALTER TABLE ndb.geochroncontrols
        ADD CONSTRAINT fk_geochroncontrols_geochronology
        FOREIGN KEY (geochronid) REFERENCES ndb.geochronology(geochronid) ON DELETE CASCADE;
-- And in specimen dates:
    ALTER TABLE ndb.specimendates
        DROP CONSTRAINT sd_gcid;
    ALTER TABLE ndb.specimendates
        ADD CONSTRAINT sd_gcid
        FOREIGN KEY (geochronid) REFERENCES ndb.geochronology(geochronid) ON DELETE CASCADE;
-- Then delete the dataset entries that aren't associated with the database of interest: 
    DELETE FROM ndb.datasets
    WHERE datasetid = ANY(SELECT datasetid FROM ndb.datasetdatabases WHERE NOT databaseid = :dbid);
-- We need to cleanup sites & collectionunits at this point:
-- Alter the chroncontrols for deleting collectionunits
    ALTER TABLE ndb.chroncontrols
        DROP CONSTRAINT fk_geochroncontrols_chroncontrols;
    ALTER TABLE ndb.geochroncontrols
        ADD CONSTRAINT fk_geochroncontrols_chroncontrols
        FOREIGN KEY (chroncontrolid) REFERENCES ndb.chroncontrols(chroncontrolid) ON DELETE CASCADE;
    ALTER TABLE ndb.chroncontrols
        DROP CONSTRAINT fk_chroncontrols_analysisunits;
    ALTER TABLE ndb.chroncontrols
        ADD CONSTRAINT fk_chroncontrols_analysisunits
        FOREIGN KEY (analysisunitid) REFERENCES ndb.analysisunits(analysisunitid) ON DELETE CASCADE;
-- Alter the chroncontrols for deleting collectionunits
    ALTER TABLE ndb.chroncontrols
        DROP CONSTRAINT fk_chroncontrols_analysisunits;
    ALTER TABLE ndb.chroncontrols
        ADD CONSTRAINT fk_chroncontrols_analysisunits
        FOREIGN KEY (analysisunitid) REFERENCES ndb.analysisunits(analysisunitid) ON DELETE CASCADE;
-- Alter
    ALTER TABLE ndb.eventchronology
        DROP CONSTRAINT evc_alu;
    ALTER TABLE ndb.eventchronology
        ADD CONSTRAINT evc_alu
        FOREIGN KEY (analysisunitid) REFERENCES ndb.analysisunits(analysisunitid) ON DELETE CASCADE;
-- Alter
    ALTER TABLE ndb.eventchronology
        DROP CONSTRAINT evc_ccid;
    ALTER TABLE ndb.eventchronology
        ADD CONSTRAINT evc_ccid
        FOREIGN KEY (chroncontrolid) REFERENCES ndb.chroncontrols(chroncontrolid) ON DELETE CASCADE;
-- Alter
    ALTER TABLE ndb.tephras
        DROP CONSTRAINT fk_tephras_analysisunits;
    ALTER TABLE ndb.tephras
        ADD CONSTRAINT fk_tephras_analysisunits
        FOREIGN KEY (analysisunitid) REFERENCES ndb.analysisunits(analysisunitid) ON DELETE CASCADE;
-- Alter
    ALTER TABLE ndb.samples
        DROP CONSTRAINT fk_samples_analysisunits;
    ALTER TABLE ndb.samples
        ADD CONSTRAINT fk_samples_analysisunits
        FOREIGN KEY (analysisunitid) REFERENCES ndb.analysisunits(analysisunitid) ON DELETE CASCADE;
-- Alter
    ALTER TABLE ndb.depagents
        DROP CONSTRAINT fk_depagents_analysisunits;
    ALTER TABLE ndb.depagents
        ADD CONSTRAINT fk_depagents_analysisunits
        FOREIGN KEY (analysisunitid) REFERENCES ndb.analysisunits(analysisunitid) ON DELETE CASCADE;
-- Alter
    ALTER TABLE ndb.relativechronology
        DROP CONSTRAINT fk_relativechronology_analysisunits;
    ALTER TABLE ndb.relativechronology
        ADD CONSTRAINT fk_relativechronology_analysisunits
        FOREIGN KEY (analysisunitid) REFERENCES ndb.analysisunits(analysisunitid) ON DELETE CASCADE;
-- Alter
    ALTER TABLE ndb.analysisunitaltdepths
        DROP CONSTRAINT fk_analysisunitaltdepths_analysisunits;
    ALTER TABLE ndb.analysisunitaltdepths
        ADD CONSTRAINT fk_analysisunitaltdepths_analysisunits
        FOREIGN KEY (analysisunitid) REFERENCES ndb.analysisunits(analysisunitid) ON DELETE CASCADE;
-- Alter
    ALTER TABLE ndb.accumulationrates
        DROP CONSTRAINT fk_accumulationrates_analysisunits;
    ALTER TABLE ndb.accumulationrates
        ADD CONSTRAINT fk_accumulationrates_analysisunits
        FOREIGN KEY (analysisunitid) REFERENCES ndb.analysisunits(analysisunitid) ON DELETE CASCADE;
-- Then delete:
    DELETE FROM ndb.collectionunits
    WHERE NOT collectionunitid = ANY(SELECT collectionunitid FROM ndb.datasets);
-- Then Delete sites:
    DELETE FROM ndb.sites
    WHERE NOT siteid = ANY(SELECT siteid FROM ndb.collectionunits);
-- CLean up publications:
    WITH pubids AS (
        SELECT publicationid FROM ndb.taxa
        UNION
        SELECT publicationid FROM ndb.datasetpublications
        UNION
        SELECT publicationid FROM ndb.calibrationcurves
        UNION
        SELECT publicationid FROM ndb.eventpublications
        UNION
        SELECT publicationid FROM ndb.externalpublications
        UNION
        SELECT publicationid FROM ndb.synonymy
        UNION
        SELECT publicationid FROM ndb.formtaxa
    )
    DELETE FROM
        ndb.publications AS pu
        WHERE pu.publicationid != ALL((SELECT DISTINCT publicationid FROM pubids WHERE publicationid IS NOT NULL));
-- Managing Contacts Now, first temporarily disable the triggers:
BEGIN;
SET session_replication_role = replica;
WITH contids AS (
    SELECT validatorid AS contactid FROM ndb.taxa
    UNION
    SELECT contactid FROM ndb.sampleanalysts
    UNION
    SELECT contactid FROM ndb.dataprocessors
    UNION
    SELECT contactid FROM ndb.datasetpis
    UNION
    SELECT contactid FROM ndb.datasetsubmissions
    UNION
    SELECT contactid FROM ndb.publicationauthors
    UNION
    SELECT contactid FROM ndb.synonymy
    UNION
    SELECT contactid FROM ndb.collectors
    UNION
    SELECT contactid FROM ndb.chronologies
    UNION
    SELECT contactid FROM ndb.constituentdatabases
)
DELETE FROM
    ndb.contacts AS ct
    WHERE ct.contactid != ALL((SELECT DISTINCT contactid FROM contids WHERE contactid IS NOT NULL));
-- Now restore the contact triggers:
SET session_replication_role = DEFAULT;
COMMIT;
