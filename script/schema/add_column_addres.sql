--liquibase formatted sql
--changeset ${USERNAME}:add-address-column  context:add_column tag:add-address-column
ALTER TABLE test_table ADD Adresss VARCHAR(250);