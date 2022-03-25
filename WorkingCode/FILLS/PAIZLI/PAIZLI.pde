// TODO: implement a more tunable perlin noise fill using the PEmbroiderGraphics.VECFIELD 
import processing.embroider.*;

PEmbroiderGraphics E_EXT;
PEmbroiderGraphics E4;
int frame = 0;


//// FILE PARAMETERS
String fileType = ".pes";  // CHANGE ME 
String fileName = "PAIZLI"; // CHANGE ME
//// END FILE PARAMETERS


//// RUN VARIABLES
float maxDiam = 300;
//// END RUN VARIABLES

PVector center;
float GradMult = 1;
int MODE = 2;
float hatchSpacing = 30;

boolean doWrite = true;


float randAddition = 0;
boolean edditting = true;

int setStitchVal = 25;





void setup() {
  size(1000, 1000); //100 px = 1 cm (so 14.2 cm is 1420px)

  //  image_INT = loadImage("INTERIOR2.png");
  center = new PVector(width/2, height/2);


  E4 = new PEmbroiderGraphics(this, width, height);
  E4.setStitch(5, 200, 0);


  E_EXT = new PEmbroiderGraphics(this, width, height);
  E_EXT.toggleResample(true);
  E_EXT.clear();
  E_EXT.pushMatrix();

  setFieldFill(E_EXT, frame*.01, 10);
  E_EXT.noStroke();
  E_EXT.fill(0);

  E_EXT.hatchSpacing(hatchSpacing);
  E_EXT.RESAMPLE_MAXTURN = 5;
  E_EXT.setStitch(setStitchVal-20, setStitchVal, 10);
  E_EXT.circle(width/2,height/2,maxDiam);
  
  E_EXT.popMatrix();
  E_EXT.visualize(true, true, true);
}

void draw() {
  if (edditting) {
    background(180);
    E_EXT.visualize(true, true, false);
  } else {
    if (doWrite) {
      E_EXT.optimize(30, 1000);
      //backstitchPolylines(E_EXT);
      renderZigFUNOnLines(E4, E_EXT);
      PEmbroiderWrite(E4, "PAIZLI");
      doWrite = false;
      testFuntion();
    }
    background(180);
    E4.visualize(true, true, true);
  }
}

void doubleStitch(PEmbroiderGraphics E, float x, float y, float x2, float y2) {
  E.line(x, y, x2, y2);
  E.line(x2, y2, x, y);
}

void PEmbroiderWrite(PEmbroiderGraphics E, String fileName) {
  String outputFilePath = sketchPath(fileName+timeStamp()+fileType);
  E.setPath(outputFilePath);
  E.endDraw(); // write out the file
}

float zVal = 0;
void mousePressed() {
  if (edditting) {
    center = new PVector(mouseX, mouseY).add(90,90);
    zVal += .1;
    resetDesignFill_Color(E_EXT);
  }
}

void mouseDragged() {
  if (edditting) {
    center = new PVector(mouseX, mouseY);
  }
}

void keyPressed() {
  if (edditting) {
    // Handle arrow keys
    if (key == CODED) {
      if (keyCode == UP) {
        GradMult +=.1;
      } else if (keyCode == DOWN) {
        GradMult -=.1;
      } else if (keyCode == RIGHT) {
        randAddition +=1;
      } else if (keyCode == LEFT) {
        randAddition -=1;
      }
    } else {
      if (key == '0') {
        MODE = 0;
        setFieldFill(E_EXT, frame*.01, 10);
      } else if (key == '1') {
        MODE = 1;
        setFieldFill(E_EXT, frame*.01, 10);
      } else if (key == '2') {
        MODE = 2;
        setFieldFill(E_EXT, frame*.01, 10);
      } else if ( key == '3') {
        E_EXT.hatchMode(E_EXT.CROSS);
      } else if ( key == '4') {
        E_EXT.hatchMode(E_EXT.CONCENTRIC);
      } else if (key == 'w') {
        hatchSpacing *= 1.1 ;
      } else if (key == 's') {
        hatchSpacing *= 1/1.1;
      } else if (key == ' ') {
        edditting = false;
      } else if (key == '+') {
        setStitchVal++;
        E_EXT.setStitch(setStitchVal-20, setStitchVal, 10);
      } else if (key == '-') {
        setStitchVal--;
        E_EXT.setStitch(setStitchVal-20, setStitchVal, 10);
      }
      if (edditting){
      resetDesignFill_Color(E_EXT);
      }
    }
  }
}

