Novel Anticoagulants [under development]
===============


How to run on IMEDS
===============
Open an instance that runs `R 3.2`.  Such instances currently include: `linux 64-bit`

Execute `R` at the command-line and run the following commands:

```{r}
install.packages("drat")     
drat::addRepo("OHDSI")           # Enables automatic installation of OHDSI packages from github.com/OHDSI
#install.packages("NoacStudy")    # Install package and all of its dependencies   TODO

```


Acknowledgements
================
- This project is supported in part through the National Science Foundation grant IIS 1251151.
