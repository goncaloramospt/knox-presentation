#!/bin/bash

az login

az ad sp create-for-rbac --scopes /subscriptions/${SUBSCRIPTION_ID} --role "Contributor"