void resetDesignFill_Color(PEmbroiderGraphics E) {
  E.clear();
  E.hatchSpacing(hatchSpacing);
  E.pushMatrix();
 // E.translate(width/2, height/2);
 // E.image(image_EXT, -image_EXT.width/2, -image_EXT.height/2);
  E_EXT.circle(width/2,height/2,maxDiam);
  E.popMatrix();
}




///////////////Field Fill Helpers /////////////////////////

void setFieldFill(PEmbroiderGraphics E, float z, float len) {

  MyVecField mvf = new MyVecField(z, len);
  E.hatchMode(PEmbroiderGraphics.VECFIELD);
  E.HATCH_VECFIELD = mvf;
}

void setFieldFill(PEmbroiderGraphics E, float z, float len, int mode) {

  MyVecField mvf = new MyVecField(z, len, mode);
  E.hatchMode(PEmbroiderGraphics.VECFIELD);
  E.HATCH_VECFIELD = mvf;
}



class MyVecField implements PEmbroiderGraphics.VectorField {
  // Helpful Vector Field Visualizer: https://www.desmos.com/calculator/eijhparfmd
  PVector center1 = new PVector(width/2, height/2);
  float z;
  float len;
  int mode;
  float minX = 10000;
  float minY = 10000;
  float thetaMultiplier = .03;
  float radialMultiplier = .005;
  float noiseMultiplier = 5;
  boolean set = false;

  MyVecField(float z, float len, int mode) {
    this.mode = mode;
    this.z = z;
    this.len = len;
    set = true;
  }

  MyVecField(float z, float len) {
    this.mode = 0;
    this.z = z;
    this.len = len;
  }

  public PVector get(float x, float y) {
    PVector centerPoint = null; // vector that points to the center
    if (!set) {
      this.mode = MODE;
    }
    switch(mode) {
    case 0:
      x*=0.01;
      y*=0.01;
      return new PVector(0, len).rotate(noise(x, y, z)*2*PI);
    case 1:
      x=x+width/2;
      y=y+height/2;
      centerPoint = center.copy().sub(x, y);
      if (minX>x) {
        minX = x;
      }
      if (minY>y) {
        minY=y;
      }
      if (centerPoint.mag() < 5) {
        return new PVector(0, 0);
      }
      centerPoint.normalize().mult(len).rotate(PI/2);
      return centerPoint;
    case 2:
      x=x+width/2;
      y=y+height/2;
      centerPoint = center.copy().sub(x, y);
      if (minX>x) {
        minX = x;
      }
      if (minY>y) {
        minY=y;
      }
      if (centerPoint.mag() < 5) {
        return new PVector(0, 0);
      }
      //point(x,y);
      float heading = centerPoint.heading();
      float mag = centerPoint.mag();

      float noiseVal = (noise(sin(heading)*thetaMultiplier, mag*radialMultiplier, zVal)-.5)*noiseMultiplier;
      centerPoint.normalize().mult(10).rotate(noiseVal);
      return centerPoint;
    }
    return null;
  }
}



///////////////////////////////////////////////////////////////





























///////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////// NEEDLE DOWN HELPERS ////////////////////////////////////////////////////////////

