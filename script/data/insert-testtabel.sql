--liquibase formatted sql
--changeset NAALI39:1-data-insert-testtabel.sql context:data-1 labels:insert-testtabel
--comment: Change generated for insert-testtabel.sql in data
--sql: Add SQL statements below this line

INSERT INTO test (id, name, email)
VALUES (7, 'Diana', 'test@example.com');

