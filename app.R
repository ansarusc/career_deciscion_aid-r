library(dash)
library(dashHtmlComponents)
library(dashCoreComponents)
library(dashBootstrapComponents)
library(tidyverse)
library(here)
library(plotly)
library(dashTable)

# Loading Data Sets
lang_data <- read_csv(here('data/Processed/lang_barplot_data.csv'))
ml_data <- read_csv(here('data/Processed/ml_barplot_data.csv'))
general_processed_data <- read_csv(here('data/Processed/general_processed_data.csv'))
fluc_data <- read_csv(here('data/Processed/Fluctuation_plot_data.csv'))


# Creating vec of job titles of interest to populate drop down
roles <- lang_data %>%
  filter(Q5 != "Student" & Q5 != "Other" & Q5 != "Currently not employed" ) %>%
  select(Q5) %>%
  distinct(Q5) %>%
  pull()

# Create list of countries
countries <- general_processed_data %>%
  select(Q3) %>%
  distinct(Q3) %>%
  pull()

#' Returns strings associated with values from slider
#'
#' @param prog_exp__value A number associated with slider
#' @return exp_range the associated string
slider_recognition <- function(prog_exp__val){
  if (prog_exp__val == 1) {
    exp_range <- '< 1 years'
  } else if (prog_exp__val == 2) {
      exp_range <- '1-2 years'
  } else if (prog_exp__val == 3) {
      exp_range <- '3-5 years'
  } else if (prog_exp__val == 4) {
      exp_range <- '5-10 years'
  } else if (prog_exp__val == 5) {
      exp_range <- '10-20 years'
  } else {
      exp_range <- '20+ years'
    }
  exp_range
}

 
app = Dash$new(external_stylesheets = dbcThemes$BOOTSTRAP)


collapse <- htmlDiv(
  list(
    dbcButton(
      "Learn more",
      id="collapse-button",
      className="mb-3",
      outline=FALSE,
      style= list('margin-top'= '10px',
        'width'= '150px',
        'background-color'= 'white',
        'color'= 'steelblue')
    )
  )
)


#' Opens and closes the learn more button
#'
#' @param is_open Boolean from app callback
#' @param n input from clicks
#' @return a named vector containing a boolean to control the button
app$callback(
  list(output("collapse", "is_open")),
  list(input("collapse-button", "n_clicks"),
       state("collapse", "is_open")),
  function(n, is_open){
    if (is.null(n[[1]]) | n[[1]] == 1) {
      return(is_open)
      
    } else if (n[[1]] %% 2 == 0) {
      return(list(TRUE))
      
    } else {
      return(list(FALSE))
    }
      
    }
)



