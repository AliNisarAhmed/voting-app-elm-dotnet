create table Vote (
	id int Primary Key Identity (1, 1) not null,
	clientId int not null,
	CONSTRAINT fk_voterId FOREIGN KEY (clientId)
	REFERENCES Client(id),
	optionId int not null,
	CONSTRAINT fk_optionId FOREIGN KEY (optionId)
	REFERENCES PollOption(id),
	);