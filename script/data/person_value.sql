--liquibase formatted sql
--changeset naila-alissa:data-person_value context:data labels:person_value

INSERT INTO person (id, name, address1, address2, city)
VALUES (1, 'John Doe', '123 Main St', 'Apt 4B', 'New York');
--rollback: ROLLBACK person_value

