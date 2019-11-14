using System.Collections.Generic;
using VotingAPI.ServiceModel.DataModels;

namespace VotingAPI.ServiceModel.ResponseDTOs
{
    public class PollWithOptionsAndVotes : Poll
    {
        public List<OptionWithVoteCount> OptionsWithCounts { get; set; }
    }
}
