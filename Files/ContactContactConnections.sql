DECLARE @CompanyID INT;
DECLARE @ContactID INT;

DECLARE c_contacts CURSOR FOR 
SELECT DISTINCT
	Companies.Id,
	OfficeContactRel.ContactID
FROM
	Companies
INNER JOIN Offices ON Companies.Id = Offices.CompanyId
INNER JOIN OfficeContactRel ON Offices.Id = OfficeContactRel.OfficeID
	
OPEN c_contacts
FETCH NEXT FROM c_contacts INTO @CompanyID, @ContactID
WHILE @@FETCH_STATUS = 0
BEGIN

	INSERT INTO ContactContactConnections
	(
		ContactAID,
		ContactBID,
		RelationshipType_Id
	)
	SELECT TOP 5
		@ContactID,
		Contact.Id,
		(SELECT TOP 1 Id FROM ContactContactRelationshipType WHERE CompanyId = @CompanyID ORDER BY NEWID())
	FROM
		Contact
	WHERE
		Contact.Id <> @ContactID
	AND
		EXISTS(SELECT * FROM OfficeContactRel WHERE OfficeContactRel.ContactID = Contact.Id AND OfficeContactRel.OfficeID IN (SELECT OfficeId FROM OfficeContactRel ocr2 WHERE ocr2.ContactID = @ContactID))
	AND
		NOT EXISTS(SELECT * FROM ContactContactConnections WHERE ContactAID = Contact.Id AND ContactBID = @ContactID)
	ORDER BY
		NEWID();

	FETCH NEXT FROM c_contacts INTO @CompanyID, @ContactID
END
CLOSE c_contacts   
DEALLOCATE c_contacts