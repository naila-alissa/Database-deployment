--liquibase formatted sql
--changeset naila-alissa:1-schema-add_addres context:schema-1 labels:add_addres
--comment: Change generated for add_addres.sql in schema

ALTER TABLE test ADD Adresss VARCHAR(250);
--rollback: ROLLBACK COMMAND FOR add_addres