PVector getND(PEmbroiderGraphics E, int ndIndex) {
  //get the ith needle down
  if (ndIndex < ndLength(E)) {
    int n = 0;
    for (int i=0; i<E.polylines.size(); i++) {
      for (int j=0; j<E.polylines.get(i).size(); j++) {
        PVector needleLoc = E.polylines.get(i).get(j).copy();
        if (n >= ndIndex) {
          return needleLoc;
        }
        n++;
      }
    }
  } else {
    int polyLen = E.polylines.size();
    int finalPolyLen = E.polylines.get(polyLen - 1).size();
    return E.polylines.get(polyLen-1).get(finalPolyLen-1).copy();
  }
  return null; //will return null if the index is outside the needle down list
}

PVector getPolyND(PEmbroiderGraphics E, int ndIndex, int polylineIndex) {
  return E.polylines.get(polylineIndex).get(ndIndex).copy();
}

int polyndLength(PEmbroiderGraphics E, int polylineIndex) {
  return E.polylines.get(polylineIndex).size();
}

int ndLength(PEmbroiderGraphics E) {
  //return the total number of needle downs in the job
  int n = 0;
  for (int i=0; i<E.polylines.size(); i++) {
    n += E.polylines.get(i).size();
  }
  return n;
}

float getndDist(PEmbroiderGraphics E, int i1, int i2) {
  PVector P1 = getND(E, i1);
  PVector P2 = getND(E, i2);
  return P1.sub(P2).mag();
}



void checkStitchDens(PEmbroiderGraphics E) {
  int rows = height/5;
  int cols = width/5;
  float heightOffset = height/rows;
  float widthOffset = width/cols;

  int stitchCounters[][] = new int[rows+10][cols+10];

  int lenE = ndLength(E);
  PVector pointLoc = new PVector();
  int maxStitches = 0;

  int rowTrack = 100;
  int colTrack = 0;

  // This loop goes through each point  in E counts how many times the needle down falls within a certain stitch counter
  for (int i = 0; i < lenE; i++) {
    pointLoc = getND(E, i);
    int col = int(pointLoc.x/widthOffset);
    int row = int(pointLoc.y/heightOffset);
    if (row<rowTrack) {
      rowTrack = row;
    }
    if (col>colTrack) {
      colTrack = col;
    }

    stitchCounters[row][col]++;
  }

  for (int row=0; row < rows; row ++) {
    for (int col=0; col < cols; col++) {
      int r = int(float(stitchCounters[row][col])*30);
      if (maxStitches<stitchCounters[row][col]) {
        maxStitches =stitchCounters[row][col];
      }
      noStroke();
      fill(r, 0, 0);
      rect(col*widthOffset, row*heightOffset, widthOffset, heightOffset);
    }
  }


  for (int i = 0; i < lenE; i++) {
    pointLoc = getND(E, i);
    fill(255);
    stroke(255, 255, 255, 40);
    point(pointLoc.x, pointLoc.y);
  }
}


void randomStepPolys(PEmbroiderGraphics E, PEmbroiderGraphics E2, int steps) {
  for (int i=0; i<E.polylines.size(); i++) {
    int eLen = polyndLength(E, i);
    //   int i0 = 0%eLen;//int(random(eLen));
    // int i1 = (0+5)%eLen;//int(random(eLen));
    for (int j=0; j<steps; j++) {
      if (j%2 == 0) {
        int i0 = j%(eLen-1);//i1;
        int i1 = (j+8)%(eLen-1);//(i1+10);
        PVector P0 = getPolyND(E, i0, i);
        PVector P1 = getPolyND(E, i1, i);
        E2.line(P0.x, P0.y, P1.x, P1.y);
      } else {
        int i1 = j%(eLen-1);//i1;
        int i0 = (j+8)%(eLen-1);//(i1+10);
        PVector P0 = getPolyND(E, i0, i);
        PVector P1 = getPolyND(E, i1, i);
        E2.line(P0.x, P0.y, P1.x, P1.y);
      }
    }
  }
}

void sortRadial(PEmbroiderGraphics E) {
  // implement a radial sort/ optization here --> the pattern should generally spiral outward
}

