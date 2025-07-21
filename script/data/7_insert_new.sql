--liquibase formatted sql
--changeset NAALI39:data-3

INSERT INTO test_table (id, name, email)
VALUES (3, 'DeDi', 'ali@example.com');