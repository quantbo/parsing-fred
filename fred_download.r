comment("
fred_download.r:
Download the FRED data file with the indicated Series ID and transform it to a data frame.
Optionally save the data frame to disk.
Return the data frame.

To run from the command line:
Rscript fred_download.r series_id
")

fred_download = function(series_id, save=TRUE) {
  #series_id: A FRED series ID. Example: A939RX0Q048SBEA (Real gross domestic product per capita).
  #save: If TRUE, save the data to disk as a CSV file. The file is named 'series_id.csv'.

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

  #The 'read.table' function should have automatically parsed the VALUE field as numeric or integer.
  #The call to mode covers both of these possibilities.
  stopifnot(mode(dfr$VALUE) == 'numeric')
	#Convert the DATE field from character to Date.
	dfr$DATE = as.Date(dfr$DATE)

	#Save to disk.
	if (save) {
		file = paste(series_id, '.csv', sep='')
		write.csv(dfr, file=file, row.names=FALSE)		
	}

	#Return the data frame.
	return(invisible(dfr))
}

#If run from the command line user must provide the Series ID as argument.
#Example command line invocation: Rscript fred_download.r DEXUSEU
if (!interactive()) {
	series_id = commandArgs(trailingOnly=TRUE)
	stopifnot(length(series_id) == 1)
	fred_download(series_id)
}