void sortConcentric(PEmbroiderGraphics E) {
  // implement concentric sort which steps out and back in and out and back in
}


void filterND(PEmbroiderGraphics E, float intRad, float edgRad) {
  PVector center = new PVector(width/2, height/2);
  for (int i=0; i<E.polylines.size(); i++) {
    ArrayList<PVector> collection =  new ArrayList<PVector>();
    for (int j=0; j<E.polylines.get(i).size(); j++) {
      PVector needleLoc0 = E.polylines.get(i).get(j).copy();
      float dist = needleLoc0.sub(center).mag();
      boolean val = abs(dist-edgRad)<1 || (dist<intRad);// this includes all we want to keep (so everything that is on the edge OR is within 300 px of the center)
      if (!val) {
        collection.add(E.polylines.get(i).get(j));
      }
    }
    E.polylines.get(i).removeAll(collection);
  }
}

void filterByColor(PEmbroiderGraphics E) {
  PVector center = new PVector(width/2, height/2);
  for (int i=0; i<E.polylines.size(); i++) {
    PVector needleLoc0 = E.polylines.get(i).get(int(E.polylines.get(i).size()/2)).copy();
    float dist = needleLoc0.sub(center).mag();
    if (dist>114 && dist<= 155) {
      resetPolylineColor(E, i, color(0, 255, 0));
    } else if (dist > 155) {
      resetPolylineColor(E, i, color(0, 255, 0));
    }
  }
}


void filterByColor2(PEmbroiderGraphics E) {
  PVector center = new PVector(width/2, height/2);
  ArrayList<ArrayList <PVector>> Color0 = new ArrayList<ArrayList <PVector>>();
  ArrayList<ArrayList <PVector>> Color1 = new ArrayList<ArrayList <PVector>>();
  ArrayList<ArrayList <PVector>> Color2 = new ArrayList<ArrayList <PVector>>();
  ArrayList <Integer> colors0 = new ArrayList <Integer>();
  ArrayList <Integer> colors1 = new ArrayList <Integer>();
  ArrayList <Integer> colors2 = new ArrayList <Integer>();
  for (int i=0; i<E.polylines.size(); i++) {
    PVector needleLoc0 = E.polylines.get(i).get(int(E.polylines.get(i).size()/2)).copy();
    float dist = needleLoc0.sub(center).mag();
    if (dist>90 && dist<= 156) {
      Color1.add(E.polylines.get(i));
      colors1.add(color(0));
    } else if (dist > 156) {
      Color2.add(E.polylines.get(i));
      colors2.add(color(0, 255, 0));
    } else {
      Color0.add(E.polylines.get(i));
      colors0.add(color(255, 0, 0));
    }
  }
  E.polylines.clear();
  E.colors.clear();
  E.polylines.addAll(Color0);
  E.polylines.addAll(Color1);
  E.polylines.addAll(Color2);
  E.colors.addAll(colors0);
  E.colors.addAll(colors1);
  E.colors.addAll(colors2);
  E.optimize(10, 1000);
}

void filterByColor4(PEmbroiderGraphics E) {
  ArrayList<ArrayList <PVector>> Color0 = new ArrayList<ArrayList <PVector>>();
  ArrayList<ArrayList <PVector>> Color1 = new ArrayList<ArrayList <PVector>>();
  ArrayList<ArrayList <PVector>> Color2 = new ArrayList<ArrayList <PVector>>();
  ArrayList <Integer> colors0 = new ArrayList <Integer>();
  ArrayList <Integer> colors1 = new ArrayList <Integer>();
  ArrayList <Integer> colors2 = new ArrayList <Integer>();
  for (int i=0; i<E.polylines.size(); i++) {
    PVector needleLoc0 = E.polylines.get(i).get(int(E.polylines.get(i).size()/2)).copy();
    float dist = needleLoc0.sub(center).mag();
    dist += random(-randAddition, randAddition);
    if (dist>90*GradMult && dist<= 156*GradMult) {
      Color1.add(E.polylines.get(i));
      colors1.add(color(0));
    } else if (dist > 156*GradMult) {
      Color2.add(E.polylines.get(i));
      colors2.add(color(0, 255, 0));
    } else {
      Color0.add(E.polylines.get(i));
      colors0.add(color(255, 0, 0));
    }
  }
  E.polylines.clear();
  E.colors.clear();
  E.polylines.addAll(Color0);
  E.polylines.addAll(Color1);
  E.polylines.addAll(Color2);
  E.colors.addAll(colors0);
  E.colors.addAll(colors1);
  E.colors.addAll(colors2);
}


