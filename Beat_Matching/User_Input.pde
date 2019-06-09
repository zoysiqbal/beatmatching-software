//Adjusted library code - ControlP5
//Adds GUI controls in the form of interactive buttons
void buttons()
{
  cp5 = new ControlP5(this);
  cp5.addButton("loadFolder").setPosition(300, 50).setSize(70, 20);
  cp5.addButton("playSong").setPosition(370, 50).setSize(70, 20);
  cp5.addButton("nextSong").setPosition(440, 50).setSize(70, 20);
  cp5.addButton("previousSong").setPosition(510, 50).setSize(70, 20);
}

//Method for functionality of the playSong button
void playSong()
{
  if (song.isPlaying())
  {
    //All songs need to pause so that the visualiser and audio will pause accordingly
    song.pause();
    filePlayer.pause();
    nextSong.pause();
    paused=true;
  } else {
    //AudioPlayer object song needs to be muted audibly whilst FilePlayer object filePlayer can audibly play and be manipulated by BPM/tempo adjustment methods
    song.play();
    song.mute();
    filePlayer.play();
    nextSong.play();
    nextSong.mute();
    paused=false;
  }
}

//Method for functionality of the nextSong button
public void nextSong()
{
  //Iterates to the next file in the array list
  indexFile++;
  //When the last song has been selected, the next song is reset to the first file in the array
  if (indexFile>=fileNames.length)
    indexFile = 0;
  getCurrentSong();
}

//Method for functionality of the nextSong button
public void previousSong() {
  //Iterates to the previous file in the array list
  indexFile--;
  //When the last song has been selected, the next song is reset to the first file in the array
  if (indexFile>=fileNames.length)
    indexFile = 0;
  getCurrentSong();
}

//Force stops all audio
void stop()
{
  song.close();
  filePlayer.close();
  nextSong.close();
  minim.stop();
  super.stop();
}

//Method which allows the user to skip to any part of the song using the mouse input
void mousePressed()
{
  if (song!=null) {
    int position = int(map(mouseX, 0, width, 0, song.length()));
    song.cue(position);
    filePlayer.cue(position);
  }
}

//Method that displays information about the current song playing
void currentText() {
  if (fileNames!=null)
  {
    try
    {
      if (fileNames.length > indexFile)
      {
        //Adjusted library code - Mp3agic
        //Method to retrieve metadata from files
        Mp3File mp3file = new Mp3File(fileNames[indexFile]);
        ID3v2 id3v2Tag = mp3file.getId3v2Tag();
        fill(255);
        textAlign(RIGHT);
        if (song != null)
        {
          //Displays metadata information about the current song
          text("Current song", 250, 42);
          text("Title : "+ id3v2Tag.getTitle(), 250, 57);
          text("Artist : "+ id3v2Tag.getArtist(), 250, 73);
          text("Album : "+ id3v2Tag.getAlbum(), 250, 89);
          text("Year : "+ id3v2Tag.getYear(), 250, 105);
          text("BPM :" + id3v2Tag.getBPM(), 250, 121);
        }
        textAlign(LEFT);
        text("Waveform for : "+ id3v2Tag.getTitle(), 10, 500);
        text("Pitch can be manually adjusted by using up or down arrow keys", 650, 480);
      }
    }
    catch(IOException ie) {
    }
    catch(UnsupportedTagException ute) {
    }
    catch(InvalidDataException ide) {
    }
  }
}

//Method that displays information about the next song that is queued to play
void nextText()
{
  try
  {
    if (fileNames.length > nextIndexFile(indexFile))
    {
      //Adjusted library code - Mp3agic
      //Method to retrieve metadata from files
      Mp3File nextSong = new Mp3File(fileNames[nextIndexFile(indexFile)]);
      ID3v2 id3v2Tag = nextSong.getId3v2Tag();
      fill(255);
      textAlign(RIGHT);
      if (song != null)
      {
        //Displays metadata information about the next song
        text("Next song", 800, 42);
        text("Title : "+ id3v2Tag.getTitle(), 800, 57);
        text("Artist : "+ id3v2Tag.getArtist(), 800, 73);
        text("Album : "+ id3v2Tag.getAlbum(), 800, 89);
        text("Year : "+ id3v2Tag.getYear(), 800, 105);
        text("BPM :" + id3v2Tag.getBPM(), 800, 121);
      }
      textAlign(LEFT);
      text("Waveform for : "+ id3v2Tag.getTitle(), 10, 600);
    }
  }
  catch(IOException ie) {
    ie.printStackTrace();
  }
  catch(UnsupportedTagException ute) {
    ute.printStackTrace();
  }
  catch(InvalidDataException ide) {
    ide.printStackTrace();
  }
}

void sortTracklist()
{
  //Populates the tracklist menu with the files sorted in order of ascending BPM
  populateTracklist(sortBPM.keyArray());
  try
  {
    if (!song.isPlaying() && !paused) 
    {
      //Iterates to the next file
      indexFile++;
      //When the last song has been selected, the next song is reset to the first file in the array
      if (indexFile>=fileNames.length)
        indexFile = 0;
      getCurrentSong();
    }
  }
  catch (Exception e) {
  }
}

void populateTracklist(String[] localArray)
{
  //Updates the tracklist menu whenever a new folder is selected
  loadTracklist.clear();
  for (int i = view; i < localArray.length; i++)
  {
    //Populates the tracklist menu with the contents of the selected folder
    loadTracklist.addItem(localArray[i].substring(selectedPathDefault.length()), i);
  }
}  

void loadTracklist(int index)
{
  //playLock is set to true as a new song is being transitioned to
  playLock = true;
  indexFile = index;
  getCurrentSong();
  analyseUsingAudioSample(indexFile);
  playLock = false;
}

//Method that stylises the tracklist menu
void initialiseTracklist()
{
  loadTracklist = cp5.addListBox("loadTracklist")
    .setPosition(width/2, 200)
    .setSize(300, 200)
    .setItemHeight(15)
    .setBarHeight(15)
    .setColorBackground(color(0))
    .setColorForeground(color(0, 45, 90))
    .setColorActive(color(0, 116, 217));

  loadTracklist.getCaptionLabel().toUpperCase(true);
  loadTracklist.getCaptionLabel().set("Tracklist");
  loadTracklist.getCaptionLabel().setColor(color(255));
}
