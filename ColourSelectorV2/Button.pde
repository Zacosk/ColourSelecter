public class Button
{
  String imageName;
  PImage image;
  PVector position, size;
  public boolean hover;
  float timer;
  
  public Button(String text, PVector position, String imageName, PVector size)
  {
    this.position = position;
    this.imageName = imageName;
    
    this.image = loadImage(imageName + "Dark.png");
    this.image.resize((int)size.x, (int)size.y);
    this.size = size;
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
      text(imageName,mouseX + 17, mouseY+10);
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
  
  public void UpdateImg(boolean darkMode)
  {
    if (darkMode)
    {
      image = loadImage(imageName + "Dark.png");
    } else {
      image = loadImage(imageName + "Light.png");
    }
    image.resize((int)size.x, (int)size.y);
  }
}
