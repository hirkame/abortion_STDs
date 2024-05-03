library(RSelenium)
library(rvest)
library(readr)

# State code
state_fips_master <- read_csv("data/state_fips_master.csv")

# Function to navigate to the given URL and wait for the page to load
navigate_and_wait <- function(driver, url) {
  driver$navigate(url)
  Sys.sleep(3)
}

# Function to click the 'More' button if it exists
click_more_button <- function(driver) {
  button <- tryCatch({
    driver$findElement(using = 'xpath', "//button[contains(., 'Show More')]")
  }, error = function(e) { NULL })
  
  if (!is.null(button)) {
    button$sendKeysToElement(list(key="enter"))
    Sys.sleep(1)
  } 
}

# Function to extract and print the table if it exists
extract_table <- function(page) {
  if (length(html_nodes(page, "table")) > 0) {
    table <- html_table(html_nodes(page, "table")[[1]], fill = TRUE)
  } else {
    stop("Table not found")
  }
}

# Start RSelenium driver
rD <- rsDriver(browser = "firefox", port = 4555L, verbose = F, chromever = NULL)
remDr <- rD[["client"]]

# Loop through years and states
for (state in state_fips_master$fips) {
  for (year in 2011:2024) {
    # Define the URL of the website
    url <- paste0("https://www.countyhealthrankings.org/health-data/health-factors/health-behaviors/sexual-activity/sexually-transmitted-infections?year=",
                  year,
                  "&state=",
                  sprintf("%02d", state), # Format state code with leading zeros if necessary
                  "&tab=1")
    
    # Navigate to the URL and wait
    navigate_and_wait(remDr, url)
    
    # Click the 'More' button
    click_more_button(remDr)
    
    # Extract the page source
    page_source <- remDr$getPageSource()[[1]]
    page <- read_html(page_source)
    
    # Extract and print the table
    table <- extract_table(page)
    
    # Save table as csv
    file_name <- paste0("data/STDs/", state, "_", year, ".csv")
    write.csv(table, file_name)
    Sys.sleep(1)
  }
}

# Close the Selenium browser
remDr$close()
rD[["server"]]$stop()
