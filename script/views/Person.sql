--liquibase formatted sql
--changeset naila-alissa:views-Person context:views labels:Person

CREATE VIEW view_people_in_ny AS
SELECT id, name, city
FROM person
WHERE city = 'New York';
--rollback: DROP VIEW view_people_in_ny;

