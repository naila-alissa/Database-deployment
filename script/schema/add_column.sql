--liquibase formatted sql
--changeset ${USERNAME}:add-email-column
ALTER TABLE test_table ADD email VARCHAR(150);