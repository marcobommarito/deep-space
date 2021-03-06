Planet[] planets;
int numPlanets = 500;
int currentPlanet = 0;
HScrollbar gslider;
int timeCount;
int timeSinceClickBuffer;
int timeSinceClick;

//Gravitational Constant
float G;

void setup(){
  timeCount = 0;
  timeSinceClick = 0;
  timeSinceClickBuffer = 0;
  size(800, 600);
  background(8, 126, 139);
  cursor(CROSS);
  planets = new Planet[numPlanets];
  for (int i = 0; i < planets.length; i++) {
    planets[i] = new Planet();
  }
  gslider = new HScrollbar(400, 8, /*width*/400, 16, 16);
  gslider.display();
  textSize(18);
  fill(0);
  text("Gravitational Constant", 500, 35);
}

void draw() {
  timeCount++;
  timeSinceClickBuffer++;
  if (timeSinceClickBuffer > 1000) timeSinceClick++;
  
  background(8 + (.2 * timeSinceClick), 126 + (.2 * timeSinceClick), 139 + (.2 * timeSinceClick));
  
  for (int i = 0; i < numPlanets; i++) {
  
    
    G = .001 * exp( 46.05 * (gslider.getPos()/7958.56) - 0.0524847 );
    print (" G equals:"); print(G);
    planets[i].display();
    planets[i].move();
    //planets[i].leak(timeCount);
    
    gslider.update();
    gslider.display();
  }
  
  if (timeCount % (Math.round(Math.random() * 2000)) == 0 && timeSinceClick > 1275 || timeSinceClick == 1275){
    float x = (float) (Math.random() * 750) + 25;
    float y = (float) (Math.random() * 550) + 25;
    float X = (float) Math.random() * 5 - 2.5;
    float Y = (float) Math.random() * 5 - 2.5;
    float r = (float) Math.random() * 6 + 3;
    planets[currentPlanet].start(x, y, X, Y, r);
    currentPlanet++;
  }
  
  textSize(18);
  fill(0);
  text("Gravitational Constant", 500, 35);
  
  //if (timeSinceClick % 6000 == 5999) reset();
}

void mousePressed() {
  if (gslider.over != true) {
    if (mouseButton == LEFT) {
      //Generate random parameters
      float X = (float) Math.random() * 5 - 2.5;
      float Y = (float) Math.random() * 5 - 2.5;
      float r = (float) Math.random() * 6 + 3;
      //Create new (random) planet
      planets[currentPlanet].start(mouseX, mouseY, X, Y, r);
      currentPlanet++;
      if (currentPlanet >= numPlanets) {
        currentPlanet = 0;
      }
      timeSinceClickBuffer = 0;
      timeSinceClick = 0;
      
      //Right-click to reset
    } else if (mouseButton == RIGHT) {
      reset();
    }
  }
}

void reset(){
  textSize(18);
  fill(0);
  text("Gravitational Constant", 500, 35);
  gslider.display();
  for (int i = 0; i < numPlanets; i++) {
    planets[i].on = false;
  }
}


//------------------------------------------------------------------------------------------------------------------------


class Planet {
  float rad;
  float mass;
  float size;
  float xAcc;
  float yAcc;
  float xVel;
  float yVel;
  float xPos;
  float yPos;
  color c;
  boolean anti;
  boolean on = false;

  Planet () {
  }
  
  void start(float newXPos, float newYPos, float newXVel, float newYVel, float newRad) {
    xVel = newXVel;
    yVel = newYVel;
    xPos = newXPos;
    yPos = newYPos;
    rad = newRad;
    mass = rad * rad;
    float test = (float) Math.random() * 400;
    if (test > 1) {
      anti = false;
    } else {
      anti = true;
    }
    if (anti == false) {
      c = color(0);
    } else {
      c = color(255);
    }
    on = true;
  }
  
  
  void leak(int timeCount){
    if (on == true && timeCount % 20 == 0 ){
      this.rad -= .08
      this.mass = this.rad * this.rad;
      
    }
  }
  
