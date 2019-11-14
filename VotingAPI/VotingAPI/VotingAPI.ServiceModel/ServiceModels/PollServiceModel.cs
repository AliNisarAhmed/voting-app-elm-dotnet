using ServiceStack;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace VotingAPI.ServiceModel.ServiceModels
{
    public class PollServiceModel
    {
        [Route("/api/polls", "GET")]
        public class GetAllPollsRequest
        {

        }

        [Route("/api/polls/new", "POST")]
        public class CreateNewPollRequest
        {
            public int ClientId { get; set; }
            public List<string> Options { get; set; }
            public string Description { get; set; }
        }

        [Route("/api/polls/{PollId}", "GET")]
        public class GetSinglePollDetails
        {
            public int PollId { get; set; }
        }

    }
}
