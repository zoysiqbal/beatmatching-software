//Imported libraries
import processing.sound.*;
import controlP5.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.spi.*;
import ddf.minim.effects.*;
import ddf.minim.analysis.FFT;
import java.util.Map;
import java.util.Arrays;
import java.util.List;
import com.mpatric.mp3agic.*;

//Minim library
Minim minim;
AudioPlayer song, nextSong;
//FilePlayer object refers to duplicate object of AudioPlayer song but with additional functionalities
FilePlayer filePlayer;
//For BPM/tempo adjustment
TickRate tickRate;
AudioOutput audioOutput;
BeatDetect beat;
BeatListener listener;

//Processing library
//File Handling
String selectedPathDefault = "";
File selectedPath;
int indexFile = 0;
IntDict sortBPM;
int view;
//Pitch
FFTEffect effect;
PitchEffect processor;
float startRate;
//Transitioning
boolean paused = false;
//playLock ensures that the song object will not be accessed when the transition is occuring
boolean playLock = true;
//Tempo
//adjustment will be true when the current BPM/tempo changes. This is to ensure that the BPM/tempo value is only changed once. It will become false when the next song has loaded
boolean adjustment = false;
//adjustmentTime has been set to 30 seconds (30000 milliseconds) so BPM/tempo changes 30 seconds before the current song ends
int adjustmentTime = 30000;

//Arrays
float[][] spectraCurrent;
float[][] spectraNext;
String[] fileNames;

//Control P5 library
ControlP5 cp5;
ListBox loadTracklist;

void settings()
{
  //Sets the size of the program window
  size(900, 700);
}

void setup()
{
  //Sets the background colour to black
  background(0);
  //Allows the initial data path to be selected by the user when the folder dialog appears
  selectedPath = new File(selectedPathDefault);
  //Creates a Minim object so files can be loaded from the data directory
  minim = new Minim(this);
  //Buttons are initialised and displayed at the startup of the program
  buttons();
}

void draw()
{
  //This section of the window is for the visualiser - the background has an opacity of 35 which allows the patterns created by the Visualiser to have a fading effect
  fill(0, 35);
  //The section of the window has no border
  noStroke();
  //Creates the section of the window with the fading effect and is translated to the part where the visualiser is located
  rect(-1, 0, width, 600);

  //This section of the window is for the tracklist menu. It fills the other half of the window with a full opacity so when the menu is loaded, it is drawn over instantly
  fill(0);
  //Creates the section of the window with full opacity and is translated to the part where the tracklist menu is located
  rect(-1, 500, width, height);

  //If there is no song currently playing, then call the getCurrentSong() method
  if (song == null && playLock == false)
  {
    getCurrentSong();
  }

  //The next song in the tracklist menu is selected to be the current song playing, whether a song is playing or not
  //The playLock object is here allow the program to know when to transition to the next song and to avoid transitioning twice 
  if (song != null && !song.isPlaying() && !paused && playLock == false)
  {
    indexFile++;
    adjustment = false;
    getCurrentSong();
  }

  //Continuously displays information about the song whether a song is playing or not
  else if (song != null && (song.isPlaying() || paused) && playLock == false)
  {
    //Displays the information of the current song
    currentText();
    //Displays the information of the next song
    nextText();
    //Draws the visualiser
    drawVisualiser();
    //Displays the waveform(s)
    displayWaveform();
    //Displays information about the impending adjustment of the BPM/tempo
    text("BPM will be changed to " + sortBPM.valueArray()[nextIndexFile(indexFile)] + " and sped up / slowed down by " + float(sortBPM.valueArray()[nextIndexFile(indexFile)])/float(sortBPM.valueArray()[indexFile]) + "%", 650, 500);
  }
  //If a song is playing and has not already had the BPM adjusted (adjustment = false), then
  //adjustmentTime sets the seconds in which the BPM of the current song is adjusted to the value of the BPM of the next song
  if (adjustment == false && song != null && (song.length() - song.position()/1) < adjustmentTime)
  {
    //Prints text in console
    println("30 seconds before the next song. BPM changed to " + sortBPM.valueArray()[nextIndexFile(indexFile)] + " and sped up / slowed down by " + float(sortBPM.valueArray()[nextIndexFile(indexFile)])/float(sortBPM.valueArray()[indexFile]) + "%");
    //Prints text in program window
    text("30 seconds before the next song. BPM changed to " + sortBPM.valueArray()[nextIndexFile(indexFile)], 650, 460);
    //Adjusted library code - Minim
    //The rate of the current song playing is now set at the rate of the next song in the sorted song array list (tracklist menu)
    setRate(float(sortBPM.valueArray()[nextIndexFile(indexFile)])/float(sortBPM.valueArray()[indexFile]));

    float multiplier = float(sortBPM.valueArray()[indexFile])/float(sortBPM.valueArray()[nextIndexFile(indexFile)]);

    setPitch((float)(Math.log(multiplier)/Math.log(2.0)) * (-12));
    //adjustment is now set to true as the BPM has been adjusted
    adjustment = true;
  }
}
