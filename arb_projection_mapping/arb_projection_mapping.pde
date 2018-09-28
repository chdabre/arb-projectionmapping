import mqtt.*; //<>//
import deadpixel.keystone.*;

MQTTClient mqttClient;
String commandTopic = "horizon/4/bridge/state";
String stateTopic = "horizon/4/projection/state";

Keystone ks;
CornerPinSurface frontSurface;
CornerPinSurface bottomSurface;

PGraphics frontGraphics;
PGraphics bottomGraphics;

boolean skip = false;
long timer = 0;

String[] frontImages = {
  "Vorne.png",
  "Vorne 2.png",
  "Vorne 3.png",
  "Vorne 4.png",
  "Vorne 5.png",
  "Vorne 5.png",
  "Vorne 5.png",
};

String[] bottomImages = {
  "Unten.png",
  "Unten 2.png",
  "Unten 3.png",
  "Unten 4.png",
  "Unten 5.png",
  "Unten 6.png",
  "Unten 7.png",
};

int imgIndex = 0;

String[] stateNames = {
  "404",
  "200 POWER LOSS",
  "471 AIR SUPPLY",
  "123 COMMUNICATION",
  "ALL SYSTEMS ONLINE"
};

void setup() {
  // Keystone will only work with P3D or OPENGL renderers, 
  // since it relies on texture mapping to deform
  //size(1280, 720, P3D);
  fullScreen(P3D);

  ks = new Keystone(this);
  
  frontSurface = ks.createCornerPinSurface(1195, 720, 20);
  bottomSurface = ks.createCornerPinSurface(1220, 720, 20);
  
  // We need an offscreen buffer to draw the surface we
  // want projected
  // note that we're matching the resolution of the
  // CornerPinSurface.
  // (The offscreen buffer can be P2D or P3D)
  frontGraphics = createGraphics(1195, 720, P3D);
  bottomGraphics = createGraphics(1220, 720, P3D);
  
  try {
    ks.load();
  } catch(NullPointerException e) {
    ks.save();
  }
  
  mqttClient = new MQTTClient(this);
  mqttClient.connect("mqtt://192.168.100.40:1883", "processing-argame");
  mqttClient.subscribe(commandTopic);
  mqttClient.publish(stateTopic, stateNames[imgIndex]);
}

void draw() {
  background(0);

  frontGraphics.beginDraw();
  PImage frontImage;
  if (ks.isCalibrating()) {
    frontImage = loadImage("Vorne Calibration.png");
  } else {
    frontImage = loadImage(frontImages[imgIndex]);
  }
  frontGraphics.image(frontImage, 0, 0, frontGraphics.width,frontGraphics.height);
  frontGraphics.endDraw();
  
  bottomGraphics.beginDraw();
  PImage bottomImage;
  if (ks.isCalibrating()) {
    bottomImage = loadImage("Unten Calibration.png");
  } else {
    bottomImage = loadImage(bottomImages[imgIndex]);
  }
  bottomGraphics.image(bottomImage, 0, 0, bottomGraphics.width,bottomGraphics.height);
  bottomGraphics.endDraw();
  
 
  // render the scene, transformed using the corner pin surface
  frontSurface.render(frontGraphics);
  bottomSurface.render(bottomGraphics);
  
  if ( skip && millis() - timer > 3000 ) {
    imgIndex ++;
    timer = millis();
    if (imgIndex >= 6) skip = false;
  }
}

void keyPressed() {
  switch(key) {
  case 'c':
    // enter/leave calibration mode, where surfaces can be warped 
    // and moved
    ks.toggleCalibration();
    break;

  case 'l':
    // loads the saved layout
    ks.load();
    break;

  case 's':
    // saves the layout
    ks.save();
    break;
  
  case 'm':
    imgIndex++;
    if (imgIndex >= frontImages.length) {
      imgIndex = 0;
    }
    
    if (imgIndex == 4) {
      timer = millis();
      skip = true;
    }
    
    break;
    
  }
}

void messageReceived(String topic, byte[] payload) {
  println("new message: " + topic + " - " + new String(payload));

  if (new String(payload).contains("RESET")) {
    skip = false;
    timer = 0;
    imgIndex = 0;
  }
  else if (new String(payload).contains("STEP 0")) {
    skip = false;
    timer = 0;
    imgIndex = 0;
  }
  else if (new String(payload).contains("STEP 1")) imgIndex = 1;
  else if (new String(payload).contains("STEP 2")) imgIndex = 2;
  else if (new String(payload).contains("STEP 3")) imgIndex = 3;
  else if (new String(payload).contains("DIALING")) {
    imgIndex = 4;
    timer = millis();
    skip = true;
  }

  mqttClient.publish(stateTopic, stateNames[imgIndex]);
}
