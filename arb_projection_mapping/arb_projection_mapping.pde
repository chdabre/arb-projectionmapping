import deadpixel.keystone.*; //<>//

Keystone ks;
CornerPinSurface frontSurface;
CornerPinSurface bottomSurface;

PGraphics frontGraphics;
PGraphics bottomGraphics;

String[] frontImages = {
  "Vorne.png",
  "Vorne 2.png",
  "Vorne 3.png",
  "Vorne 4.png",
  "Vorne 5.png",
};

String[] bottomImages = {
  "Unten.png",
  "Unten 2.png",
  "Unten 3.png",
  "Unten 4.png",
  "Unten 5.png",
};

int imgIndex = 0;

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
    break;
    
  }
}
