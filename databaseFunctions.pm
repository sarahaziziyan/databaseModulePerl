package databaseFunctions;
use strict;
use warnings;
use Exporter qw(import);
our @EXPORT_OK = qw(connectToOracle selectFromTable insertUpdateDelete);

#############---------------  Author Sarah Aziziyan  ---------------#############
#################################################################################
##########################                             ##########################
##########################      DATABASE FUNCTIONS     ##########################
##########################             1.00            ##########################
##########################          08/06/2017         ##########################
##########################                             ##########################
#################################################################################
#############==================  File History  =================#################
## v 1.00 file creation - (last modified -> 08/06/2017 - 15:40 by Sarah Aziziyan)

sub connectToOracle{
    my $name = shift;
    $ENV{"ORACLE_HOME"}     = "/u01/app/oracle/product/11.2.0.3/db";          ## YOUR ORACLE_HOME
    $ENV{"LD_LIBRARY_PATH"} = "/u01/app/oracle/product/11.2.0.3/db/lib";      ## YOUR LD_LIBRARY_PATH
    $ENV{"NLS_LANG"}        = ".AL32UTF8";
    my $e_code  = 0;
    my $e_msg   = "";
    use DBI;
    my %commonConfig = do "/var/www/config/common.cfg";     ## config file that describes genral information about the database
    my %schemaConfig = do "/var/www/config/schemas.cfg";    ## confir file that specifies username and password for the schemas
    my $dbh = DBI->connect("dbi:Oracle:host=$commonConfig{dbhost};sid=$commonConfig{sid};port=$commonConfig{port}",$schemaConfig{$name}{schemaname},$schemaConfig{$name}{schemapass},{RaiseError=>0,PrintError=>0,AutoCommit=>0});
    if ($dbh) {
      $e_code = 0;
      $e_msg  = "";
    } else {
      $e_code = $DBI::err;
      $e_msg  = $DBI::errstr;
    }
    return ($e_code,$e_msg,$dbh);
}

sub selectFromTable{ ## works for non BLOB/CLOB types
  my ($dbh,$selectString,$params) = @_;
  my $e_code = 0;
  my $e_msg  = "";
  my $results;

  my $sth=$dbh->prepare($selectString);
  if ($sth) {
      for(my $i=0;$i<=$#{$params};$i++){
        $sth->bind_param(($i+1),$params->[$i]);
      }        
      if($sth->execute()){
          ($results) = $sth->fetchall_arrayref();
          makeAllDefined($results);     ## makes all fetched attributes defined with the default value of ""
      }else{
          $e_code = $dbh->err();
          $e_msg  = $dbh->errstr();
      }        
  }else{
      $e_code = $dbh->err();
      $e_msg  = $dbh->errstr();
  }
  return ($e_code,$e_msg,$results);
}

sub insertUpdateDelete{
  my ($dbh,$insertString,$params,$returningParams) = @_;
  my $e_code = 0;
  my $e_msg  = "";

  my $sth=$dbh->prepare($insertString);
  if ($sth) {
      my $i;
      for($i=0;$i<=$#{$params};$i++){
        $sth->bind_param(($i+1),$params->[$i]);
      }            
      if ($#{$returningParams}>=0) {
        for(my $j=$i,my $k=0;$j<=$#{$returningParams}+$i;$j++,$k++) {
            $sth->bind_param_inout($j+1,$returningParams->[$k][0],$returningParams->[$k][1]);
        }
      }
      if(!$sth->execute()){
          $e_code = $dbh->err();
          $e_msg  = $dbh->errstr();
      }            
  }else{
      $e_code = $dbh->err();
      $e_msg  = $dbh->errstr();
  }
  return ($e_code,$e_msg);
}

sub makeAllDefined{ ## makes all fetched attributes defined
  my $results = shift;    
  for(my $i=0;$i<=$#{$results};$i++){          
    for(my $j=0;$j<=$#{$results->[$i]};$j++){
      if(!defined($results->[$i][$j])){
          ($results->[$i][$j]) = "";
      }
    }
  }
}