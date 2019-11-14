using Funq;
using ServiceStack;
using ServiceStack.Data;
using ServiceStack.OrmLite;
using VotingAPI.ServiceInterface;

namespace VotingAPI
{
    //VS.NET Template Info: https://servicestack.net/vs-templates/EmptyAspNet
    public class AppHost : AppHostBase
    {
        /// <summary>
        /// Base constructor requires a Name and Assembly where web service implementation is located
        /// </summary>
        public AppHost()
            : base("VotingAPI", typeof(ClientServices).Assembly) { }

        /// <summary>
        /// Application specific configuration
        /// This method should initialize any IoC resources utilized by your web service classes.
        /// </summary>
        public override void Configure(Container container)
        {
            //Config examples
            //this.Plugins.Add(new PostmanFeature());
            //this.Plugins.Add(new CorsFeature());

            Plugins.Add(new CorsFeature());

            container.Register<IDbConnectionFactory>(c => new OrmLiteConnectionFactory(
                "Data Source=.; Initial Catalog=VotingApp; Integrated Security=True", SqlServerDialect.Provider
                ));

            GlobalRequestFilters.Add((req, res, dto) => req.ResponseContentType = MimeTypes.Json);
        }

    }
}