using VotingAPI.ServiceModel.DataModels;

namespace VotingAPI.ServiceModel.ResponseDTOs
{
    public class OptionWithVoteCount : PollOption
    {
        public int Votes { get; set; }
    }
}
