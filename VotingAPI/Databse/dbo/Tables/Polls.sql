CREATE TABLE [dbo].[Polls] (
    [Id]          INT            IDENTITY (1, 1) NOT NULL,
    [Description] NVARCHAR (MAX) NOT NULL,
    [Option1]     NVARCHAR (MAX) NOT NULL,
    [Option2]     NVARCHAR (MAX) NOT NULL,
    [Option3]     NVARCHAR (MAX) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

