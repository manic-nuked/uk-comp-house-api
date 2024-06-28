# Fetch Active Companies

A script to retrieve details of active companies from the UK Companies House API. The script fetches the company name based on SIC Code, address, and postcode, and saves these details in a CSV file. It handles pagination, rate limiting, and can be configured to fetch a large number of company records. This a quicky and dirty mehod and is to be run locally - API Key is within script. That is not good practise! 

## Prerequisites

- A valid API key from Companies House.
- `jq` installed on your system for parsing JSON data.
- `curl` installed on your system for making HTTP requests.

## Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/fetch-active-companies.git
   cd fetch-active-companies
   ```

2. **Install `jq`**:
   ```bash
   brew install jq
   ```

3. **Make the Script Executable**:
   ```bash
   chmod +x fetch_active_company.sh
   ```

## Usage

1. **Configure API Key**:
   Edit the script to replace the `api_key` variable with your actual API key.
   ```bash
   api_key="your_api_key_here"
   ```

2. **Set the SIC Code**:
   Change the `sic_codes` parameter in the URL to the SIC code of the type of companies you want to fetch. The SIC codes can be found [here](https://resources.companieshouse.gov.uk/sic/).
   ```bash
   url="${search_url}?sic_codes=your_sic_code_here&items_per_page=${items_per_page}&start_index=${start_index}&company_status=active"
   ```

3. **Run the Script**:
   Execute the script by running:
   ```bash
   ./fetch_active_company_details.sh
   ```

## Script Explanation

1. **Define Variables**:
   - `api_key`: Your Companies House API key.
   - `base_url`: Base URL for the Companies House API.
   - `search_url`: URL for the advanced search endpoint.
   - `company_url`: URL for fetching detailed company information.
   - `items_per_page`: Number of items to fetch per request.
   - `output_file`: The CSV file where the results will be saved.
   - `wait_time`: Initial wait time between requests to handle rate limiting.

2. **Initialize Start Index**:
   - `start_index`: Tracks the current starting index for pagination.
   - `total_fetched`: Tracks the total number of items fetched.
   - `max_items`: Defines the total number of items to be fetched.

3. **Create or Clear Output File**:
   The script initializes or clears the output CSV file and writes the headers.

4. **Fetch Company Details**:
   The `fetch_company_details` function retrieves detailed information for each company using the company number.

5. **Pagination Loop**:
   The script handles pagination by incrementing the `start_index` and fetching subsequent batches of companies.

6. **Rate Limiting**:
   The script checks the rate limit headers from the API response and adjusts the wait time dynamically to avoid hitting the rate limits.

7. **Save Progress**:
   The script saves the current `start_index` to a file (`last_index.txt`) to allow resumption from the last fetched index in case of interruption.

## Handling Interruptions

If the script is interrupted, it can resume from where it left off by reading the `start_index` from the `last_index.txt` file. This ensures that you do not have to start the fetching process from the beginning.

## Sample Output

The output CSV file will contain the following columns:
- `Company Name`: Name of the company.
- `Address`: Full address of the company.
- `Postcode`: Postcode of the company's registered office.

## Example Output Row

```
"BRITISH DIVERS MARINE LIFE RESCUE","Lime House Regency Close Uckfield TN22 1DS","TN22 1DS"
```
