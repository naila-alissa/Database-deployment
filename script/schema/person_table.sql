--liquibase formatted sql
--changeset naila-alissa:schema-person_table context:schema labels:person_table


create table person_test (
    id int primary key,
    name varchar(50) not null,
    address1 varchar(50),
    address2 varchar(50),
    city varchar(30)
);


--rollback DROP TABLE person_test;

