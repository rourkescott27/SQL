-------------------------------------------
-------------------------------------------
DROP TABLE my_contacts CASCADE;          --
DROP TABLE  zip_codes CASCADE;           --
DROP TABLE statuses CASCADE;             --
DROP TABLE IF EXISTS professions;        --
DROP TABLE seekings CASCADE;             --
DROP TABLE interests CASCADE;            --
DROP TABLE IF EXISTS contact_seeking;    --
DROP TABLE IF EXISTS contact_interest;   --
-------------------------------------------
-------------------------------------------

-- Zip Codes Table --
CREATE TABLE zip_codes (
	zip_code bigint CONSTRAINT zip_code_id PRIMARY KEY ,         
	province varchar(20),
	city varchar(25),
	CHECK (zip_code >= 1000 AND zip_code <= 9999)
);

INSERT INTO zip_codes (
	zip_code,
	province,
	city
)

VALUES 
	('1713', 'Limpopo', 'Polokwane'),
	('3920', 'Limpopo', 'Louis Trichardt'),
	('1200', 'Mpumalanga', 'Nelspruit'),
	('1050', 'Mpumalanga', 'Middelburg'),
	('2000', 'Gauteng', 'Johannesburg'),
	('1001', 'Gauteng', 'Pretoria'),
	('2735', 'North West', 'Mahikeng'),
	('2520', 'North West', 'Potchefstroom'),
	('9300', 'Free State', 'Bloemfontein'),
	('9459', 'Free State', 'Welkom'),
	('4000', 'Kwazulu-Natal', 'Durban'),
	('3200', 'Kwazulu-Natal', 'Pietermaritzburg'),
	('8300', 'Northern Cape', 'Kimberley'),
	('8800', 'Northern Cape', 'Upington'),
	('6000', 'Eastern Cape', 'Port Elizabeth'),
	('5200', 'Eastern Cape', 'East London'),
	('6665', 'Western Cape', 'Cape Town'),
	('7599', 'Western Cape', 'Stellenbosch');

SELECT * FROM zip_codes;
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
-- Statuses Table --
CREATE TABLE statuses (
	status_id bigserial CONSTRAINT status_id_key PRIMARY KEY,
	status varchar(15) UNIQUE NOT NULL
);

INSERT INTO statuses (status)

VALUES 
	('Single'),
	('Divorced');

SELECT * FROM statuses;
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-- Professions Table --
CREATE TABLE professions (
	profession_id bigserial CONSTRAINT professions_id_key PRIMARY KEY,
	profession varchar(25) NOT NULL,
	CONSTRAINT UC_profession UNIQUE (profession) 
);

INSERT INTO professions (profession)

VALUES 
	('Civil Engineer'),
	('Childcare worker'),
	('Economist'),
	('Medical Secretary'),
	('Physician'),
	('Student'),
	('Social Worker'),
	('Fitness Trainer'),
	('Veterinarian'),
	('Cashier');

SELECT * FROM professions;
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
-- Seeks Table --
CREATE TABLE seekings (
	seeking_id bigserial CONSTRAINT seeking_id_key PRIMARY KEY,
	seeking varchar(30) UNIQUE NOT NULL 
);

INSERT INTO seekings (seeking)

VALUES
	('Single male'),
	('Single female'),
	('Same profession'),
	('Employed'),
	('Student'),
	('Retired'),
	('Over 45'),
	('Over 25'),
	('Under 25'),
	('Under 50');

SELECT * FROM seekings;

-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
-- Interests Table --
CREATE TABLE interests (
	interest_id bigserial CONSTRAINT interest_id_key PRIMARY KEY,
	interest varchar(30) UNIQUE NOT NULL 
);

INSERT INTO interests (interest)
 
VALUES
	('Hiking'),
	('Reading'),
	('Photography'),
	('Cooking'),
	('Gardening'),
	('Swimming'),
	('Painting'),
	('Cycling'),
	('Geography'),
    ('Walking');

SELECT * FROM interests;

------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- My Contacts Table --
CREATE TABLE my_contacts (
	contact_id bigserial CONSTRAINT contact_id_key PRIMARY KEY,
	first_name varchar(30) NOT NULL,
	last_name varchar(30) NOT NULL,
	gender char(1) NOT NULL,
	phone varchar(12) UNIQUE NOT NULL,
	email varchar(50) UNIQUE NOT NULL,
	birthday date NOT NULL,
	zip_code bigint REFERENCES zip_codes (zip_code) ON DELETE CASCADE,
	status_id bigint REFERENCES statuses (status_id) ON DELETE CASCADE,
	profession_id bigint REFERENCES professions (profession_id)ON DELETE CASCADE
);

INSERT INTO my_contacts (	
	first_name,
	last_name,
	gender,
	phone,
	email,
 	birthday,
	zip_code,
	status_id,
	profession_id
)

