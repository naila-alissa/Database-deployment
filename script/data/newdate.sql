--liquibase formatted sql
--changeset naila-alissa:data-newdate context:data labels:newdate

INSERT INTO test (id, name, email) VALUES (16, 'Nina', 'ali@example.com');
--rollback: ROLLBACK newdate