void filterND_stepOver(PEmbroiderGraphics E, float intRad, float edgWidth) {
  PVector center = new PVector(width/2, height/2);
  for (int i=0; i<E.polylines.size(); i++) {
    ArrayList<PVector> collection =  new ArrayList<PVector>();
    for (int j=0; j<E.polylines.get(i).size(); j++) {
      PVector needleLoc0 = E.polylines.get(i).get(j).copy();
      float dist = abs(needleLoc0.x - center.x);
      boolean val = abs(dist-edgWidth)<1 || (dist<intRad);// this includes all we want to keep (so everything that is on the edge OR is within 300 px of the center)
      if (!val) {
        collection.add(E.polylines.get(i).get(j));
      }
    }
    E.polylines.get(i).removeAll(collection);
  }
}

boolean NDaproxIn (PEmbroiderGraphics E, PVector ND) {
  for (int i=0; i<E.polylines.size(); i++) {
    for (int j=0; j<E.polylines.get(i).size(); j++) {
      PVector needleLoc = E.polylines.get(i).get(j).copy();
      if (needleLoc.sub(ND).mag()<.001) {
        return true;
      }
    }
  }
  return false;
}


void resetPolylineColor(PEmbroiderGraphics E, int i, color c) {
  int r = int(red(c));
  int g = int(green(c));
  int b = int(blue(c));
  int colorVal = 0xFF000000 | ((r & 255) << 16) | ((g & 255) << 8) | (b & 255);
  E.colors.set(i, colorVal);
}


String timeStamp() {
  return "D" + str(day())+"_"+str(hour())+"-"+str(minute())+"-"+str(second());
}


void backstitchPolyline(PEmbroiderGraphics E, int i) {
  ArrayList<PVector> collection = new ArrayList<PVector>();
  for (int j=1; j<E.polylines.get(i).size(); j++) {
    PVector needleLoc = E.polylines.get(i).get(j).copy();
    PVector needleLoc_backStitch = E.polylines.get(i).get(j-1).copy();
    collection.add(needleLoc);
    collection.add(needleLoc_backStitch);
  }
  E.polylines.get(i).clear();
  E.polylines.get(i).addAll(collection);
}


void backstitchPolylines(PEmbroiderGraphics E) {
  ArrayList<PVector> collection = new ArrayList<PVector>();
  for (int i=0; i<E.polylines.size(); i++) {
    collection.clear();
    collection.add(E.polylines.get(i).get(0));
    for (int j=1; j<E.polylines.get(i).size(); j++) {
      PVector needleLoc = E.polylines.get(i).get(j).copy();
      PVector needleLoc_backStitch = E.polylines.get(i).get(j-1).copy();
      collection.add(needleLoc);
      collection.add(needleLoc_backStitch);
    }
    E.polylines.get(i).clear();
    E.polylines.get(i).addAll(collection);
  }
}


void renderLoopOnPolys(PEmbroiderGraphics E, PEmbroiderGraphics E_ref) {
  for (int i=0; i<E_ref.polylines.size(); i++) {
    renderLoopOnPoly(E, E_ref, i);
  }
}



