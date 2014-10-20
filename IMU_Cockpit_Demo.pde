// Libraries to import
import processing.serial.*; // Import the serial library for Processing

// Variable declarations
int width = 1600; // Width of GUI window on monitor in pixels
int height = 900; // Height of GUI window on monitor in pixels
byte serialBuffer[] = new byte[4];
int roll = 0; // Raw roll data from serial port
int pitch = 0; // Raw pitch data from serial port
int yaw = 0; // Raw yaw data from serial port
int rollDegrees = 0; // Roll data in degrees
int pitchScaled = 0; // Raw roll data from serial port
int yawScaled = 0; // To store data from serial port, used to color background
int yawDegrees = 0; // Yaw data in degrees
int syncWord = 0xFF; // This must be the same sync word as the Arduino and never appear in the data (roll, pitch, yaw)
int frameCount = 0;


// Object instantiations
Serial port; // The serial port object
PImage cockpit; // Cockpit object in foreground
PImage background; // Scenery object in background
PImage map; // Map object on dash

// Initial setup
void setup() {
  size(width, height); // Size of GUI window on monitor in pixels
  smooth(); // Draws all geometry with smooth (anti-aliased) edges
  frameRate(20); // Frame rate to render
  // Using the first available port (might be different on your computer)
  port = new Serial(this, Serial.list()[0], 9600); // Make sure this part agrees with the port listed in the PC and settings in Arduino Code
  background = loadImage("boundless-horizon-2.jpg"); // Load background image
  cockpit = loadImage("Cockpit.png"); // Load cockpit image
  map = loadImage("Map.png"); // Load map image
  port.bufferUntil(syncWord); // Loads buffer stopping at the syncWord from the Arduino
  noLoop();
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



  // Dash
  pushMatrix(); // Built-in function that saves the current position of the coordinate system
    translate(0, height/3.5);
    scale((float)width/(float)cockpit.width);
    //Map
    pushMatrix();
      translate(425, 11);
      //tint(255, 127); // helps to center the map
      pushMatrix(); // Built-in function that saves the current position of the coordinate system
        translate(width/2, height/2);
        pushMatrix(); // Built-in function that saves the current position of the coordinate system
          rotate(radians(yawDegrees));
          image(map, -map.width/2, -map.height/2);
        popMatrix(); // Restores the coordinate system to the way it was before the translate
      popMatrix(); // Restores the coordinate system to the way it was before the translate
    popMatrix(); // Restores the coordinate system to the way it was before the translate
    image(cockpit, 0, 0); // Draws cockpit on top of background
  popMatrix(); // Restores the coordinate system to the way it was before the translate
    
}

// Read and sort serial data, the assign to global variables rollDegrees, pitchScaled, and yawScaled
void serialEvent(Serial port) {
  serialBuffer = port.readBytesUntil(syncWord); // Loads buffer until syncWord is detected (syncWord is last byte)
  if (serialBuffer != null && serialBuffer.length == 4) { // Don't assign null data
    roll = serialBuffer[0]; // Raw roll data from serial port
    pitch = serialBuffer[1]; // Raw pitch data from serial port
    yaw = serialBuffer[2]; // Raw yaw data from serial port
  }
  rollDegrees = (int)( ( (float)roll )/255*360 ); // Scale roll data in degrees
  pitchScaled = -(int)( ( (float)pitch )/255*height*4 ); // Scale pitch data w.r.t. image size
  yawScaled = (int)( ( (float)yaw )/255*width ); // Scale yaw data w.r.t. image size
  yawDegrees = (int)( ( (float)yaw )/255*360 ); // Scale yaw data in degrees
  redraw();
  // For debugging
  //println(Serial.list());
  //println( "Raw Input: " + roll + " " + pitch + " " +yaw); // Uncomment for debugging
  //println( "Rotation Degrees: " + rollDegrees + " " + pitchScaled + " " +yawScaled); // Uncomment for debugging
  //println( "Frame Count: " + frameCount++); // Uncomment for debugging
}

