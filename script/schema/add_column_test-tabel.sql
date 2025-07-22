--liquibase formatted sql
--changeset naila-alissa:1-schema-add_column_test-tabel context:schema-1 labels:add_column_test-tabel
--comment: Change generated for add_column_test-tabel.sql in schema


ALTER TABLE test_table ADD City VARCHAR(250);

