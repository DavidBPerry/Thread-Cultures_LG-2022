/// Basic PEmbroidery Setup
import processing.embroider.*;
String fileType = ".pes";
String fileName = "mossyConcentricStitching"; // CHANGE ME
PEmbroiderGraphics E;
PEmbroiderGraphics E2;
int frames = 0;



PImage image;

boolean running = true;

float innerTextureDiam = 200;
float outerDiam = 300;

Pack p;

void setup() {
  size(800, 800); //100 px = 1 cm (so 14.2 cm is 1420px)
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
    int visualInput = int(map(mouseX, 0, width, 0, ndLength(E)*2));
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

float maxDiam = 300;
float minDiam = 100;
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
     val = noise(mouseX*.01, mouseY*.01)*40+10;
    if (val < 5) {
      val = 0;
    }
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
    culledPerlinFill();
    for (int i=0; i<p.circles.size(); i++) {
      Circle circ = p.circles.get(i);
      if (!circ.set) {
        drawMossyCircle(E, circ.position.x, circ.position.y, circ.diameter,float(i), false); //////////////////////////// <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      }
    }
    PEmbroiderWrite(E, fileName);
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


void culledPerlinFill(){
  E.beginOptimize();
    /// begin shape cull
    int numCull = 3; // number of layers for culled shape
    E.CULL_SPACING = 13;

    // CULL 1
    for (int j = 0; j<numCull; j++) {
      E.hatchMode(PEmbroiderGraphics.PERLIN);
      E.noStroke();
      E.hatchSpacing(4); // decrease per cull (min is 3)
      E.fill(0);
      E.beginCull();
      E.pushMatrix();
      E.translate(width/2, height/2);
      E.rotate(3*j); // rotate by some amount per cull
      E.hatchAngleDeg(45); 
      E.setStitch(40, 60, .1); // increase the stitch length per cull number
      E.circle(0, 0, innerTextureDiam);
      E.popMatrix();




      for (int i=0; i<p.circles.size(); i++) {
        Circle circ = p.circles.get(i);
        drawMossyCircle( E, circ.position.x, circ.position.y, circ.diameter, i, true);
      }
      E.endCull();
    }
    E.endOptimize();
}

//////// run these at begginning and end of setup ////////////////////////////////////

void PEmbroiderStart() {
  E = new PEmbroiderGraphics(this, width, height);
  String outputFilePath = sketchPath(fileName+fileType);
  E.setPath(outputFilePath);
  E.setStitch(8, 14, .1);
}

void PEmbroiderWrite(PEmbroiderGraphics E, String fileName) {
  String outputFilePath = sketchPath(fileName+timeStamp()+fileType);
  E.setPath(outputFilePath);
  E.endDraw(); // write out the file
}

String timeStamp() {
  return "D" + str(day())+"_"+str(hour())+"-"+str(minute())+"-"+str(second());
}

///////////////////////////////////////////////////////////////////////////////////////








////////////////////////////Mossy circle2 : no double stitch on inside


PVector pol2cart(float r, float theta) {
  int x = int(cos(theta)*r);
  int y = int(sin(theta)*r);
  return new PVector(x, y);
}

PVector getPointOnRadius(float th, float rad) {
  int x = int(cos(th)*rad);
  int y = int(sin(th)*rad);
  return new PVector(x, y);
}


float noiseLoop(float rad, float t, float z) {
  // we translate the center of the cicle so that there are no neg values
  // note: for some reason some symmetry was observed when the circle was centered on 0,0 and the input loop was symmetrical across the x and y axis
  // we assign t so that 0 is beginning of loop; 1 is end of loop
  float theta = t*2*PI; // map t to theta
  float x = cos(theta)*rad+rad;
  float y = sin(theta)*rad+rad;
  return (noise(x, y, z)-.5)*2;
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










void drawMossyCircle( PEmbroiderGraphics E, float x, float y, float diam1, float z, boolean doCull) {


  ///// stitching parameters ////
  E.noFill();
  E.stroke(0, 0, 0); 
  E.strokeWeight(1);
  E.setStitch(20, 300, 0);
  ///// stitching parameters ////
 
  float diam2 = diam1/4;

  float theta = 0; // convert to radians
  float offset = diam1/7;//pow(((abs(diam1-diam2)/2)/10), 2)*2;
  diam1 -= offset;
  println("circle number " + str(z)+":");
  println(offset);
  println(diam1);
  println(diam2);
  println();

  text(z, x, y);

  if (diam2 <50) {
    diam2 = 50;
  }

  float ar = 1; // arc length of steps along interior circle
  float thStep = ar*2/(diam2+30*offset/diam2);//

  //println(thStep*float(diam2+25)/2);
  float thSteps = 0;
  int i = 0;

  E.pushMatrix();
  E.translate(x, y);

  E.noFill();
  E.strokeWeight(1);
  E.stroke(0);

  E.beginShape();
  if (!doCull) {
    for(int j = 2; j >=0; j--){
    thSteps = 0;
    i = 0;
    ar = 1+j*1.8;
    thStep = ar*2/(diam2+30*offset/diam2);
    while (thSteps < PI*2) {
      int offsetOut = int(noiseLoop(.5, thSteps/(2*PI), 0+z)*offset)-11*j;
      int offsetIn = int(noiseLoop(.5, thSteps/(2*PI), .5+z)*offset)+11*j;
      if(diam1/2+offsetOut-(diam2/2+offsetIn)>4){
      if (i%2 == 0) {
        connect2CircleVertex(E, thSteps, thSteps, diam1/2+offsetOut, diam2/2+offsetIn);
      } else {
        connect2CircleVertex(E, thSteps, thSteps, diam2/2+offsetIn, diam1/2+offsetOut);
      }
      }
      thSteps += thStep;//random(0,thStep);
      i++;
    }
    }
    
    
    
  } else {
    E.hatchMode(PEmbroiderGraphics.PARALLEL); 
    E.hatchSpacing(5);
    E.fill(170);
    E.setStitch(10, 20, .1);
    E.noStroke();
    E.beginShape();
    thSteps = 0;
    while (thSteps < PI*2) {
      int offsetOut = int(noiseLoop(.5, thSteps/(2*PI), 0+z)*offset);
      PVector p = getPointOnRadius(thSteps, diam1/2+offsetOut);
      E.vertex(p.x, p.y);
      thSteps += thStep;//random(0,thStep);
      i++;
    }
  }
  E.endShape();

  E.popMatrix();
}


void connect2CircleVertex(PEmbroiderGraphics E, float th1, float th2, float rad1, float rad2) {
  // th1 & th2 are in radians
  // centered on zero
  int x1 = int(cos(th1)*rad1);
  int y1 = int(sin(th1)*rad1);
  int x2 = int(cos(th2)*rad2);
  int y2 = int(sin(th2)*rad2);
  if(abs(rad1-rad2)>3){
    E.vertex(x1, y1);
    E.vertex(x2, y2);
  }
}
