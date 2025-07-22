--liquibase formatted sql
--changeset IKEA\naali39:1-data-newdata_into_test-tabel context:data-1 labels:newdata_into_test-tabel
--comment: Change generated for newdata_into_test-tabel.sql in data


INSERT INTO test_table (id, name, email) VALUES (15, 'Susane', 'ali@example.com');