app$layout(
  dbcContainer(
    list(
      dbcRow(
        list(
          dbcCol(
            list(
              dbcRow(
                list(
                  dbcCol(
                    list(
                      htmlH1('Data Science Decision Aid Dashboard',
                             style=list('color' = '#2E4053', 'text-align'= 'left')
                      ),
                      dbcCollapse(
                        htmlP('This dashboard has the objective of informing Data Science students, professionals and even prospects (future possible Data Sciences professionals
                the worldwide state of the art regarding most used programming languages,machine learning methods, the recommended programs to learn first with a 
                considerable aggregated value (for prospects),and yearly income of different job titles.',
                #style=list('color' = '#D6ED17FF', 'background-color' = '#606060FF')
                        ), id="collapse",
                      )
                    ),
                md=10),
                dbcCol(
                  list(
                    collapse
                  ))))),
            style=list('backgroundColor'= '#3498DB',
              'border-radius'= 3,
              'padding'= 15,
              'margin-top'= 20,
              'margin-bottom'= 20,
              'margin-right'= 15
            )))),
      htmlBr(),
      dbcRow(
        list(
          dbcCol(
            list(htmlLabel('Programming Experience (Years)'),
                 
                 dccSlider(
                   id = "prog_exp",
                   min = 1,
                   max = 6,
                   marks = list(
                     "1" = "<1",
                     "2" = "1-2",
                     "3" = "3-5",
                     "4" = "5-10",
                     "5" = "10-20",
                     "6" = "+20"),
                   value = 1),
                 htmlBr(),
                 htmlBr(),
                 htmlBr(),
                 htmlBr(),
                 
                 htmlLabel('Job Title'),
                 dccDropdown(
                   id = "role_select",
                   options = purrr::map(roles, function(roles) list(label = roles, value = roles)),
                   value = "Data Scientist"),
                 htmlBr(),
                 htmlBr(),
                 htmlBr(),
                 htmlBr(),
                 
                 htmlLabel('Country'),
                 dccDropdown(
                   id = "country_select",
                   multi = TRUE,
                   options = purrr::map(countries, function(countries) list(label = countries, value = countries)),
                   value = c('India', 'China', 'Canada', 'Colombia', 'Argentina', 'Brazil', 'United States of America'))
                 
            ),
            style=list(
              'background-color'= '#e6e6e6',
              'padding'= 15,
              'border-radius'= 3
              ),
            md=3
          ),
          dbcCol(
            list(
              dbcRow(
                list(
                  dbcCol(
                    list(htmlH6("Used Programming Languages", style = list('text-align'= 'center')),
                      dccGraph(id = 'lang_plot', style=list('border-width'= '0', 'width'='100%', 'height'='340px'))
                    )
                    ,md=5),
                  dbcCol(
                    list(htmlH6("Used Machine Learning Methods", style = list('text-align'= 'center')),
                      dccGraph(id = 'ML_plot', style=list('border-width'= '0', 'width'= '100%', 'height'= '340px'))
                    )
                    ,md=7)
                )
              ),
              htmlBr(),
              dbcRow(
                list(
                  dbcCol(
                    list(htmlH6("Education Level vs. Recommended Programming Languages", style = list('text-align'= 'center')),
                      dccGraph(id = 'Rec_lang_count_plot', style=list('border-width'= '0', 'width'='90%', 'height'='330px','text-align'= 'center'))
                    )
                    ,md=8),
                  dbcCol(list(htmlH6("Salary Ranges for the Job (USD)", style = list('text-align'= 'center')),
                    dashDataTable(
                    id = "salary_table",
                    page_size = 7,
                    style_cell=list('whiteSpace' = 'normal', 'height'= 'auto', 'textAlign' = 'center'))))
                )
              )
            )))), dbcRow(list(htmlHr(),
                             htmlP(paste0("This Data Science Decision Aid Dashboard was developed by Jacob McFarlane, Santiago Rugeles Schoonewolff, and Yuyan Guo. ",
                                          "The server was last updated at: ", Sys.Date(), ". Please find the data source below:"), 
                                   style = list('text-align'= 'left')),
                             htmlA(children = list("2020 Kaggle Machine Learning and Data Science Survey"),
                                   href = 'https://www.kaggle.com/c/kaggle-survey-2020/rules',
                                   style = list(color = 'blue')))))))
              
                

#' Generates Programming Language Graph, Handles Interactivity
#'
#' @param role Role to filter by
#' @param prog_exp Years of Experience to Filter By
#' @param country Country to filter by
#' @return a named vector containing the histogram of languages mentioned
app$callback(
  list(output('lang_plot', 'figure')),
  list(input('role_select', 'value'),
       input('prog_exp', 'value'),
       input('country_select', 'value')),
  function(role, prog_exp, countries) {
    exp_range <- slider_recognition(prog_exp)
    lang_plot <- lang_data %>%
      filter(Q5 == role & Q6 == exp_range & Q3 %in% countries) %>%
      ggplot((aes(x = forcats::fct_infreq(selected_lang)))) +
        geom_bar()+
        coord_flip() +
        xlab("") +
        ylab("Counts") +
        theme_classic() +
        # ggtitle("Used Programming Languages") +
      theme(
        plot.title = element_text(size = 9, face = "bold"),
        axis.text = element_text(size = 7),
        axis.title = element_text(size = 8))
    list(ggplotly(lang_plot))
    }
)

