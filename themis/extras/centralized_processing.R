folder=''

#some files

library(tidyverse)
library(magrittr)

concept<-read.delim(file.path('n:/athena','concept.csv'),as.is=T,quote = "")
names(concept)
concept %<>% select(1,2,3,4,5,7)

files <- dir(pattern = "units-larger.csv")
files
# class(files)
#first file is not tab delimited
files <-files[-1]


#data <- files %>%  map(read_csv)

data <- files %>%  map(~read_delim(file=.x,delim = '|'))

#names of columns
data %>% map(~names(.x))

d <- data  %>%  map2_df(files, ~ mutate(.x, ID = .y)) 






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
  filter(n>4)

write_csv(ae,'extras/units.csv')


af<-d %>% group_by(concept_id,unit_concept_id) %>% summarize(n=n()) %>% arrange(desc(n)) %>% 
  left_join(concept,by = c('unit_concept_id'='concept_id')) %>% 
  left_join(concept,by='concept_id') %>% 
  filter(n>1)

write_csv(af,'extras/units-with-tests.csv')

#concept <- readr::read_csv('n:/athena/CONCEPT.csv')





files <- dir(pattern = "measurements-concepts.csv")
files
files <-files[-1]
data <- files %>%  map(~read_delim(file=.x,delim = '|'))

#names of columns
data %>% map(~names(.x))

d <- data  %>%  map2_df(files, ~ mutate(.x, ID = .y)) 

aa<-d %>% count(stratum_1) %>% arrange(desc(n))
names(concept)
aa %<>% left_join(concept,by=c('stratum_1'='concept_id'))
aa
ab<-aa  %>% 
  filter(n>2) %>% filter(domain_id=='Measurement') %>% 
  select(n,stratum_1,concept_name,vocabulary_id,concept_code)
ab

