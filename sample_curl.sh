curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/json" \
  -d '{
"data": {"prop":"value"}
}'


curl -s -X GET \
  http://localhost:4000/users/8f64bf40-ed01-4a80-992f-e3548a3437b8 \
  -H "content-type: application/json"


