//Adjusted library code - Minim
void analyseUsingAudioSample(int indexSample)
{
  //Retrieves current song's sample data
  loadSample(indexSample);
  //Retrieves next song's sample data
  loadSample(nextIndexFile(indexSample));
  //Retrieves the left channel of the audio as a float array
  float[] currentLeftChannel = Samples.get(indexSample).getChannel(ddf.minim.AudioSample.LEFT);
  float[] nextLeftChannel = Samples.get(nextIndexFile(indexSample)).getChannel(ddf.minim.AudioSample.LEFT);

  //Sample buffer size is 1024
  int fftSize = 1024;
  //An array is created for copying sample data into the FFT object for both audio
  float[] currentFFTSamples = new float[fftSize];
  float[] nextFFTSamples = new float[fftSize];
  ddf.minim.analysis.FFT currentFFT = new ddf.minim.analysis.FFT(fftSize, Samples.get(indexSample).sampleRate());
  ddf.minim.analysis.FFT nextFFT = new ddf.minim.analysis.FFT(fftSize, Samples.get(nextIndexFile(indexSample)).sampleRate());

  //Both samples are analysed in chunks
  int currentTotalChunks = (currentLeftChannel.length/fftSize) + 1;
  int nextTotalChunks = (nextLeftChannel.length/fftSize) + 1;

  //A 2D array is allocated which will hold the spectrum data for all chunks
  //Spectrum size is always half the number of samples analysed therefore fftSize/2
  spectraCurrent = new float[currentTotalChunks][fftSize/2];
  spectraNext = new float[nextTotalChunks][fftSize/2];
  for (int chunkIdx = 0; chunkIdx < currentTotalChunks; ++chunkIdx)
  {
    int chunkStartIndex = chunkIdx * fftSize;
    //The chunk size will always be fftSize, except for the last chunk which will consist of however many samples are left in source
    int chunkSize = min(currentLeftChannel.length - chunkStartIndex, fftSize);
    //First chunk is copied into analysis array
    arrayCopy(currentLeftChannel, chunkStartIndex, currentFFTSamples, 0, chunkSize);
    //If the chunk is smaller than the fftSize, the analysis buffer is padded out with zeros
    if (chunkSize < fftSize)
    {
      Arrays.fill(currentFFTSamples, chunkSize, currentFFTSamples.length - 1, 0.0);
    }
    //Buffer is analysed
    currentFFT.forward(currentFFTSamples);
    //Resulting spectrum is copied into spectra array
    for (int i = 0; i < 512; i++)
    {
      spectraCurrent[chunkIdx][i] = currentFFT.getBand(i);
    }
  }
  //Process is repeated for the next song's sample data
  for (int chunkIdx = 0; chunkIdx < nextTotalChunks; ++chunkIdx)
  {
    int chunkStartIndex = chunkIdx * fftSize;
    //The chunk size will always be fftSize, except for the last chunk which will consist of however many samples are left in source
    int chunkSize = min(nextLeftChannel.length - chunkStartIndex, fftSize);
    //First chunk is copied into analysis array
    arrayCopy(nextLeftChannel, chunkStartIndex, nextFFTSamples, 0, chunkSize);
    //If the chunk is smaller than the fftSize, the analysis buffer is padded out with zeros
    if (chunkSize < fftSize)
    {
      Arrays.fill(nextFFTSamples, chunkSize, nextFFTSamples.length - 1, 0.0);
    }
    //Buffer is analysed
    nextFFT.forward(nextFFTSamples);
    //Resulting spectrum is copied into spectra array
    for (int i = 0; i < 512; i++)
    {
      spectraNext[chunkIdx][i] = nextFFT.getBand(i);
    }
  }
}

//Method for constructing the waveforms
//Adjusted code by Jonatan Van Hove (https://forum.processing.org/one/topic/how-to-generate-a-simple-waveform-of-an-entire-sound-file.html)
void drawWaveform(float[][] spectra, int heightOffset) {
  float scaleMod = (float(width) / float(spectra.length));
  for (int s = 0; s < spectra.length; s++)
  {
    int i = 0;
    float total = 0; 
    for (i = 0; i < spectra[s].length-1; i++)
    {
      total += spectra[s][i];
    }
    total = total / 110;
    line(s * scaleMod, total + height - heightOffset, s * scaleMod, - total + height - heightOffset);
  }
}

void displayWaveform() {
  if (song != null) {
    if (spectraCurrent != null) {
      stroke(255, 16);
      strokeWeight(0.5);
      //Positioning of each waveform on the program window
      drawWaveform(spectraCurrent, 150);
      drawWaveform(spectraNext, 50);
    }
  }
}
