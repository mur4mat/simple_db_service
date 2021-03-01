DROP TABLE Bands;
DROP TABLE Musicians;
DROP TABLE BandsMusiciansRel;
DROP TABLE BandsRel;
DROP TABLE MusiciansRel;

CREATE TABLE Bands (
	band_id INT PRIMARY KEY AUTO_INCREMENT,
	band_name VARCHAR (255) NOT NULL UNIQUE,
	CHECK (band_name <> "")
);

CREATE TABLE Musicians (
	musician_id INT PRIMARY KEY AUTO_INCREMENT,
	musician_name VARCHAR (255) NOT NULL UNIQUE,
	CHECK (musician_name <> "")
); 

CREATE TABLE BandsMusiciansRel(
  band_id INT NOT NULL REFERENCES Bands (band_id),
  musician_id INT NOT NULL REFERENCES Musicians (musician_id),
  is_active TINYINT(1) NOT NULL,
  CONSTRAINT PK_bands_musicians_rel PRIMARY KEY (band_id, musician_id)
);

CREATE TABLE BandsRel (
   band_id1 INT NOT NULL references Bands (band_id),
   band_id2 INT NOT NULL references Bands (band_id),
   CONSTRAINT PK_bands_rel PRIMARY KEY (band_id1, band_id2));
   
CREATE TABLE MusiciansRel (
   musician_id1 INT NOT NULL,
   musician_id2 INT NOT NULL,
   CONSTRAINT PK_musicians_rel PRIMARY KEY (musician_id1, musician_id2));
   
  
INSERT INTO Bands (band_name) VALUES ('Blur') , 
('Gorillaz'), 
('Green Day'),
('Iron Maiden')

INSERT INTO Musicians (musician_name) VALUES ('Damon Albarn'),
('Graham Coxon'),
('Jamie Hewlett'),
('Blaze Bayley'),
('Bruce Dickinson')

INSERT INTO BandsMusiciansRel (band_id, musician_id, is_active) VALUES (1,1,0),
(1,2,1),
(1,3,1),
(4,4,0),
(4,5,1)

INSERT INTO BandsRel (band_id1, band_id2) VALUES (4,1),
(4,2),
(3,4)

INSERT INTO MusiciansRel (musician_id1, musician_id2) VALUES (4,1),
(4,2),
(3,4)

SELECT * FROM BandsRel br 

-- Bands - related musicians
SELECT b.musician_name, a.is_active FROM Musicians b
LEFT JOIN BandsMusiciansRel a ON a.musician_id = b.musician_id 
WHERE a.band_id = 4

-- Bands - related bands
SELECT b.band_name FROM BandsRel a
JOIN Bands b ON a.band_id2 = b.band_id
WHERE a.band_id1 = 4
UNION
SELECT b.band_name FROM BandsRel a
JOIN Bands b ON a.band_id1 = b.band_id
WHERE a.band_id2 = 4

-- Musicians - related bands
SELECT b.band_name , a.is_active FROM BandsMusiciansRel a
LEFT JOIN Bands b ON a.band_id = b.band_id
WHERE a.musician_id = 4

-- Musicians - related musicians
SELECT b.musician_name FROM MusiciansRel a
JOIN Musicians b ON a.musician_id2 = b.musician_id
WHERE a.musician_id1 = 4
UNION
SELECT b.musician_name FROM MusiciansRel a
JOIN Musicians b ON a.musician_id1 = b.musician_id
WHERE a.musician_id2 = 4