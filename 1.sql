
CREATE DATABASE PetPals;
USE PetPals;
-- Table: Pets
CREATE TABLE IF NOT EXISTS Pets (
    PetID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(255),
    Age INT,
    Breed VARCHAR(255),
    Type VARCHAR(255),
    AvailableForAdoption BIT
);

-- Table: Shelters
CREATE TABLE IF NOT EXISTS Shelters (
    ShelterID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(255),
    Location VARCHAR(255)
);

-- Table: Donations
CREATE TABLE IF NOT EXISTS Donations (
    DonationID INT AUTO_INCREMENT PRIMARY KEY,
    DonorName VARCHAR(255),
    DonationType VARCHAR(255),
    DonationAmount DECIMAL(10, 2),
    DonationItem VARCHAR(255),
    DonationDate DATETIME
);
use petpals;
-- Table: AdoptionEvents
CREATE TABLE IF NOT EXISTS AdoptionEvents (
    EventID INT AUTO_INCREMENT PRIMARY KEY,
    EventName VARCHAR(255),
    EventDate DATETIME,
    Location VARCHAR(255)
);

-- Table: Participants
CREATE TABLE IF NOT EXISTS Participants (
    ParticipantID INT AUTO_INCREMENT PRIMARY KEY,
    ParticipantName VARCHAR(255),
    ParticipantType VARCHAR(255),
    EventID INT,
    FOREIGN KEY (EventID) REFERENCES AdoptionEvents(EventID)
);

-- Insert values into Pets table
INSERT INTO Pets (PetID, Name, Age, Breed, Type, AvailableForAdoption)
VALUES 
    (1, 'Buddy', 3, 'Labrador Retriever', 'Dog', 1),
    (2, 'Whiskers', 5, 'Siamese', 'Cat', 1),
    (3, 'Max', 2, 'Golden Retriever', 'Dog', 0),
    (4, 'Fluffy', 1, 'Persian', 'Cat', 1),
    (5, 'Rocky', 4, 'German Shepherd', 'Dog', 1);

-- Insert values into Shelters table
INSERT INTO Shelters (ShelterID, Name, Location)
VALUES 
    (1, 'Happy Tails Shelter', '123 Main Street'),
    (2, 'Paws and Claws Rescue', '456 Elm Street'),
    (3, 'Second Chance Shelter', '789 Oak Avenue'),
    (4, 'Forever Friends Adoption Center', '101 Pine Street'),
    (5, 'Rescue Me Shelter', '222 Maple Avenue');

-- Insert values into Donations table
INSERT INTO Donations (DonationID, DonorName, DonationType, DonationAmount, DonationItem, DonationDate)
VALUES 
    (1, 'John Doe', 'Cash', 100.00, NULL, '2024-04-22 09:00:00'),
    (2, 'Jane Smith', 'Item', NULL, 'Blankets', '2024-04-21 15:30:00'),
    (3, 'Alice Johnson', 'Cash', 50.00, NULL, '2024-04-20 12:45:00'),
    (4, 'Bob Anderson', 'Item', NULL, 'Toys', '2024-04-19 10:15:00'),
    (5, 'Emily Brown', 'Cash', 75.00, NULL, '2024-04-18 11:20:00');

-- Insert values into AdoptionEvents table
INSERT INTO AdoptionEvents (EventID, EventName, EventDate, Location)
VALUES 
    (1, 'Pet Adoption Day', '2024-05-01 10:00:00', 'City Park'),
    (2, 'Cat Adoption Fair', '2024-04-30 11:00:00', 'Community Center'),
    (3, 'Dog Adoption Event', '2024-04-29 09:00:00', 'Pet Store'),
    (4, 'Rescue Event', '2024-04-28 13:00:00', 'Local Mall'),
    (5, 'Adopt-a-Thon', '2024-04-27 12:00:00', 'Town Square');

-- Insert values into Participants table
INSERT INTO Participants (ParticipantID, ParticipantName, ParticipantType, EventID)
VALUES 
    (1, 'Happy Tails Shelter', 'Shelter', 1),
    (2, 'Paws and Claws Rescue', 'Shelter', 2),
    (3, 'Second Chance Shelter', 'Shelter', 3),
    (4, 'Forever Friends Adoption Center', 'Shelter', 4),
    (5, 'Emily Brown', 'Adopter', 1);
    
