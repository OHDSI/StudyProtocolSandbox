queryTest<-function(connectionDetails){
  conn<-DatabaseConnector::connect(connectionDetails)
  
  data<-DatabaseConnector::querySql(conn, "select top 10 * from OHDSI_VOCAB.DBO.CONCEPT")
  dbDisconnect(conn)
  data
}


