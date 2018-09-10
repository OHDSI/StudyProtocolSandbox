#' check ThemisMeasurements Unit data
#' obtains analysisId 1807 and compares to reference data. Output is in export folder and as data.frame
#' @export
checkThemis <- function(connectionDetails,
                        cdmDatabaseSchema,
                        resultsDatabaseSchema = cdmDatabaseSchema,
                        outputFolder) {
  
  
  exportFolder<-file.path(outputFolder,"export")
  
  
  if (!file.exists(exportFolder))
    dir.create(exportFolder)
  
  
  
  
  #assuming colum names will be upper case for all outputs
  
  #1 derived measures 
  
  a<-Achilles::fetchAchillesAnalysisResults(connectionDetails,resultsDatabaseSchema,1807)$analysisResults
  names(a) <-tolower(names(a))
  a$measurement_concept_id<-as.integer(a$measurement_concept_id)
  a$unit_concept_id<-as.integer(a$unit_concept_id)
  
  #simulate some data #erythrocyte sedimantation rate in mm per hour
  #simulated<-data.frame(measurement_concept_id=3015183,unit_concept_id=8753)
  #a<-dplyr::bind_rows(a,simulated)
  
  
  
  ref<-read.csv(system.file("csv","S4-preferred_units-A.csv",package="DataQuality"),as.is=T)
  
  #make sure one error concept is not considered
  ref<-dplyr::filter(ref,concept_id != 4046263)
  
  #str(ref)
  
  #join by concept_id
  #str(a)
  #str(ref)
  
  comp<-dplyr::inner_join(a,ref,by=c('measurement_concept_id' = 'concept_id'))
  comp2<-dplyr::filter(comp,unit_concept_id.x!=unit_concept_id.y)
  #comp2
  #names(comp2)
  output<-dplyr::select(comp2,measurement_concept_id,dataset_unit_concept_id=unit_concept_id.y,expected_unit_concept_id=unit_concept_id.x
                        ,count_value
                        ,expected_unit_concept_name=concept_name.y
                        ,measurement_concept_name=concept_name.x.x)
  
  
  #export data
  write.csv(output,file = file.path(exportFolder,'ThemisMeasurementsUnitsCheck.csv'),row.names = F)
  
  writeLines(paste('Dataset rows considered:',nrow(a)))   
  writeLines(paste('Reference data rows considered:',nrow(ref)))   
  writeLines(paste('Output rows:',nrow(output)))   
  writeLines('Comparison was written to export folder.')  
  writeLines('Done with checking.')  
  return(output)
}