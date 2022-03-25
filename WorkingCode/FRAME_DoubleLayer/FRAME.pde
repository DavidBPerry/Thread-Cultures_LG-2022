import processing.embroider.*;
PEmbroiderGraphics E;

//// FILE PARAMETERS
String fileType = ".pes";  // CHANGE ME
String fileName = "FRAME"; // CHANGE ME
//// END FILE PARAMETERS

//// RUN VARIABLESz
float diameter = 580;
float diamOff = 500;

//// END RUN VARIABLES

void setup() {
  size(1300, 1800);
  E = new PEmbroiderGraphics(this, width, height);
  E.CIRCLE_DETAIL = 74;
  while(diameter<=1280){
    E.clear();
  ////////////////////////////////
  ///// 1) Marking Stitch
  E.setStitch(7, 10, 0);
  E.noFill();
  E.strokeWeight(1);
  E.stroke(255, 0, 0);
  E.circle(width/2, height/2, diameter-65); // INNER DIAMETER = diameter-65 = ~ 1200
  E.circle(width/2, height/2, diameter-60);

  /////
  //1.5) Cut top fabric here
  /////



  ///// 3) Edge Stitch
  E.setStitch(5, 18, 0);
  E.stroke(0, 0, 255);
  drawIris(E,width/2,height/2,diameter-diamOff,diameter,25); // Input: PEmbroiderGraphics, x Center, y Center, inner diameter, outer Diameter, arc Length between lines

  /////
  // 3.5) Add bottom fabric here
  /////

  // dist = mag((rad,0)+(0,len)) = sqrt(rad^2+(90+diameter/4)^2)
  E.setStitch(5, 12, 0);
  E.stroke(0, 200, 200);
  E.circle(width/2, height/2, diameter);
  E.circle(width/2, height/2, diameter);
  
  E.stroke(200, 200, 0);
  E.setStitch(5, 100, 0);
  E.strokeMode(E.PERPENDICULAR);
  E.strokeSpacing(1.8);
  E.strokeWeight(70);
  E.circle(width/2,height/2,diameter - 52);

  //
  PEmbroiderWrite(E, fileName+"_OUT"+str(diameter)+"_IN"+str(diameter-diamOff));
  diameter += 100;
  ////////////////////
  }
  
  
}

void draw() {
  background(200);
  int visualInput = int(map(mouseX, 0, width, 0, ndLength(E)+4));
  E.visualize(true, true, true, visualInput);
}



void PEmbroiderWrite(PEmbroiderGraphics E, String fileName) {
  String outputFilePath = sketchPath(fileName+fileType);
  E.setPath(outputFilePath);
  E.endDraw(); // write out the file
}


void drawIris(PEmbroiderGraphics E, float x, float y, float diam, float outDiam, float arcLength) {
  E.pushMatrix();
  E.translate(x, y);
  E.noFill();
  float rad = diam/2;
  float radOut = outDiam/2;
  float thStep = arcLength / radOut;
  float thSteps = 0;
  float theta = 0;
  int i = 0;
  while (thSteps<= 2*PI) {
    
    E.pushMatrix();
    E.translate(rad, 0);
    E.rotate(PI/2);
    E.rotate(theta);
    // outer_rad^2 = rad^2 + len^2
    // len = sqrt(outer_rad^2-rad^2)
    float len = sqrt(pow(outDiam/2,2)-pow(diam/2,2));
    if (i%2 == 0) {
      E.line(-len, 0, len, 0);
    } else {
      E.line(len, 0, -len, 0);
    }
    E.popMatrix();
    
    E.rotate(thStep);

    thSteps+= thStep;
    i++;
  }
  E.popMatrix();
}

void drawIris2(PEmbroiderGraphics E, float x, float y, float rad) {
  E.pushMatrix();
  E.translate(x, y);
  float arLen = 30;
  float thStep = arLen/rad;

  float thSteps = 0;
  int i = 0;

  float angleDif = PI*7/16;

  while (thSteps < 2*PI) {
    if (i%2==0) {
      connectPointsOnCircle(E, thSteps, thSteps+angleDif, rad);
    } else {
      connectPointsOnCircle(E, thSteps+angleDif, thSteps, rad);
    }
    thSteps += thStep;
    i++;
  }
  E.popMatrix();
}


PVector[] connectPointsOnCircle(PEmbroiderGraphics E, float th1, float th2, float rad) {
  //th1 & th2 are in radians
  // centered on zero
  PVector [] vects = new PVector[2];
  int x1 = int(cos(th1)*rad);
  int y1 = int(sin(th1)*rad);
  int x2 = int(cos(th2)*rad);
  int y2 = int(sin(th2)*rad);
  vects[0] = new PVector(x1, y1);
  vects[1] = new PVector(x2, y2);
  E.line(x1, y1, x2, y2);
  return vects;
}


int ndLength(PEmbroiderGraphics E) {
  //return the total number of needle downs in the job
  int n = 0;
  for (int i=0; i<E.polylines.size(); i++) {
    n += E.polylines.get(i).size()-1;
  }
  return n;
}
