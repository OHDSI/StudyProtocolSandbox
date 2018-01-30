folder=''
setwd('q:/w/d/ohdsi/themis/')

#some files

library(tidyverse)
library(magrittr)

concept<-read.delim(file.path('n:/athena','concept.csv'),as.is=TRUE,quote = "")
names(concept)
concept %<>% select(1,2,3,4,5,7)
names(concept)
sconcept <- concept %>% select(1,2)


#convert all to csv
# files <- dir(pattern = ".csv")
# files
# walk(files,~write_csv(read_delim(.x,delim='|'),path = .x))




#--chapter
#all files converted to pipe delimited

files <- dir(pattern = "units-larger.csv")
files
# class(files)
#first file is not tab delimited
#files <-files[-1]

#fix first file
# fl<-files[1]
# tt<-read_csv(fl)
# names(tt)
# write_delim(tt,fl,delim='|')
# write_csv(tt,paste0(fl,'-old.csv'))



#data <- files %>%  map(read_csv)

#data <- files %>%  map(~read_delim(file=.x,delim = '|'))
data <- files %>%  map(~read_csv(file=.x))

#read second files
#aa<-read_csv('two/250-units-larger.csv')



#names of columns
data2 %>% map(~names(.x))

#make all colnames lowercase
lowernames<-function(df) {colnames(df) <- tolower(colnames(df));df}
data<-map(data,lowernames)


d <- data  %>%  map2_df(files, ~ mutate(.x, ID = .y)) 

str(d)

#site staticics
ah<-d %>% count(ID)
ah

#8 datasets



# library(tidyverse)
# df <- data_frame(one = rep("hey", 10), two = seq(1:10), etc = "etc")
# 
# list_df <- list(df, df, df, df, df)
# dfnames <- c("first", "second", "third", "fourth", "fifth")
# 
# dfs <- list_df %>% map2_df(dfnames,~mutate(.x,name=.y))
# 
#               ~ mutate(id = names(list_df)),
#               .id = "Group"
# )


#which units are common accross datasets
ae<-d %>% count(unit_concept_id) %>% arrange(desc(n)) %>% 
  left_join(concept,by = c('unit_concept_id'='concept_id')) %>% 
  filter(n>=2)

write_csv(ae,'extras/units.csv')



#add names to d
names(d)
aj<-d %>% select(1,2,3,4,7) %>% 
  left_join(sconcept,by = c('unit_concept_id'='concept_id')) %>% 
  left_join(sconcept,by='concept_id') 
  
#View(aj)


#--BEST
names(d)
library(stringr)
af<-d %>% group_by(concept_id,unit_concept_id) %>%
  summarize(n=n(),dsets = paste(stringr::str_sub(ID,1,3), collapse="|")
            ,perc50=median(ratio)
            ,perc03=quantile(ratio,c(0.03)),perc25=quantile(ratio,c(0.25))
            ,perc75=quantile(ratio,c(0.75))
            ,perc97=quantile(ratio,c(0.97))
            ,mean_ratio=mean(ratio)
            #, perc0=min(statistic_value),perc100=max(statistic_value)
            )%>% 
  arrange(desc(n)) %>% 
  left_join(concept,by='concept_id') %>% 
  left_join(concept,by = c('unit_concept_id'='concept_id')) 
  
af 
names(af)
af2 <- af %>% select(-dsets) %>% select(n,perc50,concept_name.x,concept_code.y,concept_name.y,vocabulary_id.x,concept_code.x,1,2,3,mean_ratio,5,6,7,8) %>% 
   filter(n>1) %>% filter(concept_id!=0)
#str(af)
names(af2)
write_csv(af2,'extras/units-with-tests.csv')
write_csv(af,'extras/local-units-w-tests.csv')

#concept <- readr::read_csv('n:/athena/CONCEPT.csv')




#--chapter
#added 102 Stan, manuale fixed 101 and 102 to be pipe

files <- dir(pattern = "measurements-concepts.csv")
files
#files <-files[-1]
data <- files %>%  map(~read_delim(file=.x,delim = '|'))
data <- files %>%  map(~read_csv(file=.x))

#names of columns
data %>% map(~names(.x))
data
d <- data  %>%  map2_df(files, ~ mutate(.x, ID = .y)) 
str(d)
#aa<-d %>% count(stratum_1) %>% arrange(desc(n))
#abc
aa<-d %>% count(analysis_id,stratum_1) %>% arrange(desc(n))
names(concept)
aa %<>% left_join(concept,by=c('stratum_1'='concept_id'))
aa
ab<-aa  %>% 
  filter(n>=2) %>% 
  #filter(domain_id=='Measurement') %>% 
  filter(stratum_1!='0') %>% 
  select(n,stratum_1,concept_name,vocabulary_id,concept_code,domain_id,analysis_id)
ab


write_csv(ab,'extras/meas_and_obs.csv')


#sites statistics
ag<-d %>% count(analysis_id,ID)
ag
