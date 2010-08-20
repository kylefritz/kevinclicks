// we need fundamental FILE definitions and printf declarations
#include <stdio.h>

// create a FILE structure to reference our UART output function
static FILE uartout = {0} ;

// create a output function
// This works because Serial.write, although of type virtual, already exists.
static int uart_putchar (char c, FILE *stream)
{
    Serial.write(c) ;
    return 0 ;
}


const int MuxR=0;
const int MuxC=1;

const int inh[]={10,11};
const int a[]={3,6};
const int b[]={4,7};
const int c[]={5,8};
const int   t=9;

const int buttonPin = 2;
const int ledPin =  13;

void setup() {
  //set 2:11 pins to output
  for(int i=2;i<12;i++)
  {
      pinMode(i, OUTPUT);
  }
  pinMode(ledPin, OUTPUT);
  
  //inhibit mux
  inhibitAll();
  
  //start serial port at 9600 bps:
  Serial.begin(9600);
  //Enable printf
  //fill in the UART file descriptor with pointer to writer.
  fdev_setup_stream (&uartout, uart_putchar, NULL, _FDEV_SETUP_WRITE);

  //The uart is the standard output device STDOUT.
  stdout = &uartout ;
}

char func =0;


void loop() {
    if (Serial.available() > 0) {
    // get incoming byte:
      func = Serial.read();
      if(func=='r'){
        /* Momentary Connect Row-Col */
        pressRowColumn();
      }else if(func=='h'){
        /* HOLD */
        holdRowOrColumn();        
        blinkLight(5);
      }else if(func=='c'){
        /* CLEAR */
        inhibitAll();
        printf("Remote> clear\n\r");
        blinkLight(3);
      }else{
        printf("Remote> don't know function: %s\n\r",func);
        blinkLight(2);
      }
    }
}

void holdRowOrColumn(){
  while(Serial.available() < 2)
    true;//block till get what we need
  int mux = Serial.read() == 'r'?MuxR:MuxC;
  int which = Serial.read() -'a';
  
  setMuxCh(mux,which);
  
  if(which==9)
    setT(true);//transistor on
  else
    setMuxInh(mux,false);
    
  printf("Remote> hold %s: %d\n\r",mux==MuxR?"row":"col",which);
}

void pressRowColumn(){
  while(Serial.available() < 2)
    true;//block till get what we need
  char cRow = Serial.read();
  char cCol = Serial.read();    
  int iRow=cRow-'a';
  int iCol=cCol-'a';
  //printRemoteCommand(iRow,iCol);
  printf("(%c,%c)> row:%d col:%d\n\r",cRow,cCol,iRow,iCol);
  setLight(true);
  pressKey(iRow,iCol);
  setLight(false);
}

void printRemoteCommand(int row,int col)
{
  Serial.print("Remote> ");
  Serial.print("row: ");
  Serial.print(row, DEC);
  Serial.print(" col: ");
  Serial.println(col, DEC);       
  Serial.print("\n\r");
}

/*
0: [0, 0, 0, 0]
1: [0, 0, 0, 1]
2: [0, 0, 1, 0]
3: [0, 0, 1, 1]
4: [0, 1, 0, 0]
5: [0, 1, 0, 1]
6: [0, 1, 1, 0]
7: [0, 1, 1, 1]
8: [1, 0, 0, 0]
*/

void pressKey(int row,int col){

  inhibitAll();//just in case, inhibit all
  
  setMuxCh(MuxR,row);
  setMuxCh(MuxC,col);
  
  setMuxInh(MuxR,false);//mux 1 on
  if(col==9)
    setT(true);//transistor on
  else
    setMuxInh(MuxC,false);//mux 2 on
    
   delay(250);//250ms down
    
  inhibitAll();
}

void inhibitAll(){
  
  //shut all down
  setMuxInh(MuxR,true);
  setMuxInh(MuxC,true);
  setT(false);  
}

void setMuxCh(int mux,int ch){
  int A=(ch>>0)%2;
  int B=(ch>>1)%2;
  int C=(ch>>2)%2;
  
  printf("   %s [C,B,A]\n\r",mux==MuxR?"row":"col");
  printf("       [%d,%d,%d]\n\r",c[mux],b[mux],a[mux]);
  printf("       [%d,%d,%d]\n\r",C,B,A);
  
  digitalWrite(a[mux], A==1);
  digitalWrite(b[mux], B==1);
  digitalWrite(c[mux], C==1);
}

void blinkLight(int times)
{
  int lightOnMs=100;
  setLight(false);
  for(int i=0;i<times;i++)
  {
    setLight(true);
    delay(lightOnMs);
    setLight(false);
  }
}

void setLight(boolean on)
{
  digitalWrite(ledPin, on);
}

void setT(boolean on){
  digitalWrite(t, on);//transistor on
}

void setMuxInh(int mux,boolean inhibit){
    digitalWrite(inh[mux], inhibit);
}


boolean lastDown=false;

boolean buttonDown(){

  // read the state of the switch into a local variable:
  int reading = digitalRead(buttonPin);
  
  if(reading==HIGH){
    //button is down, check if first time in that state
    boolean isFirstDown= lastDown==false;
    lastDown=true;
    return isFirstDown;
  }else{
    lastDown=false;
    return false;
  }

}
