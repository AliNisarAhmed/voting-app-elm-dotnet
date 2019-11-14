using ServiceStack;
using ServiceStack.OrmLite;
using System.Collections.Generic;
using System.Threading.Tasks;
using VotingAPI.ServiceModel;
using VotingAPI.ServiceModel.DataModels;
using VotingAPI.ServiceModel.ResponseDTOs;
using static VotingAPI.ServiceModel.ServiceModels.PollServiceModel;

namespace VotingAPI.ServiceInterface
{
    class PollServices : Service
    {
        public async Task<Poll> Post(CreateNewPollRequest req)
        {
            try
            {
                var newPoll = new Poll()
                {
                    ClientId = req.ClientId,
                    Description = req.Description,
                };

                var autoId = await Db.InsertAsync(newPoll, selectIdentity: true);

                var newPollFromDb = await Db.SingleByIdAsync<Poll>(autoId);


                foreach (var option in req.Options)
                {
                    var o = new PollOption()
                    {
                        OptionText = option,
                        PollId = newPollFromDb.Id,
                    };

                    await Db.SaveAsync<PollOption>(o);
                }

                return newPollFromDb;
            }
            catch (System.Exception e)
            {

                throw new System.Exception(e.Message);
            }
        }

        public async Task<List<Poll>> Get(GetAllPollsRequest req)
        {
            // TODO: This returns the PollOptions List populated, but CLient is not!!
            var q = Db.From<Poll>();
            var polls = await Db.LoadSelectAsync<Poll>(q);
            return polls;
        }

        public async Task<object> Get(GetSinglePollDetails req)
        {
            var poll = await Db.LoadSingleByIdAsync<Poll>(req.PollId);
            var q1 = Db.From<PollOption>().Where(pO => pO.PollId == req.PollId);
            var optionsWithVoteCount = new List<OptionWithVoteCount>();
            foreach (var option in poll.Options)
            {
                var count = await Db.CountAsync<Vote>(v => v.OptionId == option.Id);
                var optionWithCount = new OptionWithVoteCount()
                {
                    Id = option.Id,
                    OptionText = option.OptionText,
                    Votes = (int)count,
                };
                optionsWithVoteCount.Add(optionWithCount);
            }
            var pollWithOptions = new PollWithOptionsAndVotes()
            {
                Id = poll.Id,
                ClientId = poll.ClientId,
                OptionsWithCounts = optionsWithVoteCount,
                Description = poll.Description
            };
            return pollWithOptions;
        }
    }
}
