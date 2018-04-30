
curl -s -X POST http://localhost:4000/users -H "content-type: application/x-www-form-urlencoded" -d 'username=user1&orgName=Org1'

curl -s -X POST \
  http://localhost:4000/channels \
  -H "authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1MjQ1MjQ4MjcsInVzZXJuYW1lIjoiSmltIiwib3JnTmFtZSI6Ik9yZzEiLCJpYXQiOjE1MjQ0ODg4Mjd9.3a6Ew4-hl9t9oJ45rN1k_j7xUDYH10AhgUXGSreUho4" \
  -H "content-type: application/json" \
  -d '{
"channelName":"mychannel",
"channelConfigPath":"../artifacts/channel/mychannel.tx"
}'

curl -s -X POST \
  http://localhost:4000/channels/mychannel/peers \
  -H "authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1MjQ1MjQ4MjcsInVzZXJuYW1lIjoiSmltIiwib3JnTmFtZSI6Ik9yZzEiLCJpYXQiOjE1MjQ0ODg4Mjd9.3a6Ew4-hl9t9oJ45rN1k_j7xUDYH10AhgUXGSreUho4" \
  -H "content-type: application/json" \
  -d '{
"peers": ["peer0.org1.example.com","peer1.org1.example.com"]
}'

INSTALL

curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1MjQ1MjQ4MjcsInVzZXJuYW1lIjoiSmltIiwib3JnTmFtZSI6Ik9yZzEiLCJpYXQiOjE1MjQ0ODg4Mjd9.3a6Ew4-hl9t9oJ45rN1k_j7xUDYH10AhgUXGSreUho4" \
  -H "content-type: application/json" \
  -d '{
"peers": ["peer0.org1.example.com","peer1.org1.example.com"],
"chaincodeName":"mycc12",
"chaincodePath":"chaincode/assets_accounter",
"chaincodeType": "golang",
"chaincodeVersion":"v0"
}'


curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes \
  -H "authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1MjQ1MjQ4MjcsInVzZXJuYW1lIjoiSmltIiwib3JnTmFtZSI6Ik9yZzEiLCJpYXQiOjE1MjQ0ODg4Mjd9.3a6Ew4-hl9t9oJ45rN1k_j7xUDYH10AhgUXGSreUho4" \
  -H "content-type: application/json" \
  -d '{
"peers": ["peer0.org1.example.com","peer1.org1.example.com"],
"chaincodeName":"mycc",
"chaincodeVersion":"v0",
"chaincodeType": "golang",
"args":["a","100","b","200"]
}'

curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1MjQ3NzAzMDUsInVzZXJuYW1lIjoidXNlcjEiLCJvcmdOYW1lIjoiT3JnMSIsImlhdCI6MTUyNDczNDMwNX0.3jeVgP1fTcDn6teYEvPSgxL3gnVBt3TGcO1I9_mS_I4" \
  -H "content-type: application/json" \
  -d '{
"peers": ["peer0.org1.example.com","peer1.org1.example.com"],
"fcn":"createAccount",
"args":["1"]
}'


curl -s -X GET http://localhost:4000/channels/mychannel/transactions/e1d7b2b8fc0be22e92930d34370181b7361d7df52a39965df59df60316934880?peer=peer0.org1.example.com \
  -H "authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1MjQ1MjQ4MjcsInVzZXJuYW1lIjoiSmltIiwib3JnTmFtZSI6Ik9yZzEiLCJpYXQiOjE1MjQ0ODg4Mjd9.3a6Ew4-hl9t9oJ45rN1k_j7xUDYH10AhgUXGSreUho4" \
  -H "content-type: application/json"


  QUERY

curl -s -X GET \
"http://localhost:4000/channels/mychannel/chaincodes/mycc12?peer=peer0.org1.example.com&fcn=query&args=%5B%221__ACCOUNTS__%22%5D" \
-H "authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1MjQ1MjQ4MjcsInVzZXJuYW1lIjoiSmltIiwib3JnTmFtZSI6Ik9yZzEiLCJpYXQiOjE1MjQ0ODg4Mjd9.3a6Ew4-hl9t9oJ45rN1k_j7xUDYH10AhgUXGSreUho4" \
-H "content-type: application/json"


curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/json" \
  -d '{
"data": {"prop":"value"}
}'

CLASSIICCCCCCCCCCCCCCCCCCCCCCC


curl -s -X POST \
  http://localhost:4000/channels \
  -H "authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1MjQ1MjQ4MjcsInVzZXJuYW1lIjoiSmltIiwib3JnTmFtZSI6Ik9yZzEiLCJpYXQiOjE1MjQ0ODg4Mjd9.3a6Ew4-hl9t9oJ45rN1k_j7xUDYH10AhgUXGSreUho4" \
  -H "content-type: application/json" \
  -d '{
"channelName":"mychannel",
"channelConfigPath":"../artifacts/channel/mychannel.tx"
}'

curl -s -X POST \
  http://localhost:4000/channels/mychannel/peers \
  -H "authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1MjQ1MjQ4MjcsInVzZXJuYW1lIjoiSmltIiwib3JnTmFtZSI6Ik9yZzEiLCJpYXQiOjE1MjQ0ODg4Mjd9.3a6Ew4-hl9t9oJ45rN1k_j7xUDYH10AhgUXGSreUho4" \
  -H "content-type: application/json" \
  -d '{
"peers": ["peer0.org1.example.com","peer1.org1.example.com"]
}'

curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1MjQ1MjQ4MjcsInVzZXJuYW1lIjoiSmltIiwib3JnTmFtZSI6Ik9yZzEiLCJpYXQiOjE1MjQ0ODg4Mjd9.3a6Ew4-hl9t9oJ45rN1k_j7xUDYH10AhgUXGSreUho4" \
  -H "content-type: application/json" \
  -d '{
"peers": ["peer0.org1.example.com","peer1.org1.example.com"],
"chaincodeName":"mycc",
"chaincodePath":"github.com/example_cc/go",
"chaincodeType": "golang",
"chaincodeVersion":"v0"
}'


curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes \
  -H "authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1MjQ1MjQ4MjcsInVzZXJuYW1lIjoiSmltIiwib3JnTmFtZSI6Ik9yZzEiLCJpYXQiOjE1MjQ0ODg4Mjd9.3a6Ew4-hl9t9oJ45rN1k_j7xUDYH10AhgUXGSreUho4" \
  -H "content-type: application/json" \
  -d '{
"peers": ["peer0.org1.example.com","peer1.org1.example.com"],
"chaincodeName":"mycc",
"chaincodeVersion":"v0",
"chaincodeType": "golang",
"args":["a","100","b","200"]
}'

curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1MjQ1MjQ4MjcsInVzZXJuYW1lIjoiSmltIiwib3JnTmFtZSI6Ik9yZzEiLCJpYXQiOjE1MjQ0ODg4Mjd9.3a6Ew4-hl9t9oJ45rN1k_j7xUDYH10AhgUXGSreUho4" \
  -H "content-type: application/json" \
  -d '{
"peers": ["peer0.org1.example.com","peer1.org1.example.com"],
"fcn":"move",
"args":["a","b","10"]
}'
