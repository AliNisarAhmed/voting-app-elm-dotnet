CREATE TABLE Poll (
	id int Primary Key Identity(1, 1) not null,
	Description nvarchar(max) not null,
	clientId int not null,
	CONSTRAINT fk_clientId FOREIGN KEY (clientId) REFERENCES Client(Id),
	);