SELECT Name, Age, Breed, Type
FROM Pets
WHERE AvailableForAdoption = 1;

DELIMITER //

CREATE PROCEDURE GetParticipantsForEvent(IN eventIDParam INT)
BEGIN
    SELECT p.ParticipantName, p.ParticipantType
    FROM Participants p
    WHERE p.EventID = eventIDParam;
END//

DELIMITER ;


DELIMITER //

CREATE PROCEDURE UpdateShelterInfo(
    IN p_ShelterID INT,
    IN p_Name VARCHAR(255),
    IN p_Location VARCHAR(255)
)
BEGIN
    DECLARE shelterExists INT;

    -- Check if the shelter exists
    SELECT COUNT(*) INTO shelterExists FROM Shelters WHERE ShelterID = p_ShelterID;

    IF shelterExists > 0 THEN
        -- Update the shelter information
        UPDATE Shelters
        SET Name = p_Name,
            Location = p_Location
        WHERE ShelterID = p_ShelterID;

        SELECT 'Shelter information updated successfully.' AS Message;
    ELSE
        SELECT 'Shelter does not exist.' AS Error;
    END IF;
END //

DELIMITER ;

SELECT
    s.Name AS ShelterName,
    COALESCE(SUM(d.DonationAmount), 0) AS TotalDonationAmount
FROM
    Shelters s
LEFT JOIN
    Donations d ON s.ShelterID = d.donationID
GROUP BY
    s.Name;
    
SELECT *
FROM Pets
WHERE OwnerID IS NULL;

UPDATE Pets
SET OwnerID = 
    CASE 
        WHEN Name = 'Buddy' THEN 1
        WHEN Name = 'Whiskers' THEN 2
        WHEN Name = 'Fluffy' THEN 4
        ELSE NULL
    END
WHERE PetID IS NOT NULL;


SELECT MonthYear, SUM(DonationAmount) AS TotalDonationAmount
FROM (
    SELECT DATE_FORMAT(DonationDate, '%M %Y') AS MonthYear, DonationAmount
    FROM Donations
) AS subquery
GROUP BY MonthYear;


SELECT DISTINCT Breed
FROM Pets
WHERE (Age BETWEEN 1 AND 3) OR (Age > 5);

SELECT p.Name AS PetName, p.Breed, p.Type, s.Name AS ShelterName
FROM Pets p
JOIN Shelters s ON p.PetID = s.ShelterID
WHERE p.AvailableForAdoption = 1;


SELECT COUNT(*) AS TotalParticipants
FROM Participants p
JOIN AdoptionEvents e ON p.EventID = e.EventID
JOIN Shelters s ON p.ParticipantID = s.ShelterID
WHERE s.Location = 'Chennai';


SELECT DISTINCT Breed
FROM Pets
WHERE Age BETWEEN 1 AND 5;


ALTER TABLE Pets
ADD OwnerID INT;

SELECT Name, Age, Breed, Type
FROM Pets
WHERE OwnerID IS NULL;

-- SELECT p.Name AS PetName, u.Name AS AdopterName
-- FROM Adoption a
-- JOIN Pets p ON a.PetID = p.PetID
-- JOIN Users u ON a.UserID = u.UserID; 

SELECT s.Name AS ShelterName, COUNT(*) AS AvailablePetsCount
FROM Shelters s
JOIN Pets p ON s.ShelterID = p.PetID
WHERE p.AvailableForAdoption = 1
GROUP BY s.ShelterID;


SELECT p1.Name AS Pet1Name, p2.Name AS Pet2Name, p1.Breed
FROM Pets p1, Pets p2
WHERE p1.PetID = p2.PetID
AND p1.PetID <> p2.PetID
AND p1.Breed = p2.Breed;


SELECT s.Name AS ShelterName, e.EventName
FROM Shelters s, AdoptionEvents e;


SELECT s.Name AS ShelterName, COUNT(*) AS AdoptedPetsCount
FROM Shelters s
JOIN Pets p ON s.ShelterID = p.PetID
WHERE p.OwnerID IS NOT NULL
GROUP BY s.ShelterID
ORDER BY AdoptedPetsCount DESC
LIMIT 1;



