#!/usr/bin/perl -w
use strict;
use warnings;
use CGI;
use databaseFunctions qw(connectToOracle selectFromTable insertUpdateDelete);

#############---------------  Author Sarah Aziziyan  ---------------#############
#################################################################################
##########################                             ##########################
##########################     TestDatabaseFunctions   ##########################
##########################            1.00             ##########################
##########################         08/06/2017          ##########################
##########################                             ##########################
#################################################################################
#############==================  File History  =================#################
## v 1.00 file creation - (last modified -> 08/06/2017 - 15:40 by Sarah Aziziyan)

sub selectFromStudents {
  my $inputStdId = $ARGV[1];
  if(!defined($inputStdId)){
    print "undefined stdId\n";
  }else{
    my ($connCode,$connMsg,$dbh) = connectToOracle("payment");

    if ($connCode == 0) {
      my $query="select stdId,stdFirstName,stdLastName from students where stdId=?";
      my @params=($inputStdId);
      my ($code,$msg,$resultArray) = selectFromTable($dbh,$query,\@params);
      if ($code == 0) {

        for (my $i=0;$i<=$#{$resultArray};$i++) {
          my ($stdId,$stdFirstName,$stdLastName)=@{$resultArray->[$i]};
          print "stdId = $stdId, stdFirstName = $stdFirstName, stdLastName = $stdLastName\n";
        }     

      } else {
        ## do something
        print "error in select statement. code = $code, msg = $msg\n";
      }
      $dbh->disconnect();

    }else{
      print "database connection error, code = $connCode , msg = $connMsg\n";
    }
  }
}

sub updateStdNameWithReturningParameter{
  my $stdId           = $ARGV[1];
  my $newStdFirstName = $ARGV[2];
  if(!defined($stdId)){
    print "undefined stdId\n";
  }elsif(!defined($newStdFirstName)){
    print "undefined newStdFirstName\n";
  }else{
    my ($connCode,$connMsg,$dbh) = connectToOracle("payment");
    if ($connCode == 0) {

      my $returningStdFirstName;
      my @returningParams=([\$returningStdFirstName,20]);
      my @params = ($newStdFirstName,$stdId);
      my $query = "update students set stdFirstName=? where stdId=? returning stdFirstName into ?";
      my ($e_code,$e_msg)=insertUpdateDelete($dbh,$query,\@params,\@returningParams);
      
      if(defined($returningStdFirstName)){
        if($e_code==0 && ($returningStdFirstName eq $newStdFirstName)){
          $dbh->commit();
          print "student $stdId,$newStdFirstName has been updated\n";
        }else{
          $dbh->rollback();
          print "no error! but also data has not been updated. returningStdFirstName=$returningStdFirstName and newStdFirstName=$newStdFirstName does not match\n";
        }
      }else{
        $dbh->rollback();
        print "no error! but also data has not been updated. possibly no record has been found with the data specified\n";
      }
      $dbh->disconnect();

    }else{
      print "database connection error, code = $connCode , msg = $connMsg\n";
    }
  }
}

sub insertStudent{ ## insert student
  my $stdId         = $ARGV[1];
  my $stdFirstName  = $ARGV[2];
  my $stdLastName   = $ARGV[3];

  if(!defined($stdId)){
    print "undefined stdId\n";
  }elsif(!defined($stdFirstName)){
    print "undefined stdFirstName\n";
  }elsif(!defined($stdLastName)){
    print "undefined stdLastName\n";
  }else{
    my ($connCode,$connMsg,$dbh) = connectToOracle("payment");
    if ($connCode == 0) {
      my $insert_string = "insert into students(stdId,stdFirstName,stdLastName) values(?,?,?)";
      my @params = ($stdId,$stdFirstName,$stdLastName);
      my ($e_code,$e_msg)=insertUpdateDelete($dbh,$insert_string,\@params);
      if($e_code==0){
        $dbh->commit();
        print "student $stdId,$stdFirstName,$stdLastName has been inserted\n";
      }else{
        $dbh->rollback();
        print "statement error.rolledback, code = $e_code , msg = $e_msg\n";
      }
      $dbh -> disconnect();
    }else{ 
      print "database connection error, code = $connCode , msg = $connMsg\n";
    }
  }
}

sub deleteStudent{
  my $stdId = $ARGV[1];
  if(!defined($stdId)){
    print "undefined stdId\n";
  }else{    
    my ($connCode,$connMsg,$dbh) = connectToOracle("payment");
    if ($connCode == 0) {
      my $insert_string = "delete from students where stdId=?";
      my @params = ($stdId);
      my($e_code,$e_msg)=insertUpdateDelete($dbh,$insert_string,\@params);
      if($e_code==0){
        $dbh->commit();
        print "student with stdId=$stdId has been successfuly deleted!\n";
      }else{
        print "statement error.rolledback, code = $e_code , msg = $e_msg\n";
        $dbh->rollback();
      }
      $dbh -> disconnect();
    }else{ 
      print "database connection error, code = $connCode , msg = $connMsg\n";
    }
  }
}


sub main {
  my $method  = $ARGV[0];

  if (defined($method)) {

    if ($method eq "select"){
        selectFromStudents();
    } elsif ($method eq "insert"){
        insertStudent();
    }  elsif ($method eq "update") {
        updateStdNameWithReturningParameter();
    } elsif ($method eq "delete") {
        deleteStudent();
    } 

    else{
        print "method does not exist\n";
    }

  } else {
     print "method undefined\n";
  }
}

main();