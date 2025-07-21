--liquibase formatted sql
--tag: v1.0
--sql: Add SQL statements below this line
--changeset ${USERNAME}:insert-sample-data context:insert-sample tag:sample-data
INSERT INTO test_table (id, name, email) VALUES (1, 'Ali', 'ali@example.com');
INSERT INTO test_table (id, name, email) VALUES (2, 'Laila', 'laila@example.com');
INSERT INTO test_table (id, name, email) VALUES (4, 'Sara', 'sara@example.com');

