# setting the directory of your hand history files
setwd('../pokerstars/HandHistory/mylogin')

# setting a string common to all files names to be loaded
buy_in <- 'hand'

# loading unstructured data to R environment
data <- load_data(buy_in)

# building the dataset
mylogin <- "AAA"
df <- build_dataset(data)
df <- df[!is.na(df$name),]

# exporting the dataset to csv
directory <- "./"
write_csv(df,paste0(directory,"result.csv"))
