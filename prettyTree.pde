// small app to blur an image by exchanging pixels 2 by 2

import controlP5.*;


PGraphics canvas;

int canvasSize = 800, UIX = canvasSize, UIY = 135;
int sizeX = canvasSize, sizeY = UIY + canvasSize; //must be the size of the input image


//UI variables
boolean transparentBackground = false;
boolean animate = false;

float branchLength = 0.4;
float branchLengthFactor = 0.8;
float branchLengthHeightFactor = 0.15;
float branchAngle = 0.6;
float branchAngleFactor = 0.9;
float branchWidth = 17;
float branchWidthFactor = 0.7;
float branchHeight = 0.2;
float branchHeightFactor = 0.6;

int nbNextBranches = 8;
int maxIterations = 7;
int composition = 0;
int colorPalette = 0;

// computing variables
float seed = 0;
float tmpSeed = 0;
float fixedSeed = 0;
float tmpFixedSeed = 0;

color trunkColor = #00EDE0;//#1B002B;
color branchColor = #F5EE34; //#43e97b;
color leafColor = #E82503;//#ffffff;

color lowSkyColor = #0250c5/*#a6c0fe*/, highSkyColor = #d43f8d;//#f68084;
color sunColor = color(255, 204, 65, 220);
color pathColor = color(255, 255, 255, 128);


//GUI variables
ControlP5 cp5;

void settings() { 
  size(sizeX, sizeY, P2D);
}


void setup () {
  //initialisation of variables
  background(0);
  noStroke();

  cp5 = new ControlP5(this);

  cp5.addButton("drawScene")
    .setLabel("generate tree")
    .setPosition(10, 10)
    .setSize(90, 20)
    ;

  cp5.addButton("export")
    .setLabel("export image")
    .setPosition(120, 10)
    .setSize(90, 20)
    ;

  cp5.addToggle("transparentBackground")
    .setLabelVisible(false)
    .setPosition(230, 10)
    .setSize(50, 20)
    ;

  cp5.addTextlabel("bgLabel")
    .setText("TRANSPARENT BACKGROUND")
    .setPosition(285, 15)
    ;


  cp5.addToggle("animate")
    .setLabelVisible(false)
    .setPosition(430, 10)
    .setSize(50, 20)
    ;

  cp5.addTextlabel("animateLabel")
    .setText("ANIMATE /!\\ LAGGY")
    .setPosition(485, 15)
    ;

  cp5.addSlider("branchLength")
    .setLabel("branch length")
    .setPosition(10, 35)
    .setSize((int)(UIX*0.3), 10)
    .setRange(0, 1)
    ;

  cp5.addSlider("branchLengthFactor")
    .setLabel("branch length factor")
    .setPosition(UIX/2, 35)
    .setSize((int)(UIX*0.3), 10)
    .setRange(0, 1)
    ;

  cp5.addSlider("branchAngle")
    .setLabel("branch angle")
    .setPosition(10, 50)
    .setSize((int)(UIX*0.3), 10)
    .setRange(0, PI * 0.5)
    ;

  cp5.addSlider("branchAngleFactor")
    .setLabel("branch angle factor")
    .setPosition(UIX/2, 50)
    .setSize((int)(UIX*0.3), 10)
    .setRange(0, 2)
    ;

  cp5.addSlider("branchWidth")
    .setLabel("branch width")
    .setPosition(10, 65)
    .setSize((int)(UIX*0.3), 10)
    .setRange(0, canvasSize * 0.1)
    ;

  cp5.addSlider("branchWidthFactor")
    .setLabel("branch width factor")
    .setPosition(UIX/2, 65)
    .setSize((int)(UIX*0.3), 10)
    .setRange(0, 2)
    ;

  cp5.addSlider("branchHeight")
    .setLabel("branch height")
    .setPosition(10, 80)
    .setSize((int)(UIX*0.3), 10)
    .setRange(0, 1)
    ;

  cp5.addSlider("branchHeightFactor")
    .setLabel("branch height factor")
    .setPosition(UIX/2, 80)
    .setSize((int)(UIX*0.3), 10)
    .setRange(0, 2)
    ;

  cp5.addSlider("nbNextBranches")
    .setLabel("childs per branch")
    .setPosition(10, 95)
    .setSize((int)(UIX*0.3), 10)
    .setRange(1, 20)
    ;

  cp5.addSlider("maxIterations")
    .setLabel("depth of tree")
    .setPosition(UIX/2, 95)
    .setSize((int)(UIX*0.3), 10)
    .setRange(0, 10)
    ;
    
  cp5.addSlider("composition")
    .setLabel("composition")
    .setPosition(10, 115)
    .setSize((int)(UIX*0.3), 10)
    .setRange(0, 10)
    ;

  cp5.addSlider("colorPalette")
    .setLabel("color palette")
    .setPosition(UIX/2, 115)
    .setSize((int)(UIX*0.3), 10)
    .setRange(0, 10)
    ;

  canvas = createGraphics(canvasSize, canvasSize, P2D);
  drawScene();
}

void draw () {
  clear();
  if (animate) {
    drawScene();
  }
  image(canvas, 0, UIY);
}