  void move() {
    if (on == true) {
      
            if (anti == false) {
              //Merges planets if need be
              for (int i = 0; i < numPlanets; i++) {
                if (planets[i].on == true && planets[i] != this) {
                float xDist = planets[i].xPos - xPos;
                float yDist = planets[i].yPos - yPos;
                float dist = sqrt((xDist * xDist) + (yDist * yDist));
                  if ((dist) < (rad + planets[i].rad - 7)) {
                    this.merge(mass, rad, xPos, yPos, xVel, yVel, i, planets[i].mass, planets[i].rad, planets[i].xPos, planets[i].yPos, planets[i].xVel, planets[i].yVel);
                    //Bouncy walls (I put it up here because otherwise it won't happen to newly-mergeds
                    if (xPos >= width-rad+5 || xPos <= rad-5){
                      this.on = false;
                    }
                    if (yPos >= height-rad+5 || yPos <= rad-5) {
                      this.on = false;
                    }
                    if (xPos >= width-rad || xPos <= rad) {
                      xVel *= -1;
                    }
                    if (yPos >= height-rad || yPos <= rad) {
                      yVel *= -1;
                    }
                    break; //This is necessary. I don't know why.  Just leave it there and forget about this whole if loop.
                  }
                }
              }
              
              xAcc = 0;
              yAcc = 0;
              float theta = 0;
              
              //Sends "gravitation particles"
              for (int i = 0; i < numPlanets; i++) {
                if (planets[i].on == true && planets[i] != this) {
                  float xDist = planets[i].xPos - xPos;
                  float yDist = planets[i].yPos - yPos;
                  
                  //Calculate the angle between them
                  if (xDist == 0 && yDist > 0) { 
                    double thta = Math.PI / 2;
                    theta = (float) thta;
                  } else if (xDist == 0 && yDist < 0) {
                    double thta = 3 * Math.PI / 2;
                    theta = (float) thta;
                  } else if (xDist > 0) {
                    theta = atan(yDist/xDist);
                  } else if (xDist < 0) { 
                    theta = atan(yDist/xDist) + (float) Math.PI;
                  }
                  
                  //Calculate the distance between them
                  float dist = sqrt((xDist * xDist) + (yDist * yDist));
                  
                  if (planets[i].anti == false) {
                    //Calculate the force between them
                    float force = ((G * mass * planets[i].mass)/(dist));
                    xAcc += (force * cos(theta))/mass;
                    yAcc += (force * sin(theta))/mass;
                    
                  } else if (planets[i].anti == true) {
                    //Calculate the force between them
                    float force = ((G * mass * planets[i].mass)/(dist));
                    xAcc -= (force * cos(theta))/mass;
                    yAcc -= (force * sin(theta))/mass;
                  }
              }
            }
            }
            
            else if (anti == true) {
              //Merges planets if need be
              for (int i = 0; i < numPlanets; i++) {
                if (planets[i].on == true && planets[i] != this) {
                float xDist = planets[i].xPos - xPos;
                float yDist = planets[i].yPos - yPos;
                float dist = sqrt((xDist * xDist) + (yDist * yDist));
                  if (dist < (rad + planets[i].rad - 7)) {
                    this.merge(mass, rad, xPos, yPos, xVel, yVel, i, planets[i].mass, planets[i].rad, planets[i].xPos, planets[i].yPos, planets[i].xVel, planets[i].yVel);
                    //Bouncy walls (I put it up here because otherwise it won't happen to newly-mergeds
                    if (xPos >= width-rad+5 || xPos <= rad-5){
                      this.on = false;
                    }
                    if (yPos >= height-rad+5 || yPos <= rad-5) {
                      this.on = false;
                    }
                    if (xPos >= width-rad || xPos <= rad) {
                      xVel *= -1;
                    }
                    if (yPos >= height-rad || yPos <= rad) {
                      yVel *= -1;
                    }
                    break; //This is necessary. I don't know why.  Just leave it there and forget about this whole if loop.
                  }
                }
              }
              
              xAcc = 0;
              yAcc = 0;
              float theta = 0;
              
              //Sends "gravitation particles"
              for (int i = 0; i < numPlanets; i++) {
                if (planets[i].on == true && planets[i] != this) {
                  float xDist = planets[i].xPos - xPos;
                  float yDist = planets[i].yPos - yPos;
                  
                  //Calculate the angle between them
                  if (xDist == 0 && yDist > 0) { 
                    double thta = Math.PI / 2;
                    theta = (float) thta;
                  } else if (xDist == 0 && yDist < 0) {
                    double thta = 3 * Math.PI / 2;
                    theta = (float) thta;
                  } else if (xDist > 0) {
                    theta = atan(yDist/xDist);
                  } else if (xDist < 0) { 
                    theta = atan(yDist/xDist) + (float) Math.PI;
                  }
                  
                  //Calculate the distance between them
                  float dist = sqrt((xDist * xDist) + (yDist * yDist));
                  
                  if (planets[i].anti == false) {
                    //Calculate the force between them
                    float force = ((G * mass * planets[i].mass)/(dist));
                    xAcc -= (force * cos(theta))/mass;
                    yAcc -= (force * sin(theta))/mass;
                    
                  } else if (planets[i].anti == true) {
                    //Calculate the force between them
                    float force = ((G * mass * planets[i].mass)/(dist));
                    xAcc += (force * cos(theta))/mass;
                    yAcc += (force * sin(theta))/mass;
                  }
              }
            }
            }
      
      
      
      //Forces have effect now
      xVel += xAcc;
      yVel += yAcc;
      xPos += xVel;
      yPos += yVel;
      
      //Bouncy walls
      if (xPos >= width-rad+5 || xPos <= rad-5){
        this.on = false;
      }
      if (yPos >= height-rad+5 || yPos <= rad-5) {
        this.on = false;
      }
      if (xPos >= width-rad || xPos <= rad) {
        xVel *= -1;
      }
      if (yPos >= height-rad || yPos <= rad) {
        yVel *= -1;
      }
      
      
    }
  }
  
