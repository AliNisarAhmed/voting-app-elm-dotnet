CREATE TABLE Client (
	Id int PRIMARY KEY IDENTITY(1, 1) not null,
	FirstName nvarchar(max) not null,
	LastName nvarchar(max) not null,
	Email nvarchar(max) not null,
	);
