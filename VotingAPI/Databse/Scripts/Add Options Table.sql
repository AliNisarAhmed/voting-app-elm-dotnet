CREATE TABLE PollOption (
	id int primary key Identity(1,1) not null,
	optionText nvarchar(max) not null,
	pollId int not null,
	CONSTRAINT fk_pollId FOREIGN KEY (pollId)
	REFERENCES Poll(id)
	);

