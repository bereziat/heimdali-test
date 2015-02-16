<div id="table-of-contents">
<h2>Table of Contents</h2>
<div id="text-table-of-contents">
<ul>
<li><a href="#sec-1">1. Makes your Assimage code Heimdali compatible</a></li>
</ul>
</div>
</div>


# Makes your Assimage code Heimdali compatible<a id="sec-1" name="sec-1"></a>

1.  Edit your `toolsXXX.hxx` file, add top of the file the following lines:
    
        #include "heimdali/itkhelper.hxx"
        using namespace Heimdali;
	and remove this one:
2.  Edit your `AssimXXX.cpp` (or `SimulationXXX.cpp`) file and replace the
    following sequence of codes:
    
        InrImage <float> Obsim(ObsFile);
        Obsim.openForRead();
        Obsim.read();
        Obsim.close();
