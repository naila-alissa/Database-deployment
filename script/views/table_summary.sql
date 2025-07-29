--liquibase formatted sql
--changeset naila-alissa:views-table_summary context:views labels:table_summary


CREATE OR ALTER VIEW vw_test_summary AS
SELECT id, name, email
FROM test_table
WHERE email IS NOT NULL;
--rollback: ROLLBACK table_summary

