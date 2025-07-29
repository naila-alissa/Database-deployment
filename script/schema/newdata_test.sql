--liquibase formatted sql
--changeset naila-alissa:schema-newdata_test context:schema labels:newdata_test

INSERT INTO test (id, name, email)
VALUES (14, 'Kasem', 'Kasem@example.com');
--rollback: ROLLBACK newdata_test

