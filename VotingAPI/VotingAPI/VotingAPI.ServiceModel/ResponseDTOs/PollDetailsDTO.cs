using System.Collections.Generic;
using VotingAPI.ServiceModel.DataModels;

namespace VotingAPI.ServiceModel.ResponseDTOs
{
    public class PollDetailsDTO : Poll
    {
        public List<OptionWithVoteCount> Options { get; set; }
        public Client Creator { get; set; }
    }
}
