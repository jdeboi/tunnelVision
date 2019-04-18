class KJoint {

  int type;
  PVector positionj;
  boolean isBoinkers = false;
  int boinkersTime = 0;

  int timeOut = 5000;

  PVector lastSanePosition;

  KJoint(int type) {
    this.type = type;
    positionj = new PVector (width/2, height/2);
    lastSanePosition = new PVector (width/2, height/2);
  }

  PVector getPosition() {
    return positionj;
  }

  void display() {
    noStroke();
    fill(0, 255, 0, 100);
    rectMode(CENTER);
    rect(positionj.x, positionj.y, 30, 30);
  }
  
  void move() {
    positionj.x = mouseX;
    positionj.y = mouseY;
  }

  void move2() {
    if (!isBoinkers) {
      lastSanePosition.x += random(-sp, sp);
      lastSanePosition.y += random(-sp, sp);
      positionj.x = lastSanePosition.x;
      positionj.y = lastSanePosition.y;
    } else {
      positionj.x += random(-sp, sp);
      positionj.y += random(-sp, sp);
    }

    if (!isBoinkers) {
      if (int(random(100)) == 0) {
        println("boinkers");
        isBoinkers = true;
        positionj.x += 300;
        positionj.y += 300;
        boinkersTime = millis();
      }
    } else {
      if (millis() - boinkersTime > timeOut) {
        isBoinkers = false;
      }
    }
  }
}
