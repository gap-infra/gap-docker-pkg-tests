#!/bin/sh -x

TESTGAP="./bin/gap.sh -b -m 100m -o 1g -A -q -x 80 -r"
TESTGAPauto="./bin/gap.sh -b -m 100m -o 1g -q -x 80 -r"

mkdir -p dev/log
echo 'SetAssertionLevel( 2 ); Read( "testpackage.g" ); SaveWorkspace( "wsp.g" );' | $TESTGAP
echo 'CreatePackageTestsInput( "'$1'", "testpackages.in", "dev/log/testpackages1", "'$TESTGAP' -L wsp.g", "false" );' | $TESTGAP -L wsp.g
chmod 777 testpackages.in; ./testpackages.in; rm testpackages.in
rm wsp.g

echo 'SetAssertionLevel( 2 ); Read( "testpackage.g" ); SaveWorkspace( "wsp.g" );' | exec $TESTGAPauto
echo 'CreatePackageTestsInput( "'$1'", "testpackages.in", "dev/log/testpackagesA", "'$TESTGAPauto' -L wsp.g", "auto" );' | $TESTGAPauto -L wsp.g
chmod 777 testpackages.in; ./testpackages.in; rm testpackages.in
rm wsp.g

echo 'SetAssertionLevel( 2 ); Read( "testpackage.g" ); SaveWorkspace( "wsp.g" );' | exec $TESTGAP
echo 'CreatePackageTestsInput( "'$1'", "testpackages.in", "dev/log/testpackages2", "'$TESTGAP' -L wsp.g", "true" );' | exec $TESTGAP -L wsp.g
chmod 777 testpackages.in; ./testpackages.in; rm testpackages.in
rm wsp.g
