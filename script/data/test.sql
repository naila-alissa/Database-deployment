--liquibase formatted sql
--changeset runneradmin:2-data-test context:data-2 labels:test
--comment: Change generated for test.sql in data


INSERT INTO test_table (id, name, email) VALUES (14, 'Susane', 'ali@example.com');

