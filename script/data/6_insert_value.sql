--liquibase formatted sql
--changeset NAALI39:data-2
INSERT INTO test_table (id, name, email) VALUES (7, 'Susane', 'ali@example.com');

