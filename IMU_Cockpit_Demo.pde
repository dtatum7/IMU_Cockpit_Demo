// Libraries to import
import processing.serial.*; // Import the serial library for Processing

// Variable declarations
int width = 1366; // Width of GUI window on monitor in pixels
int height = 768; // Height of GUI window on monitor in pixels
int rollDegrees = 0; // Roll data in degrees
int pitchScaled = 0; // Raw roll data from serial port
int yawScaled = 0; // To store data from serial port, used to color backgro
int syncWord = 0xFF; // This must be the same sync word as the Arduino and never appear in the data (roll, pitch, yaw)

// Object instantiations
Serial port; // The serial port object
PImage cockpit; // Cockpit object in foreground
PImage background; // Scenery object in background

// Initial setup
void setup() {
  size(width, height); // Size of GUI window on monitor in pixels
  smooth(); // Draws all geometry with smooth (anti-aliased) edges
  frameRate(30); // Frame rate to render
  // Using the first available port (might be different on your computer)
  port = new Serial(this, Serial.list()[0], 57600); // Make sure this part agrees with the port listed in the PC and settings in Arduino Code
  background = loadImage("boundless-horizon-2.jpg"); // Load background image
  cockpit = loadImage("Cockpit.png"); // Load cockpit Image
  port.bufferUntil(syncWord); // Loads buffer stopping at the syncWord from the Arduino
}

// Draw loop
void draw() {
  // Moves the background scenery with IMU motion
  pushMatrix(); // Built-in function that saves the current position of the coordinate system
  translate(width/2, height/2); // Centers the background scenery
  rotate(radians(rollDegrees)); // Rolls the coordinate system
  translate(yawScaled, pitchScaled); // Pans coordinate system up/down (pitch) and left/right (yaw)
  image(background, -width, -height*2, width*2, height*4); // Draws background scenery in shifted coordinate system
  popMatrix(); // Restores the coordinate system to the way it was before the translate
  
  // Foreground
  image(cockpit, 0, height/2, width, height); // Draws cockpit on top of background
}

// Read and sort serial data, the assign to global variables rollDegrees, pitchScaled, and yawScaled
void serialEvent(Serial port) {
  byte[] serialBuffer = port.readBytesUntil(syncWord); // Loads buffer until syncWord is detected (syncWord is last byte)
  int roll = 0; // Raw roll data from serial port
  int pitch = 0; // Raw pitch data from serial port
  int yaw = 0; // Raw yaw data from serial port
  if(serialBuffer != null) { // Don't assign null data
    roll = serialBuffer[0]; // Raw roll data from serial port
    pitch = serialBuffer[1]; // Raw pitch data from serial port
    yaw = serialBuffer[2]; // Raw yaw data from serial port
  }
  rollDegrees = (int)( ( (float)roll )/255*360 ); // Scale roll data in degrees
  pitchScaled = (int)( ( (float)pitch )/255*height*4 ); // Scale pitch data w.r.t. image size
  yawScaled = (int)( ( (float)yaw )/255*width ); // Scale yaw data w.r.t. image size
  // For debugging
  println(Serial.list());
  println( "Raw Input: " + roll + " " + pitch + " " +yaw); // Uncomment for debugging
  println( "Rotation Degrees: " + rollDegrees + " " + pitchScaled + " " +yawScaled); // Uncomment for debugging
}
