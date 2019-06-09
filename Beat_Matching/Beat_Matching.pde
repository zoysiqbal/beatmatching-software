//Tempo adjustment
//Sets the rate of the current song to the rate of the next song
void setRate(float value) {
  tickRate.value.setLastValue(value);
}

void setPitch(float offset) {
  startRate = processor.shiftRate;
  processor.setShiftRate(startRate + offset);
}

//Adjusted library code - Minim
void adjustTempo() {
  tickRate = new TickRate(1.f);
  //Prevents audio from being too distorted at lower levels
  tickRate.setInterpolation(true);
  //Patches the FilePlayer object to LineOut in order to adjust the rate
  audioOutput = minim.getLineOut();
  filePlayer.patch(tickRate).patch(audioOutput);
}

//Pitch adjustment
//Method to adjust pitch of vocals
void keyPressed() {
  if (keyCode == UP) {
    //Adjusted code taken from Saba Motto (https://github.com/sabamotto/PitchShifter)
    startRate = processor.shiftRate;
    processor.setShiftRate(startRate+0.01f);
  } else if (keyCode == DOWN) {
    startRate = processor.shiftRate;
    processor.setShiftRate(startRate-0.01f);
  }
}
