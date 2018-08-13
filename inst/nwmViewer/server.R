function(input, output, session) {

  # Create param UI element
  # Available params depend on type
  output$param_selector <- renderUI({
    
    req(input$type, input$forcast_input)

    available <- eval(parse(text = paste0('nwm$', input$forcast_input)))
    
    available = eval(parse(text = paste0("available$", input$type)))
    
    choices <- setNames(available$PARAM,available$DESCRIPTION)

    selectInput(
      inputId = "param",
      label = "Paramater:",
      choices = choices,
      selected = choices[1])
  })

  # Create t UI element
  # Depends on the forecast type (short, medium, long)
  output$t_input <- renderUI({

    available <- eval(parse(text = paste0('nwm$', input$forcast_input)))
    
    choices <- available$meta$tlist
    
    choices = as.numeric(gsub("t", "", choices))
  
    selectInput(
      inputId = "t",
      label = "Time of Forecast:",
      multiple = TRUE,
      choices = choices,
      selected = choices[1])
  })
  
  # Create f UI element
  # Depends on the forecast type (short, medium, long)
  output$f_input <- renderUI({
    
    available <- eval(parse(text = paste0('nwm$', input$forcast_input)))
    
    choices <- available$meta$flist
    
    choices = as.numeric(gsub("f", "", choices))
    
    selectInput(
      inputId = "f",
      label = "F value:",
      multiple = TRUE,
      choices = choices,
      selected = choices[1])
  })

  # Create date input UI element
  # Data goes back 40 days
  output$date_input <- renderUI({
    today = Sys.Date( )
    min_date = today - 40

    dateInput(inputId = "date", label = "Date", value = NULL, min = min_date, max = today,
              format = "yyyy-mm-dd", startview = "month", weekstart = 0,
              language = "en", width = NULL, autoclose = TRUE)
  })
  
  # Forecast information
  output$forcast_info <- renderText({ 
    eval(parse(text = paste0('nwm$', input$forcast_input)))$meta$DESCRIPTION
  })


  observeEvent(input$go, {

    withProgress(message = 'Making plot', value = 0, {
      
      date = gsub("-", "", input$date)

      incProgress(.1, detail = "Getting data")
      
      files = nwm::getFilelist(config = input$forcast_input, type = as.character(input$type), date = date, t = as.numeric(input$t), f = as.numeric(input$f))
      
      AOI <- tryCatch(
        {
           getAOI(clip = list(input$search, input$clip_size, input$clip_size)) %>% nwm::downloadNWM(files, param = input$param)
        },
        error=function(cond) {
          return(NULL)
        }
      )
      
      if (!is.null(AOI)) {
        data = eval(parse(text = paste0('AOI$', input$param)))
        
        info <- eval(parse(text = paste0('nwm$', input$forcast_input, "$", input$type)))
        
        title <- info[info$PARAM == input$param, ]$DESCRIPTION
        
        title = paste("NWM: ", title)
        
        incProgress(.8, detail = "Creating Fgure")
        
        output$plot <- renderPlot({
          rasterVis::levelplot(data,
                               main = title,
                               names.attr = as.character(format(nwm::getGridTime(data), format="%m-%d %H:%M")),
                               col.regions = colorRampPalette(brewer.pal(9,"YlOrRd")))
        })
        
        output$map <- renderLeaflet({
          AOI::check(AOI = AOI$AOI)$map
          # map$map
        })
    
      } else {
        showNotification(paste("Unable to download the requested data from the RENCI server. Please try again later or use a different configuration."), 
                         duration = NULL,
                         type = "error")
      }
    

    })
    
    
    
  })
  
}
