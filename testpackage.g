#############################################################################
##
#F  CreatePackageTestsInput( <scriptfile>, <outfile>, <gap>, <other> )
##
##  writes the file <scriptfile> that starts a new GAP session using the
##  command <gap> (including all command line options) for each test file
##  of a package (given by the component `TestFile' in the record stored in
##  its `PackageInfo.g' file) and reads this file. The output of all tests 
##  is collected in the files <outfile>.<packagename>
##  GAP} is started as <gap> (including all command line options).
##  <other> may be true, false or "auto" to specify whether all available
##  packages are loaded, not loaded or only autoloaded packages. This mode
##  is actually managed in the Makefile, and is passed to this function 
##  just to be printed in the information messages.
##bin
BindGlobal( "CreatePackageTestsInput", function( name, scriptfile, outfile, gap, other )
    local result, entry, pair, testfile;

    SizeScreen( [ 1000 ] );
    InitializePackagesInfoRecords( false );
    result:= "";
    
    Append( result, "TIMESTAMP=`date -u +_%Y-%m-%d-%H-%M`\n" );

      for entry in GAPInfo.PackagesInfo.( name ) do
        if IsBound( entry.InstallationPath ) and IsBound( entry.TestFile ) then
          testfile := Filename( DirectoriesPackageLibrary( name, "" ), entry.TestFile );
          if testfile <> fail then
            Append( result, Concatenation(
                    "echo 'Testing ", name, " ", entry.Version, ", test=", 
		            testfile, ", all packages=", other, "'\n" ) );
            Append( result, Concatenation( "echo ",
                    "'============================OUTPUT START=============================='",
                    " > ", outfile, "$TIMESTAMP.", name, "\n" ) );
            Append( result, Concatenation(
                    "echo 'SetUserPreference(\"UseColorsInTerminal\",false); ",
                    "RunPackageTests( \"", name,
                    "\", \"", entry.Version, "\", \"", entry.TestFile,
                    "\", \"", other, "\" );' | ", gap, 
                    " >> ", outfile, "$TIMESTAMP.", name, "\n" ) );
            Append( result, Concatenation( "echo ",
                    "'============================OUTPUT END================================'",
                    " >> ", outfile, "$TIMESTAMP.", name, "\n" ) );
          else
            Append( result, Concatenation(
                    "echo 'failed to find test files for the ", name, " package'\n") );
          fi;            
        fi;
      od;

    PrintTo( scriptfile, result );
    end );


#############################################################################
##
#F  RunPackageTests( <pkgname>, <version>, <testfile>, <other> )
##
##  loads the package <pkgname> in version <version>,
##  and reads the file <testfile> (a path relative to the package directory).
##  If <other> is `true' then all other available packages are also loaded.
##
##  The file <testfile> can either be a file that contains 
##  `Test' statements and therefore must be read with `Read',
##  or it can be a file that itself must be read with `Test';
##  the latter is detected from the occurrence of a substring
##  `"START_TEST"' in the file.
##
BindGlobal( "RunPackageTests", function( pkgname, version, testfile, other )
    local file, PKGTSTHDR, str;

    if LoadPackage( pkgname, Concatenation( "=", version ) ) = fail then
      Print( "#I  RunPackageTests: package `",
             pkgname, "' (version ", version, ") not loadable\n" );
      return;
    fi;
    if other = "true" then
      LoadAllPackages();
    fi;
    PKGTSTHDR := Concatenation( "\"", pkgname, "\", \"", version, "\", \"",
           testfile, "\", ", other );
    Print( "#I  RunPackageTests(", PKGTSTHDR, ");\n" );
    ShowSystemInformation();
    file:= Filename( DirectoriesPackageLibrary( pkgname, "" ), testfile );
    str:= StringFile( file );
    if not IsString( str ) then
      Print( "#I  RunPackageTests: file `", testfile, "' for package `",
             pkgname, "' (version ", version, ") not readable\n" );
      return;
    fi;
    if PositionSublist( str, "gap> START_TEST(" ) = fail then
      if not READ( file ) then
        Print( "#I  RunPackageTests: file `", testfile, "' for package `",
               pkgname, "' (version ", version, ") not readable\n" );
      fi;
    else
      if not Test( file, rec(compareFunction := "uptowhitespace") ) then
        Print( "#I  Errors detected while testing package ", pkgname, " ", version, "\n",
               "#I  using the test file `", testfile, "'\n");
      else
        Print( "#I  No errors detected while testing package ", pkgname, " ", version, "\n",
               "#I  using the test file `", testfile, "'\n");
      fi;
    fi;

    Print( "#I  RunPackageTests(", PKGTSTHDR, "): runtime ", Runtime(), "\n" );
    end );