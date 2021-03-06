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

color trunkColor = #00EDE0;
color branchColor = #F5EE34;
color leafColor = #E82503;

color lowSkyColor = #d43f8d, highSkyColor = #0250c5;
color lowFloorColor = #e772d1, highFloorColor = #6bc9c1;
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

  cp5.addButton("generateScene")
    .setLabel("generate new scene")
    .setPosition(10, 10)
    .setSize(90, 20)
    ;

  cp5.addButton("updateScene")
    .setLabel("update scene")
    .setPosition(120, 10)
    .setSize(90, 20)
    ;

  cp5.addButton("export")
    .setLabel("export image")
    .setPosition(230, 10)
    .setSize(90, 20)
    ;

  cp5.addToggle("transparentBackground")
    .setLabelVisible(false)
    .setPosition(340, 10)
    .setSize(50, 20)
    ;

  cp5.addTextlabel("bgLabel")
    .setText("TRANSPARENT BACKGROUND")
    .setPosition(395, 15)
    ;


  cp5.addToggle("animate")
    .setLabelVisible(false)
    .setPosition(540, 10)
    .setSize(50, 20)
    ;

  cp5.addTextlabel("animateLabel")
    .setText("ANIMATE /!\\ LAGGY")
    .setPosition(595, 15)
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
    .setRange(0, 1.5)
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
    .setRange(0, 4)
    ;

  cp5.addSlider("colorPalette")
    .setLabel("color palette")
    .setPosition(UIX/2, 115)
    .setSize((int)(UIX*0.3), 10)
    .setRange(0, 3)
    ;

  canvas = createGraphics(canvasSize, canvasSize, P2D);
  generateScene();
}

void draw () {
  clear();
  if (animate) {
    updateScene();
  }
  image(canvas, 0, UIY);
}

//updates the scene with the current parameters
void updateScene() {
  updatePalette();
  drawScene();  
}

//generate a new scene with the given parameters
void generateScene() {
  seed = random(10000);
  fixedSeed = random(10000);
  updateScene();
}

void updatePalette() {
  switch (colorPalette) {
  case 4:
    trunkColor = #00EDE0;
    branchColor = #F5EE34;
    leafColor = color(232, 37, 3, 110); 

    highSkyColor = #0250c5;
    lowSkyColor = #d43f8d;
    lowFloorColor = #e772d1;
    highFloorColor = #6bc9c1;
    sunColor = color(255, 204, 65, 220);
    pathColor = color(255, 255, 255, 128);
    break;

  case 1:
    trunkColor = #1B002B;
    branchColor = #43e97b;
    leafColor = color(255, 255, 255, 80);

    highSkyColor = #a6c0fe;
    lowSkyColor = #f68084;
    lowFloorColor = #e772d1;
    highFloorColor = #6bc9c1;
    sunColor = color(197, 142, 255, 255);
    pathColor = color(20, 30, 70, 128);
    break;

  case 2:
    trunkColor = #0e0402;
    branchColor = #722418;
    leafColor = color(215, 73, 46, 110);

    highSkyColor = #4d83c1;
    lowSkyColor = #f5ba76;
    lowFloorColor = #d4753b;
    highFloorColor = #f5ba76;
    sunColor = color(255, 255, 206, 230);
    pathColor = color(57, 0, 7, 100);
    break;

  case 3:
    trunkColor = #4c3828;
    branchColor = #58704c;
    leafColor = color(188, 195, 41, 110);

    highSkyColor = #2958dc;
    lowSkyColor = #6295d0;
    lowFloorColor = #79482d;
    highFloorColor = #c5a68a;
    sunColor = color(250, 252, 239, 200);
    pathColor = color(67, 58, 51, 120);
    break;

  case 0:
    trunkColor = #191d26;
    branchColor = #0a1832;
    leafColor = color(101, 83, 99, 50);

    highSkyColor = #e8cfd2;
    lowSkyColor = #ffdae1;
    lowFloorColor = #655363;
    highFloorColor = #d0a7b9;
    sunColor = color(255, 250, 229, 250);
    pathColor = color(9, 25, 50, 120);
    break;

  default:
    break;
  }
}

