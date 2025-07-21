--liquibase formatted sql
--changeset NAALI39:1-data-new context:data-1 labels:new
--comment: Change generated for new.sql in data
--sql: Add SQL statements below this line
INSERT INTO test (id, name, email)
VALUES (10, 'Dina', 'test@example.com');

