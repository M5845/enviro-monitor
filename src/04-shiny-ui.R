require(plyr)
require(tidyverse)
require(yaml)
require(DT)
require(ggplot2)
require(shiny)

dir.output = "../output"
myfile = file.path(dir.output, "tidy_sensor.csv")

if (!file.exists(myfile)) {
    stop(paste0("Please run 03-viz.R to create ", myfile))
}
x = read.table(myfile)

# dropdown month+year
choices.month = sort(unique(x$month))
names(choices.month) = month.name[choices.month]
choices.year = sort(unique(x$year))

# choices sensors
choices.sensors = sort(unique(x$description))

# plot labels
x$label = round(x$mean, 0)

# define UI
ui <- fluidPage(
    titlePanel("Enviro-Monitor (Shiny)"),

    sidebarLayout(
        position = "right",
        sidebarPanel(
            h2("Options"),
            selectInput("month", "Month:", choices.month),
            selectInput("year", "Year:",   choices.year),
            checkboxGroupInput("plot.options",
                "Plot options",
                c("Standard Deviation", "Labels"),
                c("Standard Deviation", "Labels"),
                inline = T
            ),
            sliderInput("range",
                label = "Temperatur",
                min = -20, max = 50, value = c(-5, 30)
            ),
            checkboxGroupInput("sensors",
                "Sensors",
                choices.sensors,
                choices.sensors,
                inline = T
            )
        ),
        mainPanel(
            h2("Plot"),
            plotOutput("plot2"),
            h2("Data"),
            DT::dataTableOutput("table")
        )
    )
)

# define server logic
server <- function(input, output) {

    getData <- function() {
        x %>%
            filter(month == input$month, year == input$year) %>%
            filter(description %in% input$sensors)
    }

    getTitle <- function() {
        paste0(month.name[as.numeric(input$month)], " ", input$year)
    }

    getDisplay <- function(y) {
        y %>% select(description, month.n, mean, sd, n, date)
    }

    output$table <- DT::renderDataTable({
        xdf = getData()
        xdf = getDisplay(xdf)
        xdf$mean = round(xdf$mean, 2)
        xdf$sd = round(xdf$sd, 2)
        xdf
    })

    output$plot2<-renderPlot({
        xdf = getData()
        mytitle = getTitle()

        g = ggplot(xdf, aes(x=day, y=mean, color=description, group = description)) +
            geom_point() +
            geom_line() +
            theme_bw() +
            ggtitle(mytitle) +
            xlab("day of month") +
            ylab("temperature (C)") +
            coord_cartesian(ylim = c(input$range[1], input$range[2]))

        if (any(input$plot.options %in% "Standard Deviation")) {
            limits = aes(ymax = mean + sd, ymin = mean - sd)
            g = g + geom_errorbar(limits, width = 0.1)
        }

        if (any(input$plot.options %in% "Labels")) {
            g = g + geom_text(nudge_y = 1, aes(label = label))
        }
        g
    })

}

# run the app
shinyApp(ui = ui, server = server)


