require(plyr)
require(tidyverse)
require(yaml)

dir.data = "../data"
dir.output = "../output"

cfg = yaml.load_file(file.path(dir.data, "cfg_sensors.yaml"))

# labels from config
mylabels = ldply(cfg, function(x) c(x$id, x$description))
colnames(mylabels) = c("id", "description")

# input
myfiles = list.files(dir.output, "\\d\\d-\\d\\d_sensors.csv", full.names = T)
content = ldply(myfiles, read_tsv, col_names = F)
colnames(content) = c("date", "type", "id", "description", "value")

# preprocessing
content$posixDate = as.POSIXct(content$date, format= "%Y-%m-%d %H:%M:%S")
content$day = format(content$posixDate, "%d")
content$month = format(content$posixDate, "%m")
content$month.n = format(content$posixDate, "%B")
content$year = format(content$posixDate, "%Y")
content$description = mylabels$description[match(content$id, mylabels$id)]

# temperatur
con.temp = content %>%
    filter(type == "temp", id != "piBoard", !is.na(value), !is.na(description)) %>%
    group_by(day, month, year, description, month.n) %>%
    summarize(
        mean = mean(value),
        sd = sd(value),
        n = length(value),
        date = paste(month[1], year[1], sep = "-")
    )

write.table(con.temp, file.path(dir.output, "tidy_sensor.csv"))