void drawScene() {
  
  canvas.beginDraw();
  canvas.clear();
  if (animate) {
    seed += 0.001;
  }
  else {
    seed += 40;
    fixedSeed += 40;
  }
  tmpSeed = seed;
  tmpFixedSeed = fixedSeed;

  if (!transparentBackground) {
    canvas.background(#ffffff);
    verticalGradient(canvas, new PVector(0, 0), new PVector (canvasSize, canvasSize), lowSkyColor, highSkyColor); 
    canvas.noStroke();
    canvas.fill(sunColor);
    canvas.ellipse(canvasSize * 0.5, 0.9 * canvasSize, 0.6*canvasSize, 0.6*canvasSize); 
    verticalGradient(canvas, new PVector(0, 0.83 * canvasSize), new PVector (canvasSize, canvasSize), #e772d1, #6bc9c1);
    canvas.fill(pathColor);
    canvas.noStroke();
    canvas.triangle(canvasSize * 0.5, canvasSize * 0.83, -0.1 * canvasSize, canvasSize, 1.1 * canvasSize, canvasSize);
  }
  drawBranch(canvas, new PVector(canvasSize * 0.4, 0.85 * canvasSize), new PVector(0, -canvasSize*branchLength*0.3), branchWidth, 0);  
  drawBranch(canvas, new PVector(canvasSize * 0.6, 0.85 * canvasSize), new PVector(0, -canvasSize*branchLength*0.3), branchWidth, 0);  
  drawBranch(canvas, new PVector(canvasSize * 0.3, 0.88 * canvasSize), new PVector(0, -canvasSize*branchLength*0.6), branchWidth, 0);  
  drawBranch(canvas, new PVector(canvasSize * 0.7, 0.88 * canvasSize), new PVector(0, -canvasSize*branchLength*0.6), branchWidth, 0);  
  drawBranch(canvas, new PVector(canvasSize * 0.12, 0.93 * canvasSize), new PVector(canvasSize*branchLength*0.02, -canvasSize*branchLength), branchWidth, 0);  
  drawBranch(canvas, new PVector(canvasSize * 0.88, 0.93 * canvasSize), new PVector(-canvasSize*branchLength*0.02, -canvasSize*branchLength), branchWidth, 0); 
  canvas.endDraw();
}

void verticalGradient(PGraphics pg, PVector bottomLeft, PVector topRight, color bottomColor, color topColor) {
  noFill();
  for (int i = (int)bottomLeft.y; i <= topRight.y; i++) {
    float inter = map(i, bottomLeft.y, topRight.y, 0, 1);
    color c = lerpColor(bottomColor, topColor, inter);
    pg.stroke(c);
    pg.line(bottomLeft.x, i, topRight.x, i);
  }
}

/*
int branchLength = 100;
 float branchLengthFactor = 0.7;
 float branchHeight = 0.5;
 float branchHeightFactor = 1;
 int branchAngle = 20;
 float branchAngleFactor = 1.3;
 float branchWidth = 30;
 float branchWidthFactor = 0.8;
 
 int nbNextBranches = 5;
 int maxIterations = 5;
 color trunkColor = color(#1B002B);
 */

float seededRandom(float min, float max) {
  tmpSeed += 5;
  return map(noise(tmpSeed), 0, 1, min, max);
}

float fixedSeededRandom(float min, float max) {
  tmpFixedSeed += 5;
  return map(noise(tmpFixedSeed), 0, 1, min, max);
}

color lerp3Color(int c1, int c2, int c3, float t) {
  if (t<0.5)
    return lerpColor(c1, c2, t*2);
  else
    return lerpColor(c2, c3, (t-0.5)*2);
}

float clamp01(float f) {
  return min(max(0, f), 1);
}

void drawBranch(PGraphics pg, PVector origin, PVector direction, float branchWidth, int iter) {
  color c = lerp3Color(trunkColor, branchColor, leafColor, (float)iter / (float)maxIterations);
  pg.stroke(c);
  pg.strokeWeight(branchWidth);
  PVector destination = PVector.add(origin, direction);
  pg.line(origin.x, origin.y, destination.x, destination.y);

  if (iter < maxIterations) {
    int nextNbNextBranches = (int)fixedSeededRandom(1, nbNextBranches);
    for (int i=0; i<nextNbNextBranches; i++) {
      float currBranchHeight = clamp01(seededRandom(branchHeight * pow(branchHeightFactor, iter), 1));
      PVector nextOrigin = PVector.add(origin, PVector.mult(direction, currBranchHeight));
      float maxCurrBranchAngle = branchAngle * pow(branchAngleFactor, iter);
      float currBranchLength = seededRandom(branchLengthFactor*0.8, branchLengthFactor*1.2) * (1-currBranchHeight*branchLengthHeightFactor);
      PVector nextDirection = direction.copy();
      nextDirection
        .rotate(seededRandom(-maxCurrBranchAngle, maxCurrBranchAngle))
        .mult(currBranchLength);
      float nextBranchWidth = branchWidth * branchWidthFactor;

      drawBranch(pg, nextOrigin, nextDirection, nextBranchWidth, iter+1);
    }
  }
}

void export() {
  canvas.save("Tree-" + year() + month() + day() + hour() + minute() + second() + ".png");
  javax.swing.JOptionPane.showMessageDialog(null, "Saved file : " + sketchPath("") + "Tree-" + year() + month() + day() + hour() + minute() + second() + ".png");
}