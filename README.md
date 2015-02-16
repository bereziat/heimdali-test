# heimdali-test

## Makes your Assimage code Heimdali compatible

1. Edit your toolsXXX.hxx file, add top of the file the following lines:
   `#include "heimdali/itkhelper.hxx"`
   `using namespace Heimdali;`
   
2. Edit your AssimXXX.cpp (or SimulationXXX.cpp) file and replace the
following sequence of code:
	`InrImage <float> Obsim(ObsFile);
	Obsim.openForRead();
	Obsim.read();
	Obsim.close();`

by:
	`ImageFloat::Pointer Obsim = OpenAndReadImage(ObsFile);`

3.


	
