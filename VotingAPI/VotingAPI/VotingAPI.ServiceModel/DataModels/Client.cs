using ServiceStack.DataAnnotations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace VotingAPI.ServiceModel.DataModels
{
    public class Client
    {
        [PrimaryKey]
        [AutoIncrement]
        public int Id { get; set; }

        public string FirstName { get; set; }
        public string LastName { get; set; }

        [Unique]
        public string Email { get; set; }

        [Reference]
        public List<Poll> Polls { get; set; }

        [Reference]
        public List<Vote> Votes { get; set; }
    }
}
