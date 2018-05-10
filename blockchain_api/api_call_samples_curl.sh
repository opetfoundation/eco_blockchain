# Create the user record.
curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/json" \
  -d '{"prop":"value", "prop2":"value2"}'

# Retrive the user record (user user UID from the create call).
curl -s -X GET \
  http://localhost:4000/users/6e66410e-5e38-4b95-8763-975ff68bb492 \
  -H "content-type: application/json"

# Create the document for the user.
curl -s -X POST \
  http://localhost:4000/documents/6e66410e-5e38-4b95-8763-975ff68bb492 \
  -H "content-type: application/json" \
  -d '{"doc1":"value", "doc2":"value2"}'

# Retrive the document.
curl -s -X GET \
  http://localhost:4000/documents/9f86941f-3c8b-49f0-a0f8-39f8106b346f/9a2f8700-fd3a-4db0-872f-5184657d4731 \
  -H "content-type: application/json"
