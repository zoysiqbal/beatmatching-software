//Method to return the contents of the next file in the tracklist menu
int nextIndexFile(int indexFile)
{
  int output = indexFile + 1;
  output = output % fileNames.length;
  return output;
}

//Method which retrieves the current song selected by the user from the tracklist menu
void getCurrentSong()
{  
  //If a file has been selected
  if (fileNames.length > 0)
  {  
    //Stops the song that was playing previously
    if (song != null)
    {
      song.close();
    }
    if (filePlayer != null)
    {
      filePlayer.close();
    }
    if (minim != null)
    {
      minim.stop();
    }
    //Retrieves the song in the array of loaded files and passes the path so song is loaded into program
    song = minim.loadFile(fileNames[indexFile]);
    nextSong = minim.loadFile(fileNames[nextIndexFile(indexFile)]);
    //song is an object of type AudioPlayer which streams a sound file from disk. filePlayer is an object of type FilePlayer which allows audio files...
    //...to be played in the same way as an AudioPlayer object does; however, it also allows advanced manipulation of the file such as...
    //...setRate (adjusting the speed at which the file is played at)
    filePlayer = new FilePlayer(minim.loadFileStream(fileNames[indexFile]));
    //filePlayer (FilePlayer object) is needed to adjust the BPM/tempo whereas song (AudioPlayer object) is needed for the waveform(s) and visualiser
    //Both songs have to be playing simultaneously; however, AudioPlayer objects are audibly muted in this instance
    song.play();
    song.mute();
    nextSong.play();
    nextSong.mute();
    filePlayer.play();
    //Calls method adjustTempo() to adjust the rate at which the song is playing
    adjustTempo();
    //When the new song has been selected, other methods (visualiser and waveform(s)) must also be initialised and updated to correspond to the new file/song selection
    visualiserSetup();
    
    processor = new PitchEffect();
    effect = new FFTEffect(audioOutput.bufferSize(), filePlayer.sampleRate(), processor);
    effect.setPrecision(3);
    audioOutput.addEffect(effect);
    
    if (song!=null)
    {
      //Waveform analysis with the new file selected
      analyseUsingAudioSample(indexFile);
    }
  }
}

//Method to load requested file into sample buffer of set size 1024
void loadSample(int index)
{
  //If sample is empty then load the current song file selected into sample buffer
  if (Samples.get(index) == null)
  {
    Samples.set(index, minim.loadSample(fileNames[index], 1024));
  }
}

//Method to retrieve the contents of the folder
void getFolder()
{
  if (selectedPath.getAbsolutePath().equals(""))
  {
    selectedPath = new File (dataPath(""));
  }
  //User selected path is stored in the directory object
  File directory = new File(selectedPath.getAbsolutePath()); 
  //List of files in user selected folder is stored in an array
  File[] filePathNames = directory.listFiles();
  //Creates an array with zero elements (avoids returning a null error)
  fileNames = new String[0];
  if (filePathNames!=null)
  {
    //IntDict was chosen as a way to sort the list by BPM values as it uses associates String 'keys' with integer values
    sortBPM = new IntDict();
    for (int i = 0; i < filePathNames.length; i++)
    {
      try
      {
        //Adjusted library code - Mp3agic
        //BPM tags are extracted from the list of loaded audio files
        Mp3File mp3file = new Mp3File(filePathNames[i]);
        ID3v2 id3v2Tag = mp3file.getId3v2Tag();
        //A new key/value pair is created between the BPM value and the file names
        sortBPM.set(filePathNames[i].getAbsolutePath(), id3v2Tag.getBPM());
      }
      catch(IOException ie) {
      }
      catch(UnsupportedTagException ute) {
      }
      catch(InvalidDataException ide) {
      }
    }
  }
  //BPM tag values are sorted in ascending order
  sortBPM.sortValues();
  //Initially, fileNames contained the alphabetical sorting of the songs so the file name did not match the correct song when selected
  //sortBPM.keyArray() assigned the correct file name to the correct song
  fileNames = sortBPM.keyArray();
  //Increases the size of the array if necessary
  for (int i=0; i<fileNames.length; i++)
  {
    Samples.add(null);
  }
  //Current song is loaded
  loadSample(indexFile);
  //When the file has finished loading, the playLock is set back to false
  playLock = false;
}

//Method to load folder into the program - accessed via GUI button
void loadFolder()
{
  //Opens folder dialog for user to select a folder to load into the program
  selectFolder("Select a folder to process:", "folderSelected");
}

//Method that allows a folder to be selected
void folderSelected(File selection) {
  playLock = true;
  selectedPathDefault = selection.getAbsolutePath();
  selectedPath = new File(selectedPathDefault);
  //Minim object is initialised everytime a new folder is selected
  minim = new Minim(this);
  //Retrieves contents of folder
  getFolder();
  //Updates the tracklist menu
  initialiseTracklist();
  sortTracklist();
}