void renderLoopOnPoly(PEmbroiderGraphics E, PEmbroiderGraphics E_ref, int i) {
  E.beginShape();
  for (int j=0; j<E_ref.polylines.get(i).size()-1; j++) {
    PVector p1 = E_ref.polylines.get(i).get(j);
    PVector p2 = E_ref.polylines.get(i).get(j+1);
    drawLoopLine(E, p1.x, p1.y, p2.x, p2.y, 7, 8, 1);
  }
  E.endShape(CLOSE);
}


void drawLoopLine(PEmbroiderGraphics E, float startX, float startY, float endX, float endY, float stitchLength, float circleRad, float overlap) {  
  float loopLineAngle = PI/2;
  float r = circleRad;
  float cx = startX;
  float cy = startY;

  float lineLength = dist(startX, startY, endX, endY);
  float numCycles = (lineLength/r)*(1/overlap);

  float angleDifference = stitchLength/r;
  float pointsPerCircle = TWO_PI/angleDifference;
  float numSteps = pointsPerCircle*numCycles ;

  float dx = (endX-startX)/ numSteps;
  float dy = (endY-startY)/ numSteps;

  float curCX = cx;
  float curCY = cy;
  E.setStitch(1, 10, 0);
  for (int i = 0; i < numSteps; i++) {
    float curX = curCX+(r * cos(loopLineAngle));
    float curY = curCY+(r * sin(loopLineAngle));

    E.vertex(curX, curY);

    loopLineAngle += angleDifference;
    curCX += dx;
    curCY += dy;
  }
}

void renderZigOnPolys(PEmbroiderGraphics E, PEmbroiderGraphics E_ref) {
  for (int i=0; i<E_ref.polylines.size(); i++) {
    renderZigPoly(E, E_ref, i);
  }
}

void renderZigPoly(PEmbroiderGraphics E, PEmbroiderGraphics E_ref, int i) {
  int increments = 3;
  int dir = 1;
  E.beginShape();
  for (int k=0; k<E_ref.polylines.get(i).size()-1; k++) {
    PVector p1 = E_ref.polylines.get(i).get(k);
    PVector p2 = E_ref.polylines.get(i).get(k+1);
    PVector tan = p2.copy().sub(p1).normalize();
    tan.rotate(PI/2);
    tan.mult(10);
    PVector step = p2.copy().sub(p1).div(increments);
    for (int j = 0; j <increments; j++) {
      E.vertex(p1.x+step.x*j+tan.x*dir, p1.y+step.y*j+tan.y*dir);
      dir*= -1;
    }
  }
  E.endShape();
}

void renderZigPoly(PEmbroiderGraphics E, PEmbroiderGraphics E_ref, int i, float stWidth, int dir) {
  float stLen = 1.5;
  E.beginShape();
  for (int k=0; k<E_ref.polylines.get(i).size()-1; k++) {
    //increments * stLen = dist
    //increments = dis/stLen
    PVector p1 = E_ref.polylines.get(i).get(k);
    PVector p2 = E_ref.polylines.get(i).get(k+1);
    PVector tan = p2.copy().sub(p1).normalize();
    int increments = int(p1.copy().sub(p2).mag()/stLen);
    tan.rotate(PI/2);
    tan.mult(stWidth/2);
    PVector step = p2.copy().sub(p1).div(increments);
    for (int j = 0; j <increments; j++) {
      E.vertex(p1.x+step.x*j+tan.x*dir, p1.y+step.y*j+tan.y*dir);
      dir*= -1;
    }
  }
  E.endShape();
}


void renderZigPolyCircProf(PEmbroiderGraphics E, PEmbroiderGraphics E_ref, int i, float stWidth, int dir) {
  float stLen = 1.6;
  E.beginShape();
  for (int k=0; k<E_ref.polylines.get(i).size()-1; k++) {
    float t = 0;
    //increments * stLen = dist
    //increments = dis/stLen
    PVector p1 = E_ref.polylines.get(i).get(k);
    PVector p2 = E_ref.polylines.get(i).get(k+1);
    PVector tan = p2.copy().sub(p1).normalize();
    int increments = int(p1.copy().sub(p2).mag()/stLen);
    tan.rotate(PI/2);
    tan.mult(stWidth/2);
    PVector step = p2.copy().sub(p1).div(increments);
    float kSteps = 1/float(increments);
    for (int j = 0; j <increments; j++) {
      t = (float(k)+kSteps*float(j))/float(E_ref.polylines.get(i).size()-1)*PI;
      E.vertex(p1.x+step.x*j+tan.x*dir*sin(t), p1.y+step.y*j+tan.y*dir*sin(t));
      dir*= -1;
    }
  }
  E.endShape();
}

