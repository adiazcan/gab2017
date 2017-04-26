using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace AzureKeyVault.Services
{
    public class MainService
    {
        private static Configuration configuration;
        public Configuration Configuration => configuration ?? (configuration = new Configuration(this));

        private static VaultService vault;
        public VaultService Vault => vault ?? (vault = new VaultService(this));
    }
}