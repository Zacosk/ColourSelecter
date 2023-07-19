public class Button
{
  String popupText;
  PImage image;
  PVector position;
  public boolean hover;
  float timer;
  
  public Button(String text, PVector position, String imageName, PVector size)
  {
    this.position = position;
    this.popupText = text;
    
    this.image = loadImage(imageName + ".png");
    this.image.resize((int)size.x, (int)size.y);
  }
  
  public void Run()
  {
    Draw();
    CheckHover();
  }
  
  public void Draw()
  {
    push();
    translate(position.x, position.y);
    //imageMode(CENTER);
    if (hover)
    {
      tint(180);
    }
    image(image, 0, 0);
    pop();
  }
  
  //Popup with the name of the button if the user 
  //mouses over it for a set amount of time
  public void PopupTimer()
  {
    if (!hover)
    {
      timer = 0;
      return;
    } else {
      timer += 1;
    }
    if (timer >= 80)
    {
      //Background
      fill(255);
      rect(mouseX + 15, mouseY-5, 110, 20);
      //Popup Text
      fill(0);
      textAlign(LEFT);
      textSize(20);
      text(popupText,mouseX + 17, mouseY+10);
    }
  }
  
  public void ResetPosition(PVector position)
  {
    this.position = position;
  }
  
  public void CheckHover()
  {
    hover = false;
    if (mouseX <= (position.x) + (image.width) && mouseX >= (position.x))
    {
      if (mouseY <= (position.y) + (image.height) && mouseY >= (position.y))
      {
        hover = true;
      }
    }
  }
}