  void display() {
    if (on == true) {
      if (this.rad < .01) {
        this.on = false;
      }
      stroke(c);
      fill(c);
      ellipse(xPos, yPos, 2 * rad, 2 * rad);
        
    }
  }
  
  void merge(float mass1, float rad1, float xPos1, float yPos1, float xVel1, float yVel1, int NUMPLANET2, float mass2, float rad2, float xPos2, float yPos2, float xVel2, float yVel2) {
    this.on = false;
    
    if (this.anti == planets[NUMPLANET2].anti) {
      planets[NUMPLANET2].mass = mass1 + mass2;
      planets[NUMPLANET2].rad = sqrt(planets[NUMPLANET2].mass);
      planets[NUMPLANET2].xVel = (mass1 * xVel1 + mass2 * xVel2)/(mass1 + mass2);
      planets[NUMPLANET2].yVel = (mass1 * yVel1 + mass2 * yVel2)/(mass1 + mass2);
      planets[NUMPLANET2].xPos += ( ((mass1 * xPos1 + mass2 * xPos2)/(mass1 + mass2)) - xPos2 );
      planets[NUMPLANET2].yPos += ( ((mass1 * yPos1 + mass2 * yPos2)/(mass1 + mass2)) - yPos2 );
    } else if (this.anti != planets[NUMPLANET2].anti) {
      if (mass1 > mass2) {
        planets[NUMPLANET2].mass = mass1 - mass2;
        planets[NUMPLANET2].rad = sqrt(planets[NUMPLANET2].mass);
        planets[NUMPLANET2].xVel = (mass1 * xVel1 - mass2 * xVel2)/(mass1 - mass2);
        planets[NUMPLANET2].yVel = (mass1 * yVel1 - mass2 * yVel2)/(mass1 - mass2);
        planets[NUMPLANET2].xPos = xPos1;
        planets[NUMPLANET2].yPos = yPos1;
        planets[NUMPLANET2].c = this.c;
        planets[NUMPLANET2].anti = this.anti;

      } else if (mass1 < mass2) {
        planets[NUMPLANET2].mass = mass2 - mass1;
        planets[NUMPLANET2].rad = sqrt(planets[NUMPLANET2].mass);
        planets[NUMPLANET2].xVel = (-mass1 * xVel1 + mass2 * xVel2)/(mass1 - mass2);
        planets[NUMPLANET2].yVel = (-mass1 * yVel1 + mass2 * yVel2)/(mass1 - mass2);
        planets[NUMPLANET2].xPos = xPos2;
        planets[NUMPLANET2].yPos = xPos2;

      }
    } 
    
  }
  
  
}











class HScrollbar {
  int swidth, sheight;    // width and height of bar
  float xpos, ypos;       // x and y position of bar
  float spos, newspos;    // x position of slider
  float sposMin, sposMax; // max and min values of slider
  int loose;              // how loose/heavy
  boolean over;           // is the mouse over the slider?
  boolean locked;
  float ratio;

  HScrollbar (float xp, float yp, int sw, int sh, int l) {
    swidth = sw;
    sheight = sh;
    int widthtoheight = sw - sh;
    ratio = (float)sw / (float)widthtoheight;
    xpos = xp;
    ypos = yp-sheight/2;
    spos = xpos + swidth/2 - sheight/2;
    newspos = spos;
    sposMin = xpos;
    sposMax = xpos + swidth - sheight;
    loose = l;
  }

  void update() {
    if (overEvent()) {
      over = true;
    } else {
      over = false;
    }
    
    if (mousePressed && over) {
      locked = true;
    }
    if (!mousePressed) {
      locked = false;
    }
    if (locked) {
      newspos = constrain(mouseX-sheight/2, sposMin, sposMax);
    }
    if (abs(newspos - spos) > 1) {
      spos = spos + (newspos-spos)/loose;
    }
  }

  float constrain(float val, float minv, float maxv) {
    return min(max(val, minv), maxv);
  }

  boolean overEvent() {
    if (mouseX > xpos && mouseX < xpos+swidth &&
       mouseY > ypos && mouseY < ypos+sheight) {
      return true;
    } else {
      return false;
    }
  }

  void display() {
    noStroke();
    fill(204);
    rect(xpos, ypos, swidth, sheight);
    if (over || locked) {
      fill(0, 0, 0);
    } else {
      fill(102, 102, 102);
    }
    rect(spos, ypos, sheight, sheight);
  }

  float getPos() {
    // Convert spos to be values between
    // 0 and the total width of the scrollbar
    return spos * ratio;
  }
}
