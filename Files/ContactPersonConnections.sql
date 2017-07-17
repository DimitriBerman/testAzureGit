INSERT INTO ContactPersonConnections
(
	ContactID,
	PersonID,
	RelationshipType_Id
)
SELECT
	Contact.Id,
	Person.Id,
	(
		SELECT TOP 1 Id FROM ContactPersonRelationshipType WHERE ContactPersonRelationshipType.CompanyId = (
			SELECT TOP 1
				Offices.CompanyId
			FROM
				OfficeContactRel
			INNER JOIN Offices ON OfficeContactRel.OfficeID = Offices.Id
			WHERE
				OfficeContactRel.ContactID = Contact.Id
		) 
		ORDER BY NEWID()
	)
FROM
	Contact
INNER JOIN Person ON Contact.Id = Person.ContactId
WHERE
	EXISTS(SELECT * FROM OfficeContactRel WHERE OfficeContactRel.ContactID = Contact.Id);