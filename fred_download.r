comment("
fred_download.r:
Download the FRED data file with the indicated Series ID.

To run from the command line:
Rscript fred_download.r series_id
")

fred_download = function(series_id) {
  #series_id: A FRED series ID. Example: A939RX0Q048SBEA (Real gross domestic product per capita).

  #URL template. Replace XXX with series_id.
  urlx = 'https://fred.stlouisfed.org/data/XXX.txt'

  url = sub('XXX', series_id, urlx)

  #The data are preceded by explanatory text.
  #The number of lines of text varies across Series ID.
  #Consequently, it is necessary to begin by reading the url as a text file.
  txt = readLines(url) #A character vector.
  #Find the line containing the data headers.
  idx = grep('^DATE[ ]+VALUE$', txt)
  stopifnot(length(idx) == 1) #Should be unique.
	#Transform to data frame.
	conn = textConnection(txt)
	dfr = read.table(conn, skip=idx, na.strings='.')
	close(conn)
	names(dfr) = c('DATE', 'VALUE')

	#The 'read.table' function should have automatically parsed the VALUE field as numeric.
	stopifnot(class(dfr$VALUE) == 'numeric')
	#Convert the DATE field from character to Date.
	dfr$DATE = as.Date(dfr$DATE)

	#Save to disk.
	file = paste(series_id, '.csv', sep='')
	write.csv(dfr, file=file, row.names=FALSE)

	#Return the data frame.
	return(invisible(dfr))
}

#If run from the command line user must provide the Series ID as argument.
#Example command line invocation: rscript fred_download.r DEXUSEU
if (!interactive()) {
	series_id = commandArgs(trailingOnly=TRUE)
	stopifnot(length(series_id) == 1)
	fred_download(series_id)
}
