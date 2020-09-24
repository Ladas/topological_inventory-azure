

# topological_inventory-azure

[![Build Status](https://travis-ci.org/RedHatInsights/topological_inventory-azure.svg?branch=master)](https://travis-ci.org/RedHatInsights/topological_inventory-azure)
[![Maintainability](https://api.codeclimate.com/v1/badges/f02d931e79344fc2481b/maintainability)](https://codeclimate.com/github/RedHatInsights/topological_inventory-azure/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/f02d931e79344fc2481b/test_coverage)](https://codeclimate.com/github/RedHatInsights/topological_inventory-azure/test_coverage)
[![security](https://hakiri.io/github/RedHatInsights/topological_inventory-azure/master.svg)](https://hakiri.io/github/RedHatInsights/topological_inventory-azure/master)

---

## Create Azure service principal and configure roles

Red Hat recommends configuring dedicated credentials to grant topological inventory read-only access to Azure data.

1. Once in the Azure portal, enter the _cloud shell_ by clicking on the terminal icon on the top menu bar.

2. In the shell environment, run the following command to obtain your Azure subscription ID:
   ```bash
   az account show --query "{subscription_id: id }"
   ```

   The subscription ID will be required for one of the following steps.

3. Now, run the following command to create the __TopologicalInventory__ service principle with an initial role of __Reader__. The command will return the API keys that will be used by the Azure source.

   ```bash
   az ad sp create-for-rbac -n "https://TopologicalInventory" --role "Reader" --query '{"tenant": tenant, "client_id": appId, "secret": password}'
   ```

   Note: Service principal names are global for the Azure account, so you may need to use a different name if __https://TopologicalInventory__ already exists.

4. Finally, we need to add the __Storage Account Contributor__ role to our newly created service principal, to enable topological inventory to collect storage information. This is accomplished by running the following:

   ```bash
   az role assignment create --role "Storage Account Contributor" --assignee https://TopologicalInventory --subscription <SubscriptionID>
   ```

   Note: Replace <SubscriptionID> with the value obtained in the first step.

## Assigning API keys to Azure source

The `az ad sp create-for-rbac ...` command mentioned above, should return the keys in the following format:

```json
{
  "client_id": "XXX",
  "secret": "YYY",
  "tenant": "ZZZ"
}
```

When seeding the source information via the scripts in the [guides](https://github.com/RedHatInsights/topological_inventory-guides) repository, assign these values in your `config.sh` as follows:

```bash
export AZURE_CLIENT_ID="XXX"
export AZURE_CLIENT_SECRET="YYY"
export AZURE_TENANT_ID="ZZZ"
```