VALUES 
	('Ellis', 'Richards', 'M', '082 227 5732', 'EllisRichards@armyspy.com', '1983-02-18', '1713', 2, 1),
	('Chloe', 'Knowles', 'F', '085 621 5572', 'ChloeKnowles@armyspy.com', '2001-07-01', '2520', 1, 6),
	('Francesca', 'Carey', 'F', '084 765 7840', 'FrancescaCarey@jourrapide.com', '1976-12-30', '2000', 2, 7),
	('Jay', 'Booth', 'M', '082 259 9048', 'JayBooth@jourrapide.com', '2002-02-06', '8800', 1, 3),
	('Charlotte', 'Spencer', 'F', '085 396 0165', 'CharlotteSpencer@dayrep.com', '1988-10-05', '3200', 2, 9),
	('Joseph', 'Hardy', 'M', '084 228 7582', 'JosephHardy@armyspy.com', '1991-01-02', '5200', 1, 8),
	('Georgia', 'Kelly', 'F', '083 646 9523', 'GeorgiaKelly@armyspy.com', '1993-05-16', '1050', 1, 10),
	('Kian', 'Stewart', 'M', '083 401 0877', 'KianStewart@rhyta.com', '1983-04-13', '1001', 2, 8),
	('Aaliyah', 'Walsh', 'F', '083 202 6106', 'AaliyahWalsh@dayrep.com', '1992-12-06', '9300', 1, 2),
	('Archie', 'Moore', 'M', '082 923 6213', 'ArchieMoore@teleworm.us', '1999-04-23', '2735', 1, 6),
	('Gabriel', 'Kerr', 'M', '083 363 6389', 'GabrielKerr@teleworm.us', '1995-11-05', '6000', 1, 3),
	('Logan', 'Hicks', 'M', '082 740 1644', 'LoganHicks@armyspy.com', '1991-08-14', '1200', 1, 3),
	('Lucy', 'Gregory', 'F', '085 235 2339', 'LucyGregory@rhyta.com', '1985-12-21', '4000', 2, 4),
	('Kieran', 'Dawson', 'M', '083 108 4317', 'KieranDawson@rhyta.com', '2000-08-08', '3920', 1, 6),
	('Alicia', 'Sykes', 'F', '085 456 1803', 'AliciaSykes@jourrapide.com', '1993-09-11', '6665', 2, 2),
	('Aidan', 'Reed', 'M', '084 202 0456', 'AidanReed@jourrapide.com', '1981-03-27', '9459', 2, 5),
	('Rachel', 'Phillips', 'F', '083 361 8005', 'RachelPhillips@dayrep.com', '1992-07-01', '8300', 1, 1),
	('Kayleigh', 'Yates', 'F', '085 122 6904', 'KayleighYates@jourrapide.com', '2001-09-06', '7599', 1, 6);

SELECT * FROM my_contacts;

-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
-- Contact Seeking Table --
CREATE TABLE contact_seeking (
	contact_id bigint NOT NULL REFERENCES my_contacts(contact_id) ON DELETE CASCADE,
	seeking_id bigint NOT NULL REFERENCES seekings(seeking_id) ON DELETE CASCADE
);
 
INSERT INTO contact_seeking (contact_id, seeking_id)
 
VALUES
	(1, 2),
	(1, 10),
	(2, 1),
	(2, 5),
	(2, 9), 
	(3, 1),
	(3, 4),
	(4, 2),
	(4, 5),
	(5, 1),
	(5, 3),
	(6, 2),
	(6, 6),
	(7, 1),
	(7, 3),
	(8, 2), 
	(8, 4),
	(9, 1),
	(9, 8),
	(10, 2),
	(10, 5),
	(11, 2),
	(11, 8),
	(12, 2),
	(12, 3),				  
	(13, 1),
	(13, 7),
	(14, 2),
	(14, 5),
	(15, 1),
	(15, 3),
	(15, 8),
	(16, 2),
	(16, 4),
	(17, 1),
	(17, 8),
	(18, 1),
	(18, 5);

SELECT * FROM contact_seeking;

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-- Contact Interest Table --

CREATE TABLE contact_interest (
	contact_id bigint NOT NULL REFERENCES my_contacts(contact_id) ON DELETE CASCADE,
	interest_id bigint NOT NULL REFERENCES interests(interest_id) ON DELETE CASCADE
);

INSERT INTO contact_interest (contact_id, interest_id)

VALUES
	(1, 2),
	(1, 5),
	(1, 6),
	(2, 8),
	(2, 9),
	(2, 4),
	(3, 7),
	(3, 3),
	(3, 9),
	(4, 10),
	(4, 3),
	(4, 7),
	(5, 8),
	(5, 1),
	(5, 5),
	(6, 10),
	(6, 3),
	(6, 7),
	(7, 1),
	(7, 6),
	(7, 7),
	(8, 6),
	(8, 2),
	(8, 5),
	(9, 4),
	(9, 7),
	(9, 9),
	(10, 10),
	(10, 3),
	(10, 8),
	(11, 1),
	(11, 5),
	(11, 3),
	(12, 2),
	(12, 10),
	(12, 4),
	(13, 2),
	(13, 6),
	(13, 9),
	(14, 5),
	(14, 6),
	(14, 7),
	(15, 2),
	(15, 6),
	(15, 10),
	(16, 3),
	(16, 8),
	(16, 9),
	(17, 2),
	(17, 4),
	(17, 8),
	(18, 5),
	(18, 10), 
	(18, 7);

SELECT * FROM contact_interest;

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
-- LEFT JOIN --
SELECT
	prof.profession, 
	zc.zip_code, 
	zc.province, 
	zc.city,
	st.status,
	intr.interest,
	sk.seeking
FROM my_contacts mc
LEFT JOIN professions prof
ON mc.profession_id = prof.profession_id
LEFT JOIN zip_codes zc
ON zc.zip_code = mc.zip_code
LEFT JOIN statuses st
ON st.status_id = mc.status_id
LEFT JOIN contact_seeking cs
ON cs.contact_id = mc.contact_id
LEFT JOIN seekings sk
ON sk.seeking_id = cs.seeking_id
LEFT JOIN contact_interest ci
ON ci.contact_id = mc.contact_id
LEFT JOIN interests intr
ON ci.interest_id = intr.interest_id;

















