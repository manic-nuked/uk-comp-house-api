#!/bin/bash

# Define variables
api_key="Your_API_Key"
base_url="https://api.company-information.service.gov.uk"
search_url="${base_url}/advanced-search/companies"
company_url="${base_url}/company"
items_per_page=100
output_file="active_company_details.csv"
wait_time=5  # Initial wait time in seconds

# Initialize start_index
start_index=0
total_fetched=0
max_items=2500  # Define the total number of items you expect

# Create or clear the output file and add headers
echo "Company Name,Address,Postcode" > $output_file

# Function to fetch company details
fetch_company_details() {
  local company_number=$1

  # Fetch company profile
  company_profile=$(curl -s -u "${api_key}:" "${company_url}/${company_number}")

  # Extract company name and address details
  company_name=$(echo "$company_profile" | jq -r '.company_name')
  address=$(echo "$company_profile" | jq -r '.registered_office_address | "\(.address_line_1 // "") \(.address_line_2 // "") \(.locality // "") \(.postal_code // "")"')
  postcode=$(echo "$company_profile" | jq -r '.registered_office_address.postal_code // ""')

  # Return formatted CSV line
  echo "\"$company_name\",\"$address\",\"$postcode\""
}

# Loop to handle pagination
while [ $total_fetched -lt $max_items ]; do
  echo "Fetching companies starting at index $start_index..."

  # Construct the URL with pagination and active status filter
  url="${search_url}?sic_codes=75000&items_per_page=${items_per_page}&start_index=${start_index}&company_status=active"
  echo "URL: $url"

  # Make the cURL request and capture headers
  response=$(curl -s -D headers.txt -u "${api_key}:" "$url")

  # Check rate limit headers
  rate_limit_remaining=$(grep -Fi 'X-Ratelimit-Remain' headers.txt | awk '{print $2}' | tr -d '\r')
  rate_limit_reset=$(grep -Fi 'X-Ratelimit-Reset' headers.txt | awk '{print $2}' | tr -d '\r')

  echo "Rate Limit Remaining: $rate_limit_remaining"
  echo "Rate Limit Reset: $rate_limit_reset"

  # Check if the response contains valid data
  if echo "$response" | jq -e '.items' > /dev/null; then
    company_count=$(echo "$response" | jq '.items | length')
    echo "Number of companies fetched: $company_count"

    if [ $company_count -eq 0 ]; then
      break
    fi

    # Process each company
    for company_number in $(echo "$response" | jq -r '.items[].company_number'); do
      csv_line=$(fetch_company_details $company_number)
      echo "$csv_line" >> $output_file
    done

    # Increment the start_index and total_fetched
    start_index=$((start_index + items_per_page))
    total_fetched=$((total_fetched + company_count))
  else
    echo "Error or no more data: $(echo "$response" | jq -r '.errors[].error')"
    break
  fi

  # If rate limit is low, wait until reset
  if [ "$rate_limit_remaining" -lt 10 ]; then
    echo "Rate limit approaching, waiting until reset..."
    sleep "$rate_limit_reset"
  else
    # Wait before the next request to avoid rate limits
    sleep $wait_time
    # Gradually increase wait time to be safer with rate limits
    wait_time=$((wait_time + 1))
  fi
done

echo "Data retrieval complete. Check the output in $output_file."
