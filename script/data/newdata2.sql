--liquibase formatted sql
--changeset NAALI39:8-data-newdata2 context:data-8 labels:newdata2
--comment: Change generated for newdata2.sql in data
--tag: v1.0
--sql: Add SQL statements below this line
INSERT INTO test (id, name, email)
VALUES (9, 'Dina', 'test@example.com');