void renderZigPolyCircProf_REV(PEmbroiderGraphics E, PEmbroiderGraphics E_ref, int i, float stWidth, int dir) {
  float stLen = 3;
  E.beginShape();
  for (int k=E_ref.polylines.get(i).size()-2; k>=0; k--) {
    int k2 = (E_ref.polylines.get(i).size()-2)-k;
    float t = 0;
    PVector p1 = E_ref.polylines.get(i).get(k+1);
    PVector p2 = E_ref.polylines.get(i).get(k);
    PVector tan = p2.copy().sub(p1).normalize();
    int increments = int(p1.copy().sub(p2).mag()/stLen);
    tan.rotate(PI/2);
    tan.mult(stWidth/2);
    PVector step = p2.copy().sub(p1).div(increments);
    float kSteps = 1/float(increments);
    for (int j = 0; j <increments; j++) {
      t = (float(k2)+kSteps*float(j))/float(E_ref.polylines.get(i).size()-1)*PI;
      E.vertex(p1.x+step.x*j+tan.x*dir*sin(t), p1.y+step.y*j+tan.y*dir*sin(t));
      dir*= -1;
    }
  }
  E.endShape();
}


void renderZigPolyCircProfLowRes(PEmbroiderGraphics E, PEmbroiderGraphics E_ref, int i, float stWidth, int dir) {
  float stLen = 1.6;
  int steps = 0;
  E.beginShape();
  for (int k=0; k<E_ref.polylines.get(i).size()-1; k++) {
    float t = 0;
    if (E_ref.polylines.get(i).size()>2) {
      t = float(k)/float(E_ref.polylines.get(i).size()-2)*PI;
    } else {
      t = PI/2;
    }
    PVector p1 = E_ref.polylines.get(i).get(k);
    PVector p2 = E_ref.polylines.get(i).get(k+1);
    PVector tan = p2.copy().sub(p1).normalize();
    int increments = int(p1.copy().sub(p2).mag()/stLen);
    tan.rotate(PI/2);
    tan.mult(stWidth/2);
    PVector step = p2.copy().sub(p1).div(increments);
    for (int j = 0; j <increments; j++) {
      E.vertex(p1.x+step.x*j+tan.x*dir*sin(t), p1.y+step.y*j+tan.y*dir*sin(t));

      dir*= -1;
    }
  }
  E.endShape();
}

float polyTraced = 0;
float sizeFilter = 2;

void renderZigPolyFUNProf(PEmbroiderGraphics E, PEmbroiderGraphics E_ref, int i, float stWidth, int dir, boolean doSampleSize) {
  float stLen = 1.6;
  E.beginShape();
  for (int k=0; k<E_ref.polylines.get(i).size()-1; k++) {
    float t = 0;
    //increments * stLen = dist
    //increments = dis/stLen
    PVector p1 = E_ref.polylines.get(i).get(k);
    PVector p2 = E_ref.polylines.get(i).get(k+1);
    PVector tan = p2.copy().sub(p1).normalize();
    int increments = int(p1.copy().sub(p2).mag()/stLen);
    tan.rotate(PI/2);
    tan.mult(stWidth/2);
    PVector step = p2.copy().sub(p1).div(increments);
    float kSteps = 1/float(increments);
    for (int j = 0; j <increments; j++) {
      t = (float(k)+kSteps*float(j))/float(E_ref.polylines.get(i).size()-1);
      if (doSampleSize){
        if (stWidth/2*f1(t)>sizeFilter) {
          E.vertex(p1.x+step.x*j+tan.x*dir*f1(t), p1.y+step.y*j+tan.y*dir*f1(t));
        }
    } else {
      E.vertex(p1.x+step.x*j+tan.x*dir*f1(t), p1.y+step.y*j+tan.y*dir*f1(t));
    }
    dir*= -1;
  }
}
E.endShape();
}

