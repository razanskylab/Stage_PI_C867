# Stage_PI_C867
Motor controller library to interface Physik Instrumente C867 controller.

A [`MATLAB`](https://ch.mathworks.com/) interface class to access the functionality of the drivers and librarys provided by [PI](https://www.physikinstrumente.de/de/) for their stages. Tested and validated for stage driver C867 but can potentially be adapted to other drivers as well. If you need a certain version of the control software contact PI support.

Requirements:

*  Windows (tested version: 10)
*  MATLAB (tested version: 2019b)
*  PIMikroMove (tested version: 2.29.3.0)
*  C compiler to load librarys (tested with Visual Studio 2019, could not get it running with MinGW)

Before using the library make sure that the path for the DLL  (property `LIB_PATH`) is set to the correct destination on your PC.


# Known errors and bugs

### Library not found error by calllib

Simply restart MATLAB, this happens when you try to set the external trigger but it is already up and running.