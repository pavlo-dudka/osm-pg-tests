#!/bin/bash

baseUrl=https://maproulette.org/api/v2
curl $baseUrl/project/3439/challenges -H "apiKey: 2511|a6bd079c-9f61-4897-b766-98f208d6e8a2" |\
  jq '.[] | .id' |\
  while read challengeId; do 
    curl -X PUT $baseUrl/challenge/$challengeId/rebuild?removeUnmatched=true -H "apiKey: 2511|a6bd079c-9f61-4897-b766-98f208d6e8a2";
  done