import nub.primitives.*;
import nub.core.*;
import nub.processing.*;
Scene scene;
PShader shader;
PShape sphere,can;
color co1, c1, c2, c3;
Node l1, l2, l3, o1;
void setup() {
  colorMode(RGB,1);
  co1 = color(1, 0.941, 0.490);
  c1 = color(0.368, 0.054, 0.101);
  size(500,500,P3D);
  can = createCan(100, 200, 32);
  sphere = createShape(SPHERE, 50);
  sphere.setFill(c1);
  sphere.setStroke(c1);
  scene = new Scene(this);
  scene.setRadius(500);
  scene.fit();
  o1 = new Node(scene,can);
  l1 = new Node(scene,sphere);
  l1.setPickingThreshold(0);
  l1.randomize();/*
  l2 = new Node(scene,sphere);
  l2.setPickingThreshold(0);
  l2.randomize();*/
  shader = loadShader("lightingfrag.glsl","lightingvert.glsl");
}
void draw(){
  background(0);
  //Vector l1Position = scene.eye().location(l1.position());
  shader(shader);
  pointLight(red(c1), green(c1), blue(c1), l1.position().x(), l1.position().y(), l1.position().z());
//  pointLight(255, 255, 255, l2.position().x(), l2.position().y(), l2.position().z());
  scene.render();
  //shader.set("c1l1",c1);
}

PShape createCan(float r, float h, int detail) {
  textureMode(NORMAL);
  PShape sh = createShape();
  sh.beginShape(QUAD_STRIP);
  sh.fill(co1);
  sh.noStroke();
  for (int i = 0; i <= detail; i++) {
    float angle = TWO_PI / detail;
    float x = sin(i * angle);
    float z = cos(i * angle);
    float u = float(i) / detail;
    sh.normal(x, 0, z);
    sh.vertex(x * r, -h/2, z * r, u, 0);
    sh.vertex(x * r, +h/2, z * r, u, 1);    
  }
  sh.endShape(); 
  return sh;
}
void mouseClicked(){
  scene.cast();
}
void mouseDragged(){
  if(scene.trackedNode() == null){
    scene.spin(scene.eye());
  }else{
    scene.translate();
  } 
}
