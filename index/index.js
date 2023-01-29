const { KeyClient } = require("@azure/keyvault-keys");
const { DefaultAzureCredential } = require("@azure/identity");

async function main() {

    // DefaultAzureCredential expects the following three environment variables:
    // - AZURE_TENANT_ID: The tenant ID in Azure Active Directory
    // - AZURE_CLIENT_ID: The application (client) ID registered in the AAD tenant
    // - AZURE_CLIENT_SECRET: The client secret for the registered application
    const credential = new DefaultAzureCredential();

    const keyVaultName = process.env["KEY_VAULT_NAME"];
    const url = "https://" + keyVaultName + ".vault.azure.net";

    const client = new KeyClient(url, credential);

    const uniqueString = Date.now();
    const keyName = `sample-key-${uniqueString}`;
    const ecKeyName = `sample-ec-key-${uniqueString}`;
    const rsaKeyName = `sample-rsa-key-${uniqueString}`;

    // Create key using the general method
    const result = await client.createKey(keyName, "EC");
    console.log("key: ", result);

    // Create key using specialized key creation methods
    const ecResult = await client.createEcKey(ecKeyName, { curve: "P-256" });
    const rsaResult = await client.createRsaKey(rsaKeyName, { keySize: 2048 });
    console.log("Elliptic curve key: ", ecResult);
    console.log("RSA Key: ", rsaResult);

    // Get a specific key
    const key = await client.getKey(keyName);
    console.log("key: ", key);

    // Or list the keys we have
    for await (const keyProperties of client.listPropertiesOfKeys()) {
    const key = await client.getKey(keyProperties.name);
    console.log("key: ", key);
    }

    // Update the key
    const updatedKey = await client.updateKeyProperties(keyName, result.properties.version, {
    enabled: false
    });
    console.log("updated key: ", updatedKey);

    // Delete the key - the key is soft-deleted but not yet purged
    const deletePoller = await client.beginDeleteKey(keyName);
    await deletePoller.pollUntilDone();

    const deletedKey = await client.getDeletedKey(keyName);
    console.log("deleted key: ", deletedKey);

    // Purge the key - the key is permanently deleted
    // This operation could take some time to complete
    console.time("purge a single key");
    await client.purgeDeletedKey(keyName);
    console.timeEnd("purge a single key");
}

main().catch((error) => {
  console.error("An error occurred:", error);
  process.exit(1);
});