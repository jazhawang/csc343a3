/* data.sql */

INSERT INTO DiveSites (id, name, location, diverFee)
VALUES
    (1, 'Bloody Bay Marine Park', 'Little Cayman', 1000),
    (2, 'Widow Makers Cave', 'Montegro Bay', 2000),
    (3, 'Crystal Bay', 'Crystal Bay', 1500),
    (4, 'Batu Bolong', 'Batu Bolong', 1500);

INSERT INTO dsDiveTypes (sID, diveType, capacity)
VALUES
    (1, 'cave', 10),
    ()