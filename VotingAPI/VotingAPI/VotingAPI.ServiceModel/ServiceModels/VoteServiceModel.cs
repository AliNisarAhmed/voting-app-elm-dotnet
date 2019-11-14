using ServiceStack;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace VotingAPI.ServiceModel.ServiceModels
{
    public class VoteServiceModel
    {
        [Route("/api/polls/{PollId}/vote", "POST")]
        public class CastAVoteRequest
        {
            public int PollId { get; set; }
            public int ClientId { get; set; }
            public int OptionId { get; set; }
        }

        [Route("/api/polls/{PollId}/vote", "DELETE")]
        public class RemoveVoteRequest
        {
            public int PollId { get; set; }
            public int ClientId { get; set; }
            public int OptionId { get; set; }
        }
    }
}
