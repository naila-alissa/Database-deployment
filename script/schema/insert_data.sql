--liquibase formatted sql
--changeset NAALI39:insert-sample
INSERT INTO test (id, name, email)
VALUES (6, 'Naila', 'ali@example.com');

