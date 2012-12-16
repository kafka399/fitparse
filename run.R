
logs=system(paste('python','/home/git/garmin/garmin.py'),intern=TRUE)
setwd('/home/git/fitparse/')
if(tail(logs,1)=="Done!")
{
  for(datalength in 2:length(grep("Downloading ",logs)))
  {
  filename=logs[(grep("Downloading ",logs)[datalength])]
  #filename='Downloading 2012-10-07_16-22-49-80-25045.fit - File transfer completed'
  filename=unlist(lapply(strsplit(filename,' '),function(y){y[2]}))
  #/home/kafka/.config/garmin-extractor/3848469561/activities/
  #filename='2012-11-11_16-00-58-80-20473.fit'
  
  #filename='2012-10-26_21-11-41-80-36600.fit'
  #filename='2012-11-10_19-33-10-80-19277.fit'

  workout=system(paste('python','/home/git/python-fitparse/run.py',filename),intern=TRUE)
  workout=do.call(rbind,strsplit(workout,';'))
  colnames(workout)=workout[1,]
  workout=data.frame(tail(workout,-1),stringsAsFactors=F)

  workout[,2:6]=apply(workout[,2:6],2,as.numeric)
  workout$heart_rate=ifelse(workout$heart_rate!='None',as.numeric(workout$heart_rate),workout$heart_rate)
  write.csv2(workout,paste('~/Dropbox/garmin/csv/',substr(filename,1,16),'.csv',sep=''),row.names=F,quote=F)
  
  #source('workout.R')
  require(knitr); 
  require(markdown)
  knit('/home/git/fitparse/workout.R', '/home/git/fitparse/workout.md');
  markdownToHTML('/home/git/fitparse/workout.md',paste('~/Dropbox/garmin/',substr(filename,1,16),'.html',sep=''));
  
  system(paste('echo "<a href=\"',substr(filename,1,16),'.html\">',substr(filename,1,16),
               '.html</a></br>">>~/Dropbox/garmin/index.html', sep=''))
  }
}