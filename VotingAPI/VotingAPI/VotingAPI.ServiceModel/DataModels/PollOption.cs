using ServiceStack.DataAnnotations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace VotingAPI.ServiceModel.DataModels
{
    public class PollOption
    {
        [PrimaryKey]
        [AutoIncrement]
        public int Id { get; set; }

        [References(typeof(Poll))]
        public int PollId { get; set; }

        public string OptionText { get; set; }

        [Reference]
        public Poll Poll { get; set; }

        [Reference]
        public List<PollOption> Vote { get; set; }
    }

}
