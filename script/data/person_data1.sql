--liquibase formatted sql
--changeset naila-alissa:data-person_data1 context:data labels:person_data1

INSERT INTO person1 (id, name, address1, address2, city)
VALUES (4, 'John Doe', '123 Main St', 'Apt 4B', 'New York');
--rollback: DELETE FROM person1 WHERE id = 4;

