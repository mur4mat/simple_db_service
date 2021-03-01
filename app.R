library(shiny)
library(dplyr)
library(RMySQL)

source("R/mysql_functions.R")
source("R/mysql_setup.R")
source("R/mysql_tables_fields.R")

ui <- navbarPage(
  "Simple DB Service",
  tabPanel("Quickguide",
           column(6, offset=1, 
                  wellPanel(
                    h2("Adding data"),
                    tags$div(
                      "You can add data about bands and musicians in",
                      tags$b("Add records"),
                      "tab. In order to add record to the database, follow steps:",
                      tags$ul(
                        tags$li("Type the band/musician name in proper text input field."),
                        tags$li("Click on Add Band/Add Musician button."),
                        tags$li("Record will be added immediately. Proper table will be updated with new record.")
                      )
                    )
                  ), 
                  wellPanel(
                    h2("Defining relations"),
                    tags$div(
                      "You can define relations between bands, musicians and bands-musicians in",
                      tags$b("Define relations"),
                      "tab. In order to define relation between two records, follow steps:",
                      tags$ul(
                        tags$li("Choose the tables from which the records You want to relate with dropdown input. 
                                Depending on the selected option, proper tables will appear."),
                        tags$li("Choose the record from the first table."),
                        tags$li("Choose the record from the second table."),
                        tags$li("(optional) If You are about to relate musician with a band, an ",
                                tags$i("Is active member"),
                                "option will be enabled."),
                        tags$li("Click on Add Relation button.")
                      )
                    )
                  ),
                  wellPanel(
                    h2("Viewing relationships"),
                    tags$div(
                      "The last tab, ",
                      tags$b("View relations"),
                      "is responsible for viewing existing data and its relations.
                      In order to view added records and their relations:",
                      tags$ul(
                        tags$li("Choose the table You want to view relations with dropdown input.
                                Depending on the selected option, proper table will appear."),
                        tags$li("Choose the desired record from the table."),
                        tags$li("Related data will appear in Realted bands and Related musicians, respectively.")
                      )
                    )
                  )
           )
  ),
  tabPanel("Add Records",
           column(3, 
                  offset=2, 
                  wellPanel(
                    tags$h2("Add band"),
                    tags$hr(),
                    textInput("band_name", "Band name", ""),
                    actionButton("submit_band", "Add Band"),
                    tags$hr(),
                    DT::dataTableOutput("bands")
                  )
           ),
           column(3,
                  offset=2,
                  wellPanel(
                    tags$h2("Add musician"),
                    tags$hr(),
                    textInput("musician_name", "Musician name", ""),
                    actionButton("submit_musician", "Add Musician"),
                    tags$hr(),
                    DT::dataTableOutput("musicians")
                  )
           )
  ),
  tabPanel("Define relations",
           shinyjs::useShinyjs(),
           fluidRow(
             column(3,
                    offset = 2,
                    wellPanel(
                      tags$h2("First table"),
                      tags$hr(),
                      DT::dataTableOutput("first_table")
                    )
             ),
             column(2, align="center",
                    selectInput("select_relation",
                                label = "Choose relation:",
                                choices = list("Band-Musician" = 1, 
                                               "Band-Band" = 2,
                                               "Musician-Musician" = 3), 
                                selected = 1),
                    shinyjs::disabled(
                      checkboxInput("is_active", "Is active member?")
                    ),
                    actionButton("submit_rel", "Define relation")),
             column(3, 
                    wellPanel(
                      tags$h2("Second table"),
                      tags$hr(),
                      DT::dataTableOutput("second_table")
                    )
             )
           )
  ),
  tabPanel("View relations",
           column(3,
                  offset=1,
                  wellPanel(
                    tags$h2("Choose band/musician"),
                    tags$hr(),
                    selectInput("select",
                                label = "Choose band/musician:",
                                choices = list("Bands" = 1, 
                                               "Musicians" = 2), 
                                selected = 1),
                    tags$hr(),
                    DT::dataTableOutput("rel_choose_table")
                  )
           ),
           column(3,
                  offset=1,
                  wellPanel(
                    tags$h2("Related bands"),
                    tags$hr(),
                    DT::dataTableOutput("rel1")
                  )
           ),
           column(3,
                  wellPanel(
                    tags$h2("Related musicians"),
                    tags$hr(),
                    DT::dataTableOutput("rel2")
                  )
           )
  ),
  tabPanel("Justification",
           column(6, offset=1, 
                  wellPanel(
                    h2("User interface justification"),
                    h3("GUI vs API"),
                    tags$div(
                      "GUI refers to a software platform that displays back-end data in a visually
                      coherent way to help users interact with a computer application. It presents
                      objects that convey information and represent actions that the user can take.
                      GUI allows you to use picture-like items, such as icons, cursors, and buttons,
                      o tell a computer operating system what you want. Using these objects, GUI allows
                      you to navigate to different parts of an application.",
                      tags$br(),
                      tags$br(),
                      "APIs allow applications to interact and communicate with an external server using some 
                      simple commands. Using APIs, developers can create streamlined processes that don't keep 
                      re-inventing the wheel or building functionalities that already in existence. 
                      They help programmers to add new features to applications, and improve the speed and 
                      efficiency of the development process."
                    ),
                    h3("GUI justification"),
                    tags$div("The main goal of this task was to create a simple database service, that will allow 
                      interaction between database and end user. Contrary to the API, GUI doesn't require too 
                      much technical know-how or the need to memorize different methods and languages"
                    )
                  ), 
                  wellPanel(
                    h2("Database justification"),
                    h3("SQLite vs MySQL"),
                    tags$div(
                      "There are plenty of popular solutions for applications using relational database management systems.
                      Most popular among developers are SQLite, MySQL and PostgreSQL and each has its benefits, as well as drawbacks.",
                      tags$br(),
                      tags$br(),
                      "SQLite is self-contained, file-based RDBMS known for its portability, reliability, and strong performance even 
                      in low-memory environments. Although its advantages, it has limited concurrency, no user management option and 
                      provides no protection.",
                      tags$br(),
                      tags$br(),
                      "MySQL is one of the most popular open-source RDBMS. MySQL is relatively straightforward, thanks in large part to its 
                      exhaustive documentation and large community of developers, as well as the abundance of MySQL-related resources online. 
                      Biggest advantages of MySQL are easy of use, supporting user management which allows to grant access privileges on 
                      a user-by-user basis.",
                      tags$br(),
                      tags$br(),
                      "For following task, MySQL has been chosen."
                    )
                  )
           )
  )
)

server <- function(input, output, session) {
  
  bands_data <- reactive({
    input$submit_band
    loadData(table_bands)
  })
  
  musicians_data <- reactive({
    input$submit_musician
    loadData(table_musicians)
  })
  
  formDataBands <- reactive({
    data <- sapply(fields_bands, function(x) input[[x]])
    data
  })
  
  formDataMusicians <- reactive({
    data <- sapply(fields_musicians, function(x) input[[x]])
    data
  })
  
  observeEvent(input$submit_band, {
    saveData(formDataBands(), table_bands)
  })
  
  observeEvent(input$submit_musician, {
    saveData(formDataMusicians(), table_musicians)
  })
  
  output$bands <- DT::renderDataTable({
    adjust_datatable(bands_data())
  })
  
  output$musicians <- DT::renderDataTable({
    adjust_datatable(musicians_data())
  })
  
  bands_musicians_rel_data <- reactive({
    input$submit_rel
    loadData(table_bands_musicians_rel)
  })
  
  bands_rel_data <- reactive({
    input$submit_rel
    loadData(table_bands_rel)
  })
  
  musicians_rel_data <- reactive({
    input$submit_rel
    loadData(table_musicians_rel)
  })
  
  observe({
    shinyjs::toggleState(id = "is_active", 
                         input$select_relation == 1)
  })
  
  formDataRel <- reactive({
    switch(input$select_relation,
           "1"={
             data <- c(bands_data()[input$first_table_rows_selected,1],
                       musicians_data()[input$second_table_rows_selected,1],
                       input$is_active)
             names(data) <- fields_bands_musicians_rel
           },
           "2"={
             data <- c(bands_data()[input$first_table_rows_selected,1],
                       bands_data()[input$second_table_rows_selected,1])
             names(data) <- fields_bands_rel
           },
           "3"={
             data <- c(musicians_data()[input$first_table_rows_selected,1],
                       musicians_data()[input$second_table_rows_selected,1])
             names(data) <- fields_musicians_rel}
    )
    data
  })
  
  tableRel <- reactive({
    switch(input$select_relation,
           "1"=table_bands_musicians_rel,
           "2"=table_bands_rel,
           "3"=table_musicians_rel
    )
  })
  
  observeEvent(input$submit_rel, {
    saveData(formDataRel(), tableRel())
  })
  
  table_bm_rel <- reactive({
    validate(
      need(!is.null(input$rel_choose_table_rows_selected), "Please choose record")
    )
    musicians_data() %>%
      left_join(bands_musicians_rel_data(), by=c("musician_id")) %>%
      filter(band_id==bands_data()[input$rel_choose_table_rows_selected,1]) %>%
      select(musician_name, is_active)
  })
  
  table_mb_rel <- reactive({
    validate(
      need(!is.null(input$rel_choose_table_rows_selected), "Please choose record")
    )
    bands_data() %>%
      left_join(bands_musicians_rel_data(), by=c("band_id")) %>%
      filter(musician_id==musicians_data()[input$rel_choose_table_rows_selected,1]) %>%
      select(band_name, is_active)
  })
  
  table_b_rel <- reactive({
    validate(
      need(!is.null(input$rel_choose_table_rows_selected), "Please choose record")
    )
    union(
      bands_rel_data() %>% 
        left_join(bands_data(), by=c("band_id2"="band_id")) %>%
        filter(band_id1==bands_data()[input$rel_choose_table_rows_selected,1]),
      bands_rel_data() %>% 
        left_join(bands_data(), by=c("band_id1"="band_id")) %>%
        filter(band_id2==bands_data()[input$rel_choose_table_rows_selected,1])
    ) %>% 
      select(band_name)
  })
  
  table_m_rel <- reactive({
    validate(
      need(!is.null(input$rel_choose_table_rows_selected), "Please choose record")
    )
    union(
      musicians_rel_data() %>%
        left_join(musicians_data(), by=c("musician_id2"="musician_id")) %>%
        filter(musician_id1==musicians_data()[input$rel_choose_table_rows_selected,1]),
      musicians_rel_data() %>%
        left_join(musicians_data(), by=c("musician_id1"="musician_id")) %>%
        filter(musician_id2==musicians_data()[input$rel_choose_table_rows_selected,1])
    ) %>%
      select(musician_name)
  })
  
  table_mb_rel <- reactive({
    validate(
      need(!is.null(input$rel_choose_table_rows_selected), "Please choose record")
    )
    bands_data() %>%
      left_join(bands_musicians_rel_data(), by=c("band_id")) %>%
      filter(musician_id==musicians_data()[input$rel_choose_table_rows_selected,1]) %>%
      select(band_name, is_active)
  })
  
  
  
  output$first_table <- DT::renderDataTable({
    adjust_datatable(
      switch(input$select_relation,
             "1"=bands_data(),
             "2"=bands_data(),
             "3"=musicians_data()
      )
    )
  })
  
  output$second_table <- DT::renderDataTable({
    adjust_datatable(
      switch(input$select_relation,
             "1"=musicians_data(),
             "2"=bands_data(),
             "3"=musicians_data()
      )
    )
  })
  
  output$rel_choose_table <- DT::renderDataTable({
    adjust_datatable(
      switch(input$select,
             "1"=bands_data(),
             "2"=musicians_data()
      )
    )
  })
  
  output$rel1 <- DT::renderDataTable({
    adjust_datatable(
      switch(input$select,
             "1"=table_b_rel(),
             "2"=table_mb_rel()
      )
    )
  })
  
  output$rel2 <- DT::renderDataTable({
    adjust_datatable(
      switch(input$select,
             "1"=table_bm_rel(),
             "2"=table_m_rel()
      )
    )
  })
  
}

shinyApp(ui, server)