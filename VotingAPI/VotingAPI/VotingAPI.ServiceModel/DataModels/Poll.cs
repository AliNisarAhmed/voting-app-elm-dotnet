using ServiceStack.DataAnnotations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace VotingAPI.ServiceModel.DataModels
{
    public class Poll
    {
        [PrimaryKey]
        [AutoIncrement]
        public int Id { get; set; }

        public string Description { get; set; }

        [References(typeof(Client))]
        public int ClientId { get; set; }

        [Reference]
        public List<PollOption> Options { get; set; }
    }
}
