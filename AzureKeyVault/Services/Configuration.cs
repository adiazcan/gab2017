using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Web;

namespace AzureKeyVault.Services
{
    public class Configuration
    {
        private readonly MainService service;

        public Configuration(MainService service)
        {
            service.AssertNotNull(nameof(service));

            this.service = service;
        }

        public string VaultApplicationSecret => ConfigurationManager.AppSettings["VaultApplicationSecret"];
        public string VaultApplicationId => ConfigurationManager.AppSettings["VaultApplicationId"];
        public string VaultApplicationTenantId => ConfigurationManager.AppSettings["VaultApplicationTenantId"];
        public string VaultBaseAddress => ConfigurationManager.AppSettings["VaultBaseAddress"];

        public string DB => this.GetConfigurationValue("DB");
        
        private string GetConfigurationValue(string identifier)
        {
            DateTime startTime;
            string value;

            identifier.AssertNotNull(nameof(identifier));

            try
            {
                startTime = DateTime.Now;

                value = this.service.Vault.Get(identifier);

                if (string.IsNullOrEmpty(value))
                {
                    value = ConfigurationManager.AppSettings[identifier];
                }

                return value;
            }
            catch (Exception)
            {
                return null;
            }
        }
    }
}