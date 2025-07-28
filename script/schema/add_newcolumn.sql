--liquibase formatted sql
--changeset naila-alissa:1-schema-add_newcolumn context:schema-1 labels:add_newcolumn
--comment: Change generated for add_newcolumn.sql in schema
ALTER TABLE test_table ADD Provins VARCHAR(250);
--rollback: ROLLBACK COMMAND FOR add_newcolumn

