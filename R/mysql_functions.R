saveData <- function(data, table){
  tryCatch({
    # Connect to the database
    db <- dbConnect(RMySQL::MySQL(), dbname = databaseName, host = options()$mysql$host, 
                    port = options()$mysql$port, user = options()$mysql$user, 
                    password = options()$mysql$password)
    # Construct the update query by looping over the data fields
    query <- sprintf(
      "INSERT INTO %s (%s) VALUES ('%s')",
      table,
      paste(names(data), collapse = ", "),
      paste(data, collapse = "', '")
    )
    
    dbExecute(db, query)
    dbDisconnect(db)
    showModal(
      modalDialog(
        title = "Success!",
        tags$i("Record added")
      )
    )},
    error = function(e){
      showModal(
        modalDialog(
          title = "Error Occurred",
          tags$i("Please enter valid query and try again"),br(),br(),
          tags$b("Error:"),br(),
          tags$code(e$message)
        )
      )
    })
}

loadData <- function(table) {
  # Connect to the database
  db <- dbConnect(RMySQL::MySQL(), dbname = databaseName, host = options()$mysql$host, 
                  port = options()$mysql$port, user = options()$mysql$user, 
                  password = options()$mysql$password)
  # Construct the fetching query
  query <- sprintf("SELECT * FROM %s", table)
  # Submit the fetch query and disconnect
  data <- dbGetQuery(db, query)
  dbDisconnect(db)
  data
}

adjust_datatable <- function(data){
  DT::datatable(
    data,
    selection = "single",
    rownames= FALSE,
    options=list(
      "lengthChange" = FALSE
    )
  )   
}