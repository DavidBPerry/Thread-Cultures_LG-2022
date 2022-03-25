import processing.embroider.*;

//// FILE PARAMETERS
String fileType = ".pes";  // CHANGE ME 
String fileName = "SPIRAL_Noise"; // CHANGE ME
//// END FILE PARAMETERS

//// RUN VARIABLES
float offset = 11;
float maxDiam = 400;
//// END RUN VARIABLES

PEmbroiderGraphics E;
float z = 0;

//// interaction variables
boolean edditting = true; // for use during draw function
////


void setup() {
  size(900, 900); //100 px = 1 cm (so 14.2 cm is 1420px)
  E = new PEmbroiderGraphics(this, width, height);
}


void draw() {
  if (edditting) {
    z = mouseX;
    background(200);
    E.clear();
    drawSpiralized(E);
    E.visualize(true, true, true);
  } else {
    background(200);
    int visualInput = int(map(mouseX, 0, width, 0, ndLength(E)+4));
    E.visualize(true, true, true, visualInput);
  }
}


void keyPressed() {
  if (key == ' ') {
    edditting = false;
    PEmbroiderWrite(E, fileName);
  }
}

void drawSpiralized(PEmbroiderGraphics E) {
  E.pushMatrix();
  E.translate(width/2, height/2);
  float theta = 1;
  float stepLen = 1.9;
  int steps = 1000*10;
  E.stroke(0);
  E.setStitch(10, 40, 0);
  E.beginShape();
  // spiral variables
  int i = 1;
  float r = theta/(2*PI)*offset*2;
  while(r < maxDiam/2) {
    r = theta/(2*PI)*offset*2;
    float thetaStep = stepLen/r;
    PVector coord = radi2card(r+offset(r, theta, i), theta);
    E.vertex(coord.x, coord.y);
    theta+= thetaStep;
    i ++;
  }
  E.endShape();
  E.popMatrix();
}

float offset(float r, float theta, int i) {
  PVector coord = radi2card(r, theta).add(new PVector(width/2, height/2));
  float off = logiMap(noise(coord.x*.01, coord.y*.01, z/20));
  if (off*offset < 1.8) {
    off = 0;
  }
  if (i%2 == 0) {
    return -1*off*offset;
  }
  return off*offset;
}

float logiMap(float input) {
  float L = 1;
  float k = 10.4;
  float x_0 = .5;
  float e = 2.7182;

  return L/(1+pow(e, (-k*(input-x_0))));
}



PVector radi2card(float r, float th) {
  PVector card = new PVector(0, r);
  return card.rotate(th);
}

void PEmbroiderWrite(PEmbroiderGraphics E, String fileName) {
  String outputFilePath = sketchPath(fileName+timeStamp()+fileType);
  E.setPath(outputFilePath);
  E.endDraw(); // write out the file
}

String timeStamp() {
  return "D" + str(day())+"_"+str(hour())+"-"+str(minute())+"-"+str(second());
}

int ndLength(PEmbroiderGraphics E) {
  //return the total number of needle downs in the job
  int n = 0;
  for (int i=0; i<E.polylines.size(); i++) {
    n += E.polylines.get(i).size()-1;
  }
  return n;
}
