--liquibase formatted sql
--changeset naila-alissa:1-schema-add_column_into_table context:schema-1 labels:add_column_into_table
--comment: Change generated for add_column_into_table.sql in schema
ALTER TABLE test ADD country VARCHAR(250);
--rollback: ROLLBACK COMMAND FOR add_column_into_table

