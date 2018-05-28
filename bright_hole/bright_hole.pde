//タイトル名：brighthole(blackholeの派生版みたいないめーじ)
import processing.video.*;
import ddf.minim.*;

//変数の定義
Minim minim;
AudioSample player;
Capture video;
//星のための配列
fallingball[] ball = new fallingball[5];
//衝突判定のための変数
float [] check = new float [5];
//右上のスコアの初期化
int score=0;
//スコアの色
float [] scorec = new float [4];

//クラスの定義
class fallingball{
  //x座標、y座標、半径、速度
  float x,y,r,velocity;
  //色を表示するための変数を格納
  float aa,bb,cc,dd;
  
  fallingball(float _x, float _y, float _r,float _velocity){
    x=_x;
    y=_y;
    r=_r;
    velocity = _velocity;
    aa = random(255);
  bb = random(255);
  cc = random(255);
  dd = 80;
  }
  
  
  //更新したときの星の位置をずらす
  void update(){
  y+=velocity;
  if(y == 600){ y = 0;
  x = int(random(width));
  r = int(random(30,50));
  }
}
//星の表示
 void display(){
   ellipse(x,y,r,r);
 }
//条件を満たしたときに色と半径と位置が変わった星を出現させる
 void reset(){
   y = 0;
  x = int(random(width));
  r = int(random(30,50));
  aa = random(255);
  bb = random(255);
  cc = random(255);
 }
 //星を小さくする
 void small(float a){
   r = r-5;
   //半径０以下になったら半径０＝消滅する
   if(r<0) r = 0;
   if(x>a){x = x-3;}else{
     x = x+3;
   }
 }
 //ブライトホール：強力モード
 void stronghole(float a){
   if(x>a){x = x-6;}else{
     x = x+6;
 }
 }
}

//初期設定
void setup() {
  size(640, 480);
  background(0,0,0);
  video = new Capture(this, width, height);
  video.start();  
  noStroke();
  smooth();
  frameRate(60);
  minim = new Minim(this);
  player = minim.loadSample("sound3.mp3");
  
  //星の生成
  for(int i=0;i<5;i++){
  ball[i] = new fallingball(random(width),0,random(30,50),3*(i+1));
  }
  

}

void draw() {
  if(score==0){
  fill(255);
  }else{
    fill(scorec[0],scorec[1],scorec[2],scorec[3]);
  }
  textSize(100);
  //スコアの桁数が増えたときに左に寄せて文字が端で切れることを阻止
  if(score<10){
    text(score,530,100);
  }else if(score<100){
    text(score,480,100);
  }else if(score<1000){
    text(score,430,100);
  }else if(score<10000){
    text(score,380,100);
  }
  
  //カメラON
  if (video.available()) {
    video.read();
    int brightestX = 0; 
    int brightestY = 0; 
    float brightestValue = 0; 
  
    video.loadPixels();
    int index = 0;
    //一番明るい座標を得る
    for (int y = 0; y < video.height; y++) {
      for (int x = 0; x < video.width; x++) {
       float pixelBrightness = brightness(video.pixels[index]);
        if (pixelBrightness > brightestValue) {
          brightestValue = pixelBrightness;
          brightestY = y;
          brightestX = x;
        }
        index++;
      }
    }
    fadeout();
    //白色でもっとも明るい色のところを塗る
    fill(255, 255,255,50);
    if(key=='b'){
      fill(255,0,0,50);
    }
    ellipse(brightestX, brightestY, 150, 150);
    
    //星の更新、描画
    for(int i=0;i<5;i++){
      fill(ball[i].aa,ball[i].bb,ball[i].cc,50);
      ball[i].update();
      ball[i].display();
    }
    //
    for(int i=0;i<5;i++){
      check[i]=smash(brightestX, brightestY,ball[i].x,ball[i].y,ball[i].r);
    }
    
    for(int i=0;i<5;i++){
      //衝突中は星を小さくしつつ音をならす。
      if(check[i]==2){
      ball[i].small(brightestX);
      player.trigger();
      
      //星のリセットと点数の色をかえる
      if(ball[i].r == 0){
     ball[i].reset();
     scorec[0] =ball[i].aa;
     scorec[1] = ball[i].bb;
     scorec[2] = ball[i].cc;
     scorec[3] = 50;
     score ++;
    }
    }
    }
    
    //bキーを押したときにブライトホールを強化する
  if(key=='b'){
    for(int i=0;i<5;i++){
     ball[i].stronghole(brightestX);;
     }
}
     
  }
  
}

//衝突判定用。衝突しているなら２を返す
float smash(float ax,float ay, float bx, float by,float r){
  float distance=0;
  float root= 0;
  distance = abs(150 - r);
  root = sqrt((bx-ax)*(bx-ax)+(by-ay)*(by-ay));
  //接触している判断した場合
  if(root<distance){
    return 2;
  }
  return 0;
}

//スコアリセット
void keyPressed(){
  if(key=='r'){
    score=0;
  }
}

//フェードアウト
void fadeout(){
  noStroke();
  fill(0,70);
  rect(0,0,width,height);
}