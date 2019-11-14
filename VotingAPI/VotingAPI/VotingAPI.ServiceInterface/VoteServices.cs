using ServiceStack;
using ServiceStack.OrmLite;
using System.Collections.Generic;
using System.Threading.Tasks;
using VotingAPI.ServiceModel;
using VotingAPI.ServiceModel.DataModels;
using static VotingAPI.ServiceModel.ServiceModels.VoteServiceModel;
using System.Linq;

namespace VotingAPI.ServiceInterface
{
    public class VoteServices : Service
    {
        public async Task<bool> Post(CastAVoteRequest req)
        {
            try
            {
                // first we check if the optionId provided is valid
                var options = await Db.SelectAsync<PollOption>(po => po.PollId == req.PollId);

                if (!options.Select(o => o.Id).Contains(req.OptionId))
                {
                    throw new System.Exception("Invalid Option");
                }
                // check if the client has voted on this poll already
                var existingVote = await Db.SingleAsync<Vote>(v => v.PollId == req.PollId && v.ClientId == req.ClientId);

                if (existingVote != null)
                {
                    // If the client has already voted, we need to either remove the previous vote, or if it is for the same option just return true
                    if (existingVote.OptionId != req.OptionId)
                    {
                        existingVote.OptionId = req.OptionId;
                        // Update the old vote with new option?
                        await Db.SaveAsync(existingVote);
                    }
                    return true;
                }
                else
                {
                    var newVote = new Vote()
                    {
                        ClientId = req.ClientId,
                        PollId = req.PollId,
                        OptionId = req.OptionId
                    };

                    await Db.InsertAsync(newVote);
                    return true;
                }
            }
            catch (System.Exception e)
            {

                throw new System.Exception(e.Message);
            }

        }

        public async Task<bool> Delete(RemoveVoteRequest req)
        {
            try
            {
                var vote = await Db.DeleteAsync<Vote>(v =>
                    v.OptionId == req.OptionId && v.ClientId == req.ClientId);

                return vote == 0;
            }
            catch (System.Exception e)
            {

                throw new System.Exception(e.Message);
            }

        }
    }
}
 