void drawScene() {
  canvas.beginDraw();
  canvas.clear();
  if (animate) {
    seed += 0.001;
  }
  tmpSeed = seed;
  tmpFixedSeed = fixedSeed;
  switch (composition) {
  case 0:
    drawVaporwaveScene(canvas);
    break;
  case 1:
    drawBouquetScene(canvas);
    break;
  case 2:
    drawSingleTreeScene(canvas);
    break;
  case 3:
    drawPlanetScene(canvas);
    break;
  case 4:
    drawPatternScene(canvas);
    break;
  default:
    break;
  }
  canvas.endDraw();
}

void drawVaporwaveScene(PGraphics pg) {
  if (!transparentBackground) {
    pg.background(#ffffff);
    verticalGradient(pg, new PVector(0, 0), new PVector (canvasSize, canvasSize), highSkyColor, lowSkyColor); 
    pg.noStroke();
    pg.fill(sunColor);
    pg.ellipse(canvasSize * 0.5, 0.9 * canvasSize, 0.6*canvasSize, 0.6*canvasSize); 
  }
  verticalGradient(pg, new PVector(0, 0.83 * canvasSize), new PVector (canvasSize, canvasSize), lowFloorColor, highFloorColor);
  pg.fill(pathColor);
  pg.noStroke();
  pg.triangle(canvasSize * 0.5, canvasSize * 0.83, -0.1 * canvasSize, canvasSize, 1.1 * canvasSize, canvasSize);

  drawBranch(pg, new PVector(canvasSize * 0.4, 0.85 * canvasSize), new PVector(0, -canvasSize*branchLength*0.3), 0);  
  drawBranch(pg, new PVector(canvasSize * 0.6, 0.85 * canvasSize), new PVector(0, -canvasSize*branchLength*0.3), 0);  
  drawBranch(pg, new PVector(canvasSize * 0.3, 0.88 * canvasSize), new PVector(0, -canvasSize*branchLength*0.6), 0);  
  drawBranch(pg, new PVector(canvasSize * 0.7, 0.88 * canvasSize), new PVector(0, -canvasSize*branchLength*0.6), 0);  
  drawBranch(pg, new PVector(canvasSize * 0.12, 0.93 * canvasSize), new PVector(canvasSize*branchLength*0.02, -canvasSize*branchLength), 0);  
  drawBranch(pg, new PVector(canvasSize * 0.88, 0.93 * canvasSize), new PVector(-canvasSize*branchLength*0.02, -canvasSize*branchLength), 0);
}

void drawBouquetScene(PGraphics pg) {
  if (!transparentBackground) {
    pg.background(#ffffff);
    verticalGradient(pg, new PVector(0, 0), new PVector (canvasSize, canvasSize), highSkyColor, lowSkyColor); 
  }
  pg.fill(pathColor);
  pg.noStroke();
  pg.triangle(canvasSize * 0.5, canvasSize * 0.83, 0.1 * canvasSize, 0.1 * canvasSize, 0.9 * canvasSize, 0.1 * canvasSize);
  
  pg.noStroke();
  pg.fill(sunColor);
  pg.ellipse(canvasSize * 0.5, canvasSize * 0.35, 0.4*canvasSize, 0.4*canvasSize); 
  
  drawBranch(pg, new PVector(canvasSize * 0.4, 0.95 * canvasSize), new PVector(-canvasSize*0.06, -canvasSize*branchLength*0.6), 0);  
  drawBranch(pg, new PVector(canvasSize * 0.6, 0.95 * canvasSize), new PVector(canvasSize*0.06, -canvasSize*branchLength*0.6), 0);  
  drawBranch(pg, new PVector(canvasSize * 0.5, canvasSize), new PVector(0, -canvasSize*branchLength), 0);  
  radialGradient(pg, new PVector(canvasSize * 0.5, canvasSize * 1.1), canvasSize * 0.5, highFloorColor, lowFloorColor);
}

void drawSingleTreeScene(PGraphics pg) {
  if (!transparentBackground) {
    pg.background(#ffffff);
    verticalGradient(pg, new PVector(0, 0), new PVector (canvasSize, canvasSize), highSkyColor, lowSkyColor); 
  }
  drawBranch(pg, new PVector(canvasSize * 0.5, canvasSize * 0.9), new PVector(0, -canvasSize*branchLength*0.8), 0);  
}

void drawPlanetScene(PGraphics pg) {
  if (!transparentBackground) {
    pg.background(#ffffff);
    verticalGradient(pg, new PVector(0, 0), new PVector (canvasSize, canvasSize), highSkyColor, lowSkyColor); 
  }
  
  pg.noStroke();
  pg.fill(pathColor);
  pg.ellipse(canvasSize*0.5, canvasSize*0.5, canvasSize*0.32, canvasSize*0.32);
  int nbTrees = (int)fixedSeededRandom(3,24);
  for (int i=0; i<nbTrees; i++) {
    float theta = i*2*PI/nbTrees;
    float currTreeLength = canvasSize*branchLength*0.5*fixedSeededRandom(0.2,1);
    drawBranch(pg, new PVector(canvasSize*0.5 + canvasSize * 0.1 * cos(theta), canvasSize*0.5 + canvasSize * 0.1 * sin(theta)), new PVector(currTreeLength*cos(theta), currTreeLength*sin(theta)), 0);
  }
  radialGradient(pg, new PVector(canvasSize * 0.5 , canvasSize * 0.5), canvasSize * 0.24, highFloorColor, lowFloorColor);
}

void drawPatternScene(PGraphics pg) {
  if (!transparentBackground) {
    pg.background(#ffffff);
    verticalGradient(pg, new PVector(0, 0), new PVector (canvasSize, canvasSize), highSkyColor, lowSkyColor); 
  }
  
  pg.noStroke();
  pg.fill(pathColor);
  //pg.ellipse(canvasSize*0.5, canvasSize*0.5, canvasSize*0.32, canvasSize*0.32);
  
  int nbRows = (int)fixedSeededRandom(1,8);
  
  for (int i=0; i<nbRows; i++) {
    for (int j=0; j<nbRows; j++) {
      float theta = -PI/2;
      float currTreeLength = canvasSize*branchLength /nbRows;
      drawBranch(pg, new PVector(canvasSize*(((float)i+0.5)/nbRows), canvasSize*(((float)j+0.9)/nbRows)), new PVector(currTreeLength*cos(theta), currTreeLength*sin(theta)), 0);
    }
  }
  //radialGradient(pg, new PVector(canvasSize * 0.5 , canvasSize * 0.5), canvasSize * 0.24, highFloorColor, lowFloorColor);

}

//draw a tree branch and it's children until last iteration
void drawBranch(PGraphics pg, PVector origin, PVector direction, int iter) {
  color c = lerp3Color(trunkColor, branchColor, leafColor, (float)iter / (float)maxIterations);
  pg.stroke(c);
  pg.strokeWeight(branchWidth * pow(branchWidthFactor, iter));
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

      drawBranch(pg, nextOrigin, nextDirection, iter+1);
    }
  }
}

//Draws a series of lines to create a gradient from one color to another
void verticalGradient(PGraphics pg, PVector bottomLeft, PVector topRight, color bottomColor, color topColor) {
  noFill();
  for (int i = (int)bottomLeft.y; i <= topRight.y; i++) {
    float inter = map(i, bottomLeft.y, topRight.y, 0, 1);
    color c = lerpColor(bottomColor, topColor, inter);
    pg.stroke(c);
    pg.strokeWeight(1);
    pg.line(bottomLeft.x, i, topRight.x, i);
  }
}

//Draws a series of concentric circles to create a gradient from one color to another
void radialGradient(PGraphics pg, PVector center, float radius, color centerColor, color outsideColor) {
  pg.noStroke();
  for (int r=(int)radius; r >= 0; r--) {
    float inter = map(r, 0, radius, 0, 1);
    color c = lerpColor(centerColor, outsideColor, inter);
    pg.fill(c);
    pg.ellipse(center.x, center.y, r, r);
  }
}

//random vamue but using a seed
float seededRandom(float min, float max) {
  tmpSeed += 5*PI;
  return map(noise(tmpSeed), 0, 1, min, max);
}

//random vamue but using a fixed seed
float fixedSeededRandom(float min, float max) {
  tmpFixedSeed += 5*PI;
  return map(noise(tmpFixedSeed), 0, 1, min, max);
}

//lerp on 3 colors between 0 - 1
color lerp3Color(int c1, int c2, int c3, float t) {
  if (t<0.5)
    return lerpColor(c1, c2, t*2);
  else
    return lerpColor(c2, c3, (t-0.5)*2);
}

//clamp a value between 0 - 1
float clamp01(float f) {
  return min(max(0, f), 1);
}

void export() {
  canvas.save("Tree-" + year() + month() + day() + hour() + minute() + second() + ".png");
  javax.swing.JOptionPane.showMessageDialog(null, "Saved file : " + sketchPath("") + "Tree-" + year() + month() + day() + hour() + minute() + second() + ".png");
}