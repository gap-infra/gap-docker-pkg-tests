for pkgname in SortedList(RecNames( GAPInfo.PackagesInfo ) ) do
  if IsBound( GAPInfo.PackagesInfo.(pkgname)[1].TestFile) then
    Print("- PKG_NAME=",pkgname,"\n");
  fi;
od;
