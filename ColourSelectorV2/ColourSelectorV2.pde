import java.awt.*;
import java.awt.datatransfer.*;
import java.awt.image.BufferedImage;
import java.awt.Rectangle;
import java.awt.MouseInfo;
import java.awt.Point;

//initialise screen shot variables
PImage shot;
Robot robot;
BufferedImage screenshot;
Rectangle r;

//initialise mouse variables
Point mouse;

void setup(){
  //initialise window settings
  size(300, 130);
  surface.setTitle("Pixel Colour Selector");
  surface.setResizable(true);
  surface.setAlwaysOnTop(true);
  
  //New screen shot variables
  try
  {
    robot = new Robot();
    shot = new PImage();
  } catch (AWTException e){
    throw new RuntimeException("Unable to Initialize", e);
  }
  
  captureScreenShot();
  rectMode(CENTER);

}
void draw(){
  captureScreenShot();
  
  
  
  //image(shot,0,0);
  //fill(shot.get(mouseX,mouseY));
  //rect(mouseX,mouseY,15,15);
  
  println("X:" + mouse.x + " Y:" + mouse.y);
  println(frameRate);
}

void captureScreenShot()
{
  mouse = MouseInfo.getPointerInfo().getLocation();
  
  r = new Rectangle(mouse.x-50, mouse.y-50, 100, 100);
  screenshot = robot.createScreenCapture(r);//new Rectangle(Toolkit.getDefaultToolkit().getScreenSize()));
  shot = new PImage(screenshot);
}

void keyPressed() {
  if (key == ' ') {
    fill(255, 0, 0);
    rect(50, 50, 200, 100);
  }
}
