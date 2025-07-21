--liquibase formatted sql
--changeset NAALI39:5-data-9_insert.sql   context:data-5 labels:9_insert.sql

INSERT INTO test_table (id, name, email)
VALUES (9, 'Diana', 'ali@example.com');


