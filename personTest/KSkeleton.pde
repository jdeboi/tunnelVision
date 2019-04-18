int sp = 15;

class KSkeleton {

  boolean isTracked = true;
  KJoint[] joints;

  KSkeleton() {
    joints = new KJoint[1];
    joints[0] = new KJoint(0);
  }

  boolean isTracked() {
    return true;
  }

  KJoint [] getJoints()  {
    return joints;
  }
  
  void move() {
    joints[0].move();
  }
  
  void display() {
 
    
    joints[0].display();
  }

}
