folder=''
setwd('q:/w/d/ohdsi/themis/')
getwd()




library(tidyverse)
library(magrittr)

#concept<-read.delim(file.path('n:/athena','concept.csv'),as.is=TRUE,quote = "")

 # fname='c:/temp/concept.rds'
 # concept<-read_rds(fname)

names(concept)
concept %<>% select(1,2,3,4,5,7)
names(concept)
sconcept <- concept %>% select(1,2)


#convert all to csv
# files <- dir(pattern = ".csv")
# files
# walk(files,~write_csv(read_delim(.x,delim='|'),path = .x))



# fname='c:/temp/concept.rds'
# concept<-read_rds(fname)

#--chapter --START HERE
#concept   <-read.delim(file.path('n:/athena','concept.csv'),as.is=T,quote = "")

files <- dir(pattern = "units-larger.csv")
files
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

#9 datasets (8 + au)



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
table(is.na(d$ratio))
tta<-d %>% filter(is.na(ratio))
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
  
names(af)
af2 <- af %>% select(-dsets) %>% select(n,perc50,concept_name.x,concept_code.y,concept_name.y,vocabulary_id.x,concept_code.x,1,2,3,mean_ratio,5,6,7,8) %>% 
   filter(n>1) %>% filter(concept_id!=0)
#str(af)

table(af2$n)

write_csv(af,'extras/local-units-w-tests.csv')

#tests with more than one unit
af3<-af2 %>% group_by(concept_id,concept_name.x) %>% 
  summarize(QualUnitCnt=n(),allQualUnits=paste(concept_code.y,collapse = ',')
            ,allQualUnitsNs=paste(n,collapse = ',')
            ,allQualUnitsMedians=paste(round(perc50,2),collapse = ',')
              ) %>% ungroup() %>% arrange(QualUnitCnt,desc(allQualUnitsNs),concept_id)
af2 %<>% left_join(af3)

write_csv(af2,'extras/units-with-tests.csv')
#write_csv(af2,'extras/units-with-tests-new.csv')
exppath<-'C:/q/d/GitHub/StudyProtocolSandbox/themis/extras/partial_results'
exppath
write_csv(af2,file.path(exppath,'units-with-tests.csv'))


#sites statistics
exppath<-'C:/q/d/GitHub/StudyProtocolSandbox/themis/extras/partial_results'
ag<-d %>% count(analysis_id,ID)
ag
write_csv(ag,file.path(exppath,'datasets.csv'))




#------END-----
#compare old
cf<-read_csv('extras/units-with-tests.csv')
table(cf$n)
table(af2$n)



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




#REMOVED CODE
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







#one file fix
# fname<-'au/UNSW_ePBRM_JJ_V2.csv'
# ba<-read_csv(fname)
# #some files
# bb<-ba %>% select(labcid,unitcit) %>% distinct()
# bb<-ba %>% select(count,labcid,unitcit,localname) 
# bb$analysis_id<-1807
# bb$ratio=1 #later do better group by and better logic
# bc<-bb %>% select(analysis_id,concept_id=labcid,unit_concept_id=unitcit,ratio,count,localname) %>% filter(!is.na(unit_concept_id))
# bc<-bb %>% select(analysis_id,concept_id=labcid,unit_concept_id=unitcit,ratio) %>% filter(!is.na(unit_concept_id))
# bc %<>% left_join(bc %>% count(concept_id))
# View(bc)
# write_csv(bc,'260-units-larger.csv')
# 

# 
# #another file fix
# ca<-read_csv('826-measurement-concepts-units_larger.csv')
# ca
# #analysis_id,concept_id,unit_concept_id,ratio
# cb<-ca %>%  filter(analysis_id==1807) %>% filter(stratum_1!=0)
# cc<-cb %>% group_by(stratum_1) %>% summarize(cnt=n(),sumcnt=sum(count_value)) %>% ungroup()
# options(scipen = 999) #disable exponent scientific notation
# table(cc$sumcnt==0)
# cd<-cb %>% left_join(cc) %>% mutate(ratio=count_value/sumcnt) %>%
#     arrange(stratum_2) %>% 
#     select(1,concept_id=stratum_1,unit_concept_id=stratum_2,ratio)
# cd %<>% filter(concept_id!=0)
# cd %<>% filter(!is.na(unit_concept_id))
# cd %<>% filter(!is.na(ratio))
# table(is.na(cd$ratio))
# table(cd$analysis_id)
# 
# write_csv(cd,'826-units-larger.csv')
