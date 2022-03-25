 /// Basic PEmbroidery Setup
import processing.embroider.*;
String fileType = ".pes";
String fileName = "mossyConcentricStitching"; // CHANGE ME
PEmbroiderGraphics E;
PEmbroiderGraphics E2;

float outerDiam = 400;


PImage image;

boolean running = true;
boolean debugging = false;
boolean doShowStats = false;

int stitchBuildCounter = 0;

Pack p;

void setup() {
  size(1200, 1200); //100 px = 1 cm (so 14.2 cm is 1420px)
  PEmbroiderStart();
  E2 = new PEmbroiderGraphics(this, width, height);
  p = new Pack();
  E2.rectMode(CENTER);
  E2.circle(width/2, height/2, outerDiam);
  p.addSetAlongPoly(E2);
}


void draw() {
  if (running) {
    background(100);
    p.run();
    if (!randomRadius) {
      pushStyle();
      stroke(255, 0, 0);
      noFill();
      circle(mouseX, mouseY, diameter);
      popStyle();
    } else {
      pushStyle();
      fill(255, 0, 0);
      noStroke();
      if(DiamMode != 0){
        circle(mouseX, mouseY, diamFunction());
      } else {
        fill(0, 255, 0);
        circle(mouseX, mouseY, 10);
      }
      fill(255, 0, 0);
      stroke(255, 0, 0);
      line(mouseX, mouseY, width/2, height/2);
      popStyle();
    }
  } else {
    background(100);
    int visualInput = int(map(mouseX, 0, width, 0, ndLength(E)+4));
    E.visualize(true, true, true, visualInput);
    pushStyle();
    fill(255);
    stroke(255);
    text(visualInput, 10, 30);
    text(ndLength(E), 10, 50);
    text(ndLength(E), 10, 50);


    popStyle();
  }
}

float maxDiam = 45;
float minDiam = 16;
boolean randomRadius = true;
int diameter = 40;

void mousePressed() {
  float diam = 0;
  if (randomRadius) {
    diam = diamFunction();
  } else {
    diam = diameter;
  }
  p.circles.add(new Circle(mouseX, mouseY, diam));
}



int waitVal = 0;
void mouseDragged() {
  float diam = 0;
  if (randomRadius) {
    diam = diamFunction();
  } else {
    diam = diameter;
  }

  if (waitVal == 0) {
    p.circles.add(new Circle(mouseX, mouseY, diam));
    waitVal = 10;
  } else if (waitVal > 0) {
    waitVal--;
  }
}

int DiamMode = 0;
float diamFunction() {
  float val = -100000;
  if (DiamMode == 0) {
    return random(minDiam, maxDiam);
  } else if (DiamMode == 1) {
    PVector pointVect = new PVector(width/2-mouseX, height/2-mouseY);
     val = (400 - pointVect.mag())/5;
    if (val < 5) {
      val = 0;
    }
    return val;
  } else if (DiamMode == 2) {
    PVector pointVect = new PVector(width/2-mouseX, height/2-mouseY);
    //println(pointVect.mag());
     val = logistic(pointVect.mag());
    if (val < 5) {
      val = 0;
    }
  } else if (DiamMode == 3) {
     val = pow(noise(mouseX*.01, mouseY*.01),1.4)*70+10;
    if (val < 5) {
      val = 0;
    }
    println(val);
  }
  return val;
}


float logistic(float x) {
  // Desmos :
  float e = 2.71828;
  float L = 30;
  float k = -.03;
  float x_0 = 180;
  float a = 10;
  float val = L/(1+pow(e, -k*(x-x_0)))+ a;
  return val;
}



void keyPressed() {
  if (key == ' ') {
    running = false;
    for (int i=0; i<p.circles.size(); i++) {
      Circle circ = p.circles.get(i);
      if (!circ.set) {
        int stitchOverlap = drawKnot2(E, circ.diameter/2, circ.position.x, circ.position.y); //////////////////////////// <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        if (doShowStats) {
          E.setStitch(15, 20, 0);
          E.text("Diam:"+str(int(circ.diameter)), circ.position.x+100, circ.position.y-25);
          E.text("Th#:"+str(stitchOverlap), circ.position.x+100, circ.position.y+25);
        }
      }
    }
    PEmbroiderWrite(E, "frenchKnottyBits");
  }
  if (key == 'r') {
    if (randomRadius) {
      randomRadius = false;
    } else {
      randomRadius = true;
    }
  }
  if (key == CODED) {
    if (keyCode == UP) {
      diameter+=2;
    } else if (keyCode == DOWN) {
      if (diameter > 15) {
        diameter-=2;
      }
    }
  }
}


