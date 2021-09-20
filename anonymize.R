library(data.table)
library(digest)

# load dataset
df <- read_csv('FILE_NAME.csv')

cols_to_mask <- c("name")

anonymize <- function(x, algo="crc32") {
  sapply(x, function(y) if(y == "" | is.na(y)) "" else digest(y, algo = algo))
}

setDT(df)
df[, (cols_to_mask) := lapply(.SD, anonymize), .SDcols = cols_to_mask]

write_csv(df,paste0(directory,"FILE_NAME.csv"))
