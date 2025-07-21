--liquibase formatted sql
--changeset ${USERNAME}:tabel_summary context:summary tag:summary-view
CREATE OR ALTER VIEW vw_test_summary AS
SELECT id, name, email
FROM test_table
WHERE email IS NOT NULL;