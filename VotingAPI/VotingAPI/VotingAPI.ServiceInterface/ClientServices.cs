using ServiceStack;
using ServiceStack.OrmLite;
using System.Collections.Generic;
using System.Threading.Tasks;
using VotingAPI.ServiceModel;
using VotingAPI.ServiceModel.DataModels;
using static VotingAPI.ServiceModel.ServiceModels.ClientServiceModel;
using static VotingAPI.ServiceModel.ServiceModels.UserServiceModel;

namespace VotingAPI.ServiceInterface
{
    public class ClientServices : Service
    {
        public async Task<Client> Post(CreateNewClientRequest req)
        {
            try
            {
                var client = new Client()
                {
                    FirstName = req.FirstName,
                    LastName = req.LastName,
                    Email = req.Email,
                };

                var id = await Db.InsertAsync(client, selectIdentity: true);
                return await Db.SingleByIdAsync<Client>(id);
            }
            catch (System.Exception e)
            {
                throw new System.Exception(e.Message);
            }
        }

        public async Task<List<Client>> Get(GetAllClientsRequest req)
        {
            var clients = await Db.LoadSelectAsync<Client>(c => c.Id >= 0);
            return clients;
        }
    }
}