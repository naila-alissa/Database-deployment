--liquibase formatted sql
--changeset NAALI39:create-table
CREATE TABLE test_table (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    created_at DATETIME DEFAULT GETDATE()
);


