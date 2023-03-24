public class Button
{
  String popupText;
  PImage image;
  PVector position;
  public boolean hover;
  float timer;
  
  public Button(String text, PVector position, String imageName)
  {
    this.position = position;
    this.popupText = text;
    
    this.image = loadImage(imageName + ".png");
    this.image.resize(50, 50);
  }
  
  public void Run()
  {
    Draw();
    CheckHover();
    PopupTimer();
  }
  
  public void Draw()
  {
    push();
    translate(position.x, position.y);
    imageMode(CENTER);
    if (hover)
    {
      tint(180);
    }
    image(image, 0, 0);
    pop();
  }
  
  public void PopupTimer()
  {
    if (!hover)
    {
      timer = 0;
      return;
    } else {
      timer += 1;
    }
    if (timer >= 120)
    {
      textAlign(RIGHT);
      fill(0);
      textSize(20);
      text(popupText,position.x - 30, position.y);
    }
  }
  
  public void ResetPosition(PVector position)
  {
    this.position = position;
  }
  
  public void CheckHover()
  {
    hover = false;
    if (mouseX <= (position.x) + 25 && mouseX >= (position.x) - 25)
    {
      if (mouseY <= (position.y) + 25 && mouseY >= (position.y) - 25)
      {
        hover = true;
      }
    }
  }
}
