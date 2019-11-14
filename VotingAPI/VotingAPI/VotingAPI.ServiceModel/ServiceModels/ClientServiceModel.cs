using ServiceStack;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace VotingAPI.ServiceModel.ServiceModels
{
    public class ClientServiceModel
    {
        [Route("/api/clients", "GET")]
        public class GetAllClientsRequest
        {

        }
    }
}