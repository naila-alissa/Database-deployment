--liquibase formatted sql
--changeset naila-alissa:1-schema-add_column_country context:schema-1 labels:add_column_country
--comment: Change generated for add_column_country.sql in schema



ALTER TABLE test_table ADD country VARCHAR(250);

