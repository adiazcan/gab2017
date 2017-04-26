using Microsoft.Azure.KeyVault;
using Microsoft.Azure.KeyVault.Models;
using Microsoft.IdentityModel.Clients.ActiveDirectory;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web;

namespace AzureKeyVault.Services
{
    public sealed class VaultService 
    {
        private readonly MainService service;

        public VaultService(MainService service)
        {
            service.AssertNotNull(nameof(service));

            this.service = service;
        }

        private const string NotFoundErrorCode = "SecretNotFound";

        public bool IsEnabled => !string.IsNullOrEmpty(this.service.Configuration.VaultBaseAddress);

        public string Get(string identifier)
        {
            identifier.AssertNotEmpty(nameof(identifier));

            return SynchronousExecute(() => this.GetAsync(identifier));
        }

        public async Task<string> GetAsync(string identifier)
        {
            DateTime startTime;
            SecretBundle bundle;

            identifier.AssertNotEmpty(nameof(identifier));

            try
            {
                startTime = DateTime.Now;

                if (!this.IsEnabled)
                {
                    return null;
                }

                using (IKeyVaultClient client = new KeyVaultClient(GetToken))
                {
                    try
                    {
                        bundle = await client.GetSecretAsync(this.service.Configuration.VaultBaseAddress, identifier);
                    }
                    catch (KeyVaultErrorException ex)
                    {
                        if (ex.Body.Error.Code.Equals(NotFoundErrorCode, StringComparison.CurrentCultureIgnoreCase))
                        {
                            bundle = null;
                        }
                        else
                        {
                            throw;
                        }
                    }
                }

                return bundle?.Value;
            }
            finally
            {
                bundle = null;
            }
        }

        public void Store(string identifier, string value)
        {
            identifier.AssertNotEmpty(nameof(identifier));
            value.AssertNotEmpty(nameof(value));

            this.StoreAsync(identifier, value).RunSynchronously();
        }

        public async Task StoreAsync(string identifier, string value)
        {
            DateTime startTime;

            identifier.AssertNotEmpty(nameof(identifier));
            value.AssertNotEmpty(nameof(value));

            try
            {
                startTime = DateTime.Now;

                if (!this.IsEnabled)
                {
                    return;
                }

                using (IKeyVaultClient client = new KeyVaultClient(GetToken))
                {
                    await client.SetSecretAsync(this.service.Configuration.VaultBaseAddress, identifier, value);
                }
            }
            catch (Exception) { }
        }

        public async Task<string> GetToken(string authority, string resource, string scope)
        {
            var authContext = new AuthenticationContext(authority);
            var clientCred = new ClientCredential(service.Configuration.VaultApplicationId, service.Configuration.VaultApplicationSecret);
            AuthenticationResult result = await authContext.AcquireTokenAsync(resource, clientCred);

            if (result == null)
                throw new InvalidOperationException("Failed to obtain the JWT token");

            return result.AccessToken;
        }

        private static T SynchronousExecute<T>(Func<Task<T>> operation)
        {
            try
            {
                return Task.Run(async () => await operation()).Result;
            }
            catch (AggregateException ex)
            {
                if (ex.InnerException != null)
                {
                    throw ex.InnerException;
                }

                throw;
            }
        }
    }
}