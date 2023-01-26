#!/bin/bash

# Create a Node.js application using the Express Generator package
npx express-generator myExpressApp --view ejs

# Change dir and install npm packages
cd myExpressApp && npm install

# Install Azure Key Vault
npm install azure-keyvault

# Resolve Vulnerabilities Issues
npm fund
npm audit fix --force

# Start the development server with debug information
DEBUG=myexpressapp:* npm start