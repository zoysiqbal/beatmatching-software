Visualiser sampleVisualiser;
ArrayList<ddf.minim.AudioSample> Samples = new ArrayList<ddf.minim.AudioSample>();

int lowBand;
int highBand;
int onsetsThreshold; 
int sensitivity;

float angleNoise, radiusNoise;
float angle = -PI/6;
float radius;
float colour = 180;
int transition = -1;

//Adjusted library code - Minim
class BeatListener implements AudioListener
{
  private BeatDetect beat;
  private AudioPlayer source;

  BeatListener(BeatDetect beat, AudioPlayer source)
  {
    this.source = source;
    this.source.addListener(this);
    this.beat = beat;
  }

  void samples(float[] samps)
  {
    beat.detect(source.mix);
  }

  void samples(float[] sampsL, float[] sampsR)
  {
    beat.detect(source.mix);
  }
}

//Method to initialise visualiser properties
void visualiserSetup() {
  //Initialises frequency band range in order to accurately detect beats
  lowBand = 0;
  highBand = 8;
  onsetsThreshold = 6;

  if (sampleVisualiser == null)
  {
    sampleVisualiser = new Visualiser(lowBand, highBand, onsetsThreshold);
  }

  //Adjusted library code - Minim
  beat = new BeatDetect(audioOutput.bufferSize(), filePlayer.sampleRate());
  sensitivity = 10;
  beat.setSensitivity(sensitivity);
  listener = new BeatListener(beat, song);

  //Adjusted code - taken from Generative Art: A Practical Guide Using Processing Book by Matt Pearson
  angleNoise = random(10);
  radiusNoise = random(10);
}

class Visualiser {
  int onsetThreshold;
  int lowBand;
  int highBand;
  //Detects whether a beat has occured or not
  boolean onset;

  //Constructor
  Visualiser(int lb, int hb, int t) {
    lowBand = lb;
    highBand = hb; 
    onsetThreshold  = t;
  }

  void setOnset(boolean b) {
    onset = b;
  }

  void setLowBand(int l) {
    lowBand = l;
  }

  void setHighBand(int h) {
    highBand = h;
  }

  void setOnsetThreshold(int t) {
    onsetThreshold = t;
  }

  int getLowBand() {
    return lowBand;
  }

  int getHighBand() {
    return highBand;
  }

  int getOnsetThreshold() {
    return onsetThreshold;
  }

  void visualiserAttributes() {
    //Adjusted code taken from Generative Art: A Practical Guide Using Processing Book by Matt Pearson
    radiusNoise += 0.005;
    radius = (noise(radiusNoise)*150) + 1;
    angleNoise += 0.005; 
    angle += (noise(angleNoise)*6) - 3;
    if (angle > 360) {
      angle -= 360;
    } else if (angle < 0) {
      angle += 360;
    }

    //Adjusted code taken from Abhinav Kr (https://github.com/black/Music-Visualization)
    int bufferSize = audioOutput.bufferSize();
    for (int i = 0; i < bufferSize - 1; i+=4) {
      float x1 = (radius)*cos(i*2*PI/bufferSize);
      float y1 = (radius)*sin(i*2*PI/bufferSize);
      float x2 = (radius + audioOutput.left.get(i)*100)*cos(i*2*PI/bufferSize);
      float y2 = (radius + audioOutput.left.get(i)*100)*sin(i*2*PI/bufferSize);

      //Adjusted code - taken from Generative Art: A Practical Guide Using Processing Book by Matt Pearson
      colour += transition;
      if (colour > 140) {
        transition = 1;
      } else if (colour < 250) {
        transition = -1;
      }
      stroke(colour, 110);
      strokeWeight(0.1);
      line(x1 + width/4, y1 + height/2, x2 + width/4, y2 + height/2);
    }
  }
}

//Method for constructing the visualiser and distorting the shape
void drawVisualiser() {
  try {
    if (sampleVisualiser != null)
      //If a beat is detected then increase the angleNoise and radiusNoise variables to visually represent beat detection using shape distortion
      if (beat != null && beat.isRange(sampleVisualiser.getLowBand(), sampleVisualiser.getHighBand(), 
        sampleVisualiser.getOnsetThreshold())) {
        angleNoise++;
        radiusNoise++;
      }
    sampleVisualiser.visualiserAttributes();
  }
  catch(Exception ie) {
    ie.printStackTrace();
  }
}