void renderZigPolyFUNProf_REV(PEmbroiderGraphics E, PEmbroiderGraphics E_ref, int i, float stWidth, int dir, boolean doSampleSize) {
  float stLen = 3;
  E.beginShape();
  for (int k=E_ref.polylines.get(i).size()-2; k>=0; k--) {
    int k2 = (E_ref.polylines.get(i).size()-2)-k;
    float t = 0;
    PVector p1 = E_ref.polylines.get(i).get(k+1);
    PVector p2 = E_ref.polylines.get(i).get(k);
    PVector tan = p2.copy().sub(p1).normalize();
    int increments = int(p1.copy().sub(p2).mag()/stLen);
    tan.rotate(PI/2);
    tan.mult(stWidth/2);
    PVector step = p2.copy().sub(p1).div(increments);
    float kSteps = 1/float(increments);
    for (int j = 0; j <increments; j++) {
      t = 1-(float(k2)+kSteps*float(j))/float(E_ref.polylines.get(i).size()-1);
      if (doSampleSize){
        if (stWidth/2*f1(t)>sizeFilter) {
          E.vertex(p1.x+step.x*j+tan.x*dir*f1(t), p1.y+step.y*j+tan.y*dir*f1(t));
        }
    } else {
      E.vertex(p1.x+step.x*j+tan.x*dir*f1(t), p1.y+step.y*j+tan.y*dir*f1(t));
    }
    dir*= -1;
  }
}
E.endShape();
}


float f1(float t) {
  return f4(t);//sin(t*PI)/3*2;
}


float f2(float t, float offset) {
  float output = 0;
  if (t<.2) {
    output = f3(t, new PVector(0, 0), new PVector(offset, 1));
  } else if (t>=.2 && t<.8) {
    output = 1;
  } else {
    output = f3(t, new PVector(1-offset, 1), new PVector(1, 0));
  }
  return output;
}

float f3(float t, PVector P0, PVector P1) {
  float output = (t-P0.x)*(P1.y-P0.y)/(P1.x-P0.x)+P0.y;
  return output;
}

float f4(float t) {
  return sin(pow(t, 4)*PI);
}

float f5(float t) {
  return noise(t*3, polyTraced)*f2(t, .2);
}

float f6(float t) {
  return f3(t, new PVector(0, 0), new PVector(1, .5));
}


void renderZigOnLines(PEmbroiderGraphics E, PEmbroiderGraphics E_ref) {
  for (int i=0; i<E_ref.polylines.size(); i++) {

    renderZigPolyCircProf(E, E_ref, i, hatchSpacing/4, 1);
    renderZigPolyCircProf_REV(E, E_ref, i, hatchSpacing/2, 1);
    renderZigPolyCircProf(E, E_ref, i, hatchSpacing*5/8, 1);
  }
}

void renderZigFUNOnLines(PEmbroiderGraphics E, PEmbroiderGraphics E_ref) {
  for (int i=0; i<E_ref.polylines.size(); i++) {
    renderZigPolyFUNProf(E, E_ref, i, hatchSpacing/8, 1, true);
    renderZigPolyFUNProf_REV(E, E_ref, i, hatchSpacing*3/8, 1, true);
    renderZigPolyFUNProf(E, E_ref, i, hatchSpacing*5/8, 1, false);
    polyTraced++;
  }
}

void testFuntion() {
  for (int i = 0; i<100; i++) {
    float val = float(i)/99.00;
    println(f5(val));
  }
}



////////////////////// END NEEDLE DOWN HELPERS /////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////
