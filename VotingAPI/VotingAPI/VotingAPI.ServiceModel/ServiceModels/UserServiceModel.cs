using ServiceStack;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace VotingAPI.ServiceModel.ServiceModels
{
    public class UserServiceModel
    {
        [Route("/api/users/new", "POST")]
        public class CreateNewClientRequest
        {
            public string FirstName { get; set; }
            public string LastName { get; set; }
            public string Email { get; set; }
        }
    }
}
