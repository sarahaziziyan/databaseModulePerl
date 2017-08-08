# databaseModulePerl

This is a module that helps connecting and executing queries on Oracle Database.

#databaseFunctions.pm
includes three functions : connectToOracle, selectFromTable, insertUpdateDelete

connectToOracle :
  Takes an string argument to connect to a wanted name which is described in schemas.cfg config file. username and password is read from the config file. This function only creates a connection, so closing or dissconnectig the connection is on the hands of the developer, so be careful).

selectFromTable:
  Takes the $dbh queryString and parameters that may be described. In return it gives a code and a msg and of course the results as an arrayOfArray.
  
insertUpdateDelete:
  With using this function inserts, updates and deletes are easily done. plus it can do update with returning param.
  Input arguments are : $dbh, queryString ,parameters in the query as an array reference and returningParams as an array reference.
  It will return a code and a msg as result. Obviously because of sending the address of the returning params, the data of it will be changed if the caller has it's reference.
  
#testDatabaseFunctions.pl
This pl file is written as an example.


####### configurations ########
copy databaseFunctions.pm to /usr/lib64/perl5/ directory so that it will be seen by perl. (For Linux users)
copy databaseFunctions.pm to [your perl library in windows]

remember to copy config files to the specified directory which in this code example is /tmp/config/

Sarah Aziziyan. All rights reserved. This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.
