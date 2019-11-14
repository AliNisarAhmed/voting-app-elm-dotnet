using ServiceStack.DataAnnotations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace VotingAPI.ServiceModel.DataModels
{
    public class Vote
    {
        [PrimaryKey]
        [AutoIncrement]
        public int Id { get; set; }

        [References(typeof(Client))]
        public int ClientId { get; set; }

        [References(typeof(PollOption))]
        public int OptionId { get; set; }

        [References(typeof(Poll))]
        public int PollId { get; set; }
    }
}
