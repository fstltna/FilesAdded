# FilesAdded
Saves a list of files being added to post about it to Discord later.

Included Utilities:
==
- **perladd** (1.0) - Scans the current folder for new files and adds them to a list of files to be posted to Discord later.
- **file_announce** (1.0) - This posts a list of files that you have added using perladd to Discord. It posts as content, not a attachment!
- **file_remove** (1.0) - This removes a file from your processed list so it can be imported with perladd again.
- **updseen** (1.0) - Updates the perladd /root/.filesseen file to fix issues - Not usually needed...

Basic Workflow
==
**cd /source_dir**

**perladd**    <- this will add all the files in the current folder to the queue

**_repeat for each directory to be added_**

**file_announce**   <- this will post all the entries for the previous files to your Discord server.

