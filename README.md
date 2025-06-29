# MiniDisplayTester

This is a program for Apple II computers to test various display modes.  The tests are simple and are intended as an aid for people working on emulators or other hardware such as FPGA cores or video generators.

![A simple menu for getting to various image types](assets/github-image.png)

It's designed to run on an Apple II under ProDOS for full compatibility across the line of systems.  However, if you load it to address $2000 and jump to that address it should work without any OS, which is helpful if you haven't emulated an entire Apple II yet.  (It will relocate above to $4000 upon start to be able to draw on the high resolution screen.)