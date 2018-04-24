
#heel stuff
tta<-as.data.frame(table(combHeel$rule_id) )

tta <-combHeel %>% group_by(rule_id) %>% tally()
tta <-combHeel %>% group_by(rule_id,analysis_id) %>% tally()

ttc <-combHeel %>% group_by(rule_id,analysis_id, dset) %>% tally()

ttb <-combHeel %>% group_by(rule_id, dset) %>% tally() %>% ungroup() %>% dplyr::rename(n2=n) %>% group_by(rule_id) %>% tally()



#tta <-combHeel %>% group_by(rule_id,achilles_heel_warning) %>% tally()
lkup_rules<-read_csv(file='https://raw.githubusercontent.com/OHDSI/Achilles/master/inst/csv/achilles_rule.csv')
tta %>% left_join(select(lkup_rules,1,2)) %>% arrange(desc(n)) %>% View()
tta %>% left_join(select(lkup_rules,1:8)) %>% arrange(desc(n)) %>% View()
tta %>% left_join(select(lkup_rules,1:8)) %>% arrange(desc(n)) %>% write_csv('c:/b/rules-2.csv')

write.table(head(combHeel,200),file="clipboard", sep="\t",row.names=F) #paste to excel

#posted on forum about rule splitting
#2017-06 new work
#join comHeel with lkup
ttd<-combHeel %>% left_join(lkup_rules)

#point111
ttb2<-ttb  %>% left_join(lkup_rules)