#' Generates ML Approach Graph, Handles Interactivity
#'
#' @param role Role to filter by
#' @param prog_exp Years of Experience to Filter By
#' @param country Country to filter by
#' @return a named vector containing the histogram of ML approaches mentioned
app$callback(
  list(output('ML_plot', 'figure')),
  list(input('role_select', 'value'),
       input('prog_exp', 'value'),
       input('country_select', 'value')),
  function(role, prog_exp, countries) {
    exp_range <- slider_recognition(prog_exp)
    ml_plot <- ml_data %>%
      filter(Q5 == role & Q6 == exp_range & Q3 %in% countries) %>%
      ggplot((aes(x = forcats::fct_infreq(selected_ml_method)))) +
      geom_bar()+
      coord_flip() +
      # ggtitle("Used ML Methods") +
      xlab("") +
      ylab("Counts") +
      theme_classic() +
      theme(
        plot.title = element_text(size = 9, face = "bold"),
        axis.text = element_text(size = 7),
        axis.title = element_text(size = 8))
    list(ggplotly(ml_plot))
  }
)


#' Generates Education Level vs. Recommended Programming Languages 
#' Graph, Handles Interactivity
#'
#' @param role Role to filter by
#' @param prog_exp Years of Experience to Filter By
#' @param country Country to filter by
#' @return a named vector containing the Edu vs. Programming langs graph
app$callback(
  list(output('Rec_lang_count_plot', 'figure')),
  list(input('role_select', 'value'),
       input('prog_exp', 'value'),
       input('country_select', 'value')),
  function(role, prog_exp, countries) {
    exp_range <- slider_recognition(prog_exp)
    general_processed_plot <- fluc_data %>%
      filter(Q5 == role & Q6 == exp_range & Q3 %in% countries) %>%
      ggplot((aes(y = Q8, x = Q4))) +
      geom_count() +
      coord_flip() +
      # ggtitle("Education Level vs. Recommended Programming Languages") +
      xlab("") +
      ylab("") +
      theme_classic() +
      theme(plot.title = element_text(hjust = 0.5)) +
      theme(
        plot.title = element_text(size = 7, face = "bold"),
        axis.text = element_text(size = 7),
        axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1),
        axis.title = element_text(size = 8))
    list(ggplotly(general_processed_plot))
  }
)


#' Generates Salary Table, Handles Interactivity
#'
#' @param role Role to filter by
#' @param prog_exp Years of Experience to Filter By
#' @param country Country to filter by
#' @return a named vector containing the data and cols for the salary table
app$callback(
  list(output('salary_table', 'data'),
       output('salary_table', 'columns')),
  list(input('role_select', 'value'),
       input('prog_exp', 'value'),
       input('country_select', 'value')),
  function(role, prog_exp, countries) {
    exp_range <- slider_recognition(prog_exp)
    percent_data <- general_processed_data %>% 
      filter(Q5 == role & Q6 == exp_range & Q3 %in% countries) %>% 
      drop_na(Q24) %>% 
      group_by(Q24) %>% 
      summarise(count = n()) %>% 
      mutate(percentage = round(count / sum(count), 4) * 100) %>% 
      mutate(`salary range` = Q24) %>% 
      arrange(desc(percentage)) %>% 
      mutate(percentage = paste(percentage, '%'))
    cols = list('salary range', 'percentage')
    columns <- cols %>%
      purrr::map(function(col) list(name = col, id = col))
    data <- df_to_list(percent_data %>% select(unlist(cols)))
    list(data, columns)
  }
)


# app$run_server()
app$run_server(host = '0.0.0.0')