//////// run these at begginning and end of setup ////////////////////////////////////

void PEmbroiderStart() {
  E = new PEmbroiderGraphics(this, width, height);
  String outputFilePath = sketchPath(fileName+fileType);
  E.setPath(outputFilePath);
  E.setStitch(8, 14, .1);
}

void PEmbroiderWrite(PEmbroiderGraphics E, String fileName) {
  String outputFilePath = sketchPath(fileName+";DIAM-"+outerDiam+";"+timeStamp()+fileType);
  E.setPath(outputFilePath);
  E.endDraw(); // write out the file
}

String timeStamp() {
  return "D" + str(day())+"_"+str(hour())+"-"+str(minute())+"-"+str(second());
}

///////////////////////////////////////////////////////////////////////////////////////




/// Knot Functions

void drawKnot1(PEmbroiderGraphics E, float rad, float x, float y) {
  E.pushMatrix();
  E.translate(x, y);
  E.setStitch(4, 400, 0);

  drawStarKnot(E, int(rad-9.5*3));

  drawStarKnot(E, int(rad-9.5*2));

  drawStarKnot(E, int(rad-9.5));

  E.rotate(PI/11);
  drawStarKnot(E, int(rad-2)); // .85
  E.popMatrix();
}

int drawKnot2(PEmbroiderGraphics E, float rad, float x, float y) {
  E.pushMatrix();
  E.translate(x, y);
  E.setStitch(4, 1000, 0);
  stitchBuildCounter = 0;
  drawStarKnot(E, int(rad-9*3));

  drawStarKnot(E, int(rad-9*2));

  drawStarKnot(E, int(rad-9));

  E.rotate(PI/11);
  drawStarKnot(E, int(rad-2)); // .85
  E.popMatrix();
  return stitchBuildCounter;
}


void drawStarKnot(PEmbroiderGraphics E, int rad) {
  println("/////// New Knot /////");
  if (rad*2>=10) {
    float arLen = 4;
    // arLen = rad*theta
    //
    float thStep = arLen/rad;

    float thSteps = 0;
    int i = 0;

    float angleDif = PI;
    PVector storedVect = new PVector(0, 0);

    while (thSteps < PI*1.1) {
      if (i%2==0) {
        PVector newVect = connectPointsOnCircle(E, thSteps, thSteps+angleDif, rad)[0];
        println(storedVect.sub(newVect).mag());
        storedVect = newVect.copy();
      } else {
        PVector newVect = connectPointsOnCircle(E, thSteps+angleDif, thSteps, rad)[1];
        println(storedVect.sub(newVect).mag());
        storedVect = newVect.copy();
      }
      thSteps += thStep;
      i++;
      stitchBuildCounter++;
    }
  }
}


PVector[] connectPointsOnCircle(PEmbroiderGraphics E, float th1, float th2, int rad) {
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



////////////////////////////Mossy circle2 : no double stitch on inside



void connect2CircleVertex(PEmbroiderGraphics E, float th1, float th2, int rad1, int rad2) {
  // th1 & th2 are in radians
  // centered on zero
  int x1 = int(cos(th1)*rad1);
  int y1 = int(sin(th1)*rad1);
  int x2 = int(cos(th2)*rad2);
  int y2 = int(sin(th2)*rad2);
  E.vertex(x1, y1);
  E.vertex(x2, y2);
}


PVector pol2cart(float r, float theta) {
  int x = int(cos(theta)*r);
  int y = int(sin(theta)*r);
  return new PVector(x, y);
}

PVector getPointOnRadius(float th, int rad) {
  int x = int(cos(th)*rad);
  int y = int(sin(th)*rad);
  return new PVector(x, y);
}


float noiseLoop(float rad, float t, float z) {
  // we translate the center of the cicle so that there are no neg values
  // note: for some reason some symmetry was observed when the circle was centered on 0,0 and the input loop was symmetrical across the x and y axis
  // we assign t so that 0 is beginning of loop; 1 is end of loop
  float val = 0;
  float theta = t*2*PI; // map t to theta
  float x = cos(theta)*rad+rad;
  float y = sin(theta)*rad+rad;
  if (debugging) {
    println("x: "+str(x));
    println("y: "+str(y));
    pushMatrix();
    translate(width/2, height/2);
    circle(x*100, y*100, 5);
    popMatrix();
  }
  return noise(x, y, z);
}




//////////////////////////////////////////////////////////////////////////////


int ndLength(PEmbroiderGraphics E) {
  //return the total number of needle downs in the job
  int n = 0;
  for (int i=0; i<E.polylines.size(); i++) {
    n += E.polylines.get(i).size()-1;
  }
  return n;
}
