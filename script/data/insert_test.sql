--liquibase formatted sql
--changeset runneradmin:1-data-insert_test context:data-1 labels:insert_test
--comment: Change generated for insert_test.sql in data


INSERT INTO test_table (id, name, email) VALUES (13, 'Susane', 'ali@example.com');

