## `r unlist(strsplit(filename,'_'))[1]`

```{r comment=NA,echo=FALSE,message=FALSE,results='asis'}
require('ggplot2')
require(gridExtra)
#setwd('/home/git/fitparse/')
#workout<-read.table('~/Dropbox/garmin/workout_2012-12-05.csv',sep=';',header=T,stringsAsFactors=F)

workout$timestamp=as.POSIXct(strptime(workout$timestamp,'%Y-%m-%d %H:%M:%S'))
workout$timestamp=c(0,as.numeric(tail(workout$timestamp,-1)-head(workout$timestamp,-1)))
workout$speed[1]=2
workout$speed[(workout$speed==0)]=NA
workout$speed=na.locf(workout$speed)
#workout$speed[1]=workout$speed[2]
workout$speed=1000/workout$speed/60

workout$speed[25:nrow(workout)]=rollmean(workout$speed,25,align='right')
workout$speed[5:24]=rollmean(workout$speed[1:24],5,align='right')
workout$speed[2:4]=rollmean(workout$speed[1:4],2,align='right')
#workout$speed[1]=workout$speed[2]
```
```{r pace, figure=TRUE,fig.cap='',comment=NA,echo=FALSE,message=FALSE}
grid.arrange(
  ggplot(workout,aes(distance,speed))+geom_line()+xlab("distance")+ylab("Pace: min/km"),
  #ggplot(workout,aes(cumsum(workout$timestamp/60),speed))+geom_line()+xlab("minutes")+ylab("min/km")
  ggplot(workout,aes(distance,altitude))+geom_area()+
  coord_cartesian(ylim=c(min(as.numeric(workout$altitude))-10, max(as.numeric(workout$altitude))+10))
  )
```

```{r heart, figure=TRUE,fig.cap='',comment=NA,echo=FALSE,message=FALSE}
grid.arrange(
ggplot(workout,aes(distance,heart_rate))+geom_line(),
ggplot(workout,aes(distance,altitude))+geom_area()+
  coord_cartesian(ylim=c(min(workout$altitude)-10, max(workout$altitude)+10))
)
```

### `r paste('Max heart rate:',max(workout$heart_rate),' Avg.heart rate:',round(mean(workout$heart_rate)))`

```{r comment=NA,echo=FALSE,message=FALSE,results='asis'}
pace = (workout$distance-head(c(0,workout$distance),-1))
pace[which(pace==0)]=NA
if(!is.na(pace[2]))  {
  pace[1]=pace[2]
} else {
  pace[2]=1;pace[1]=1}
pace=na.locf(pace)
pace=data.frame(m=round(workout$distance-head(c(0,workout$distance),-1)),
                s=workout$timestamp/pace)
pace$s[which(pace$m==0)]=0
ts=data.frame(m=0,s=.001)
sec=0
for(i in 2:nrow(pace))
{
  
  x=sec+1:pace$m[i]
  ts=rbind(ts,data.frame(m=x,s=rep(pace$s[i],length(x))))
  sec=last(x)
}
ts$s=cumsum(ts$s)
laps=seq(from=1,to=ceiling(last(ts$m)),by=1000)
if(last(laps)!= last(ts$m))
  laps=c(laps,last(ts$m))

laps=(ts$s[tail(laps,-1)]-ts$s[head(laps,-1)])/60/(((ts$m[tail(laps,-1)]-ts$m[head(laps,-1)]))/1000)
mins=round((laps-floor(laps))*60)
mins=ifelse(sapply(mins,function(x)nchar(as.character(x)))!=2,paste("0",mins,sep=''),as.character(mins))
laps=data.frame(value=laps,text=paste(floor(laps),":",mins,sep=''))

mins = round((mean(laps$value)-floor(mean(laps$value)))*60)
mins=ifelse(sapply(mins,function(x)nchar(as.character(x)))!=2,paste("0",mins,sep=''),as.character(mins))

mins=paste('Average pace: ',floor(mean(laps$value)),':',mins,sep='')
```

```{r heart_plot, figure=TRUE,fig.cap='',comment=NA,echo=FALSE,message=FALSE}
ggplot(laps,aes(1:nrow(laps),value))+geom_bar(stat="identity")+geom_text(aes(label=text), vjust=-1)+
  coord_cartesian(ylim=c(min(laps$value)-1, max(laps$value)+1))+ylab('lap')+xlab('time')
```


### `r mins`


```{r lapsai,echo=FALSE,results='asis'}
#The mapping Garmin uses (180 degrees to 2^31 semicircles) allows them
#to use a standard 32 bit unsigned integer to represent the full 360
#degrees of longitude. Thus you get the maximum precision that 32 bits
#allows you (about double what you'd get from a floating point value),
#and they still get to use integer arithmetic instead of floating point
#on the internal processor. 
```

```{r comment=NA,echo=FALSE,message=FALSE,results='asis',warning=FALSE,error=FALSE}
require(RgoogleMaps)

col=list()
for(i in 1:ceiling(last(workout$distance)/1000))
{
  col[i]=last(which(workout$distance<i*1000+1 & workout$distance>i*1000+1-1000))
}
col=unlist(col)
bb=qbbox(as.double(mean(workout$position_lat*180/2^31)),as.double(mean(workout$position_long*180/2^31)))
sz=c(550, 500)
myMap=GetMap.bbox(bb$lonR,bb$latR,destfile ='test.png',maptype='mobile',zoom=14,size = sz,GRAYSCALE =TRUE)
```

```{r maps, figure=TRUE,fig.cap='',comment=NA,echo=FALSE,message=FALSE}
PlotOnStaticMap(myMap,lat = workout$position_lat*180/2^31,lon=workout$position_long*180/2^31,size = sz, cex=.2,pch=20,col=c('red'), add=F);
TextOnStaticMap(myMap,lat = (workout$position_lat*180/2^31)[col],lon=(workout$position_long*180/2^31)[col],cex=.8,pch=20,col=c('blue'), add=T,labels=round(workout$distance[col]/1000));
```