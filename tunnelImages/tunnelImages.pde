

void setup() {
  size(800, 800);
}

void draw() {
  background(0);
  translate(width/2, height/2);
  //ellipseDotted(5, 100, 15, 0.5*sin(millis()/1000.0)+0.5);
  ellipseDotted(int(10*sin(millis()/1000.0))+10, 100, 15);
}

void ellipseDotted(int numDots, int diam, int sw){
  ellipseDotted(numDots, diam, sw, 0.5);
}

void ellipseDotted(int numDots, int diam, int sw, float percentDot) {
  float angleDots = (2 * PI * percentDot) / numDots;
  float angleSpace = 2 * PI * (1-percentDot) / numDots;
  float angle = 0;
  while (angle < 2 * PI && angleDots > 0 && angleSpace > 0) {
    fill(255);
    arc(0, 0, diam+sw, diam+sw, angle, angle+angleDots);
    angle += angleDots + angleSpace; 
  }
  fill(0);
  ellipse(0, 0, diam, diam);
}
