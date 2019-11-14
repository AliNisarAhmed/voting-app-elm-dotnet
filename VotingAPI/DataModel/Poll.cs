using System;
using ServiceStack;
using ServiceStack.DataAnnotations;

namespace VotingAPI.DataModel
{
    public class Poll
    {
        [PrimaryKey]
        public int Id { get; set; }
        public string Description { get; set; }

        [References(typeof(Client))]
        public int ClientId { get; set; }

        [Reference]
        public List<PollOption> Options { get; set; }
    }
}
