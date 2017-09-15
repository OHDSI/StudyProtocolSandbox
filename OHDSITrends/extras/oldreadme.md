# Analysis of trends in EHR data

Yohan Sumithipala, Vojtech Huser

This package will analyze data measures (from Achilles that are also ackowledged by [DQC collaborative](http://repository.edm-forum.org/dqc))

Pilot development uses isolated R scripts and  R markdwown scripts. Gradually, functionality is moved into package functions. Non-OMOP input data is supported as well as ability to link OMOP dataset directly using OHSI [DatabaseConnector](https://github.com/OHDSI/DatabaseConnector) approach (and possibly webAPI mode as well).

## Grouping
Ability to view related events (e.g., drug ingredients by class, drug ingredients by disease indication, related procedures) is enabled by knowledge bases that provide this grouping. See examples [here](inst/tsv)

## Examples

### Rising (drug_era events)
#### Mupirocin
![pic1](extras/images/Mupirocin.JPG)
#### Ondansetron
![pic1](extras/images/Ondansetron.JPG)
### Declining (drug_era events)
#### Verapamil
![pic1](extras/images/Verapamil.JPG)
#### Nabumethone
![pic1](extras/images/Nabumethone.JPG)
