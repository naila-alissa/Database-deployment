--liquibase formatted sql
--changeset NAALI39:data-4

INSERT INTO test_table (id, name, email)
VALUES (8, 'DeDi', 'ali@example.com');

