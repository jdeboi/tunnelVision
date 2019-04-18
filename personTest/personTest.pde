
KSkeleton skel;

Person person;

void setup() {
  size(800, 800);

  skel = new KSkeleton();
  person = new Person( 0, 0, width/4, height, 0);
}

void draw() {
  background(255);
  if ((frameCount%10) == 0) { 
    
    
   
    
  }
   person.update(skel);
  skel.move();
  person.display(60, 3);
  skel.display();
}
