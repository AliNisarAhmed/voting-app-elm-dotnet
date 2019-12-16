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
    [Authenticate]
    public class TestService : Service
    {
        public async Task<bool> Get(TestServiceRequest req)
        {
            var session = base.GetSession();
            return true;
        }

        public async Task<bool> Get(TestLoginRequest req)
        {
            return true;
        }
    }
}
