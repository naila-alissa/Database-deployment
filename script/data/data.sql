--liquibase formatted sql
--changeset naila-alissa:data-data context:data labels:data

INSERT INTO person_test (id, name, address1, address2, city)
VALUES (5, 'John Doe', '123 Main St', 'Apt 4B', 'New York');


