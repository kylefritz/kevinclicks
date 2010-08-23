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
const int MuxD=2  ;

const int inh[]={8,9};
const int a[]={2,5};
const int b[]={3,6};
const int c[]={4,7};

const int buttonPin = 2;
const int ledPin =  13;
const int doorPin =  10;
const int greenOn =  11;
const int greenOff =  12;

void setup() {
  //set 2:11 pins to output
  for(int i=2;i<12;i++)
  {
      pinMode(i, OUTPUT);
  }
  pinMode(ledPin, OUTPUT);
  
  //setupdoor
  digitalWrite(doorPin, HIGH);
  
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
      }else if(func=='d'){
        /*device*/
        processDevice();
      }else{
        printf("Remote> don't know function: %s\n\r",func);
        blinkLight(2);
      }
    }
}

void holdRowOrColumn(){
  while(Serial.available() < 2)
    true;//block till get what we need

  char m=Serial.read();
  char row[]="row";
  char col[]="col";
  char dev[]="dev";
  char * label;
  int mux;
  if(m=='r'){
      mux = MuxR;
      label= row;
  }else if(m=='c'){
      mux = MuxC;    
      label= col;
  }else{
      mux = MuxD;
      label= dev;
  }
  
  int which = parse(Serial.read());
  
  printf("Remote> hold %s: %d\n\r",label,which);
  setMuxCh(mux,which);
  setMuxInh(mux,false);
}

void processDevice(){
  //0=g1,1=g2,2=b1,3=b2,4=d
  while(Serial.available() < 1)
    true;//block till get what we need  
  char which = Serial.read();
 
  if(which=='g'){
    while(Serial.available() < 1) true;
    boolean on= Serial.read()=='1';
    greenThing(on);
    printf("green thing: %s\n\r",on?"on":"off");
    
  }else if(which=='d'){
    openDoor();
  }else{
    printf("don't know %c\n\r",which);
  }
}

void pressRowColumn(){
  while(Serial.available() < 2)
    true;//block till get what we need
  char cRow = Serial.read();
  char cCol = Serial.read();
  int iRow=parse(cRow);
  int iCol=parse(cCol);
  //printRemoteCommand(iRow,iCol);
  printf("(%c,%c)> row:%d col:%d\n\r",cRow,cCol,iRow,iCol);
  setLight(true);
  pressKey(iRow,iCol);
  setLight(false);
}

int parse(char in){
  char zero='0';
  char A='A';
  char a='a';
  if(in >=a) //'a' -> 97
    return in-a;
  if(in>=A)//'A' -> 65
    return in-A;
    
  return in-zero;//'0' -> 48
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

void openDoor(){
  digitalWrite(doorPin,LOW);
  delay(1000);
  digitalWrite(doorPin,HIGH);
}

void greenThing(boolean on){
  int pin=on?greenOn:greenOff;

  digitalWrite(pin,HIGH);
  delay(1000);
  digitalWrite(pin,LOW);

}

void pressKey(int row,int col){

  if(row==5 && col!=4)
  {
    printf("row 5 probably doesn't support col %d",col);
    //return;
  }else if(row>5)
  {
    printf("row %d not supported",row);
    return;    
  }
  
  inhibitAll();//just in case, inhibit all
  
  setMuxCh(MuxR,row);
  setMuxCh(MuxC,col);
  
  setMuxInh(MuxR,false);//mux 1 on
  setMuxInh(MuxC,false);//mux 2 on
    
  delay(250);//250ms down
    
  inhibitAll();
}

void pressDevice(int which){
  
  inhibitAll();//just in case, inhibit all
  
  setMuxCh(MuxD,which);
  
  delay(100);//250ms down
    
  inhibitAll();  
}

void inhibitAll(){
  
  //shut all down
  setMuxInh(MuxR,true);
  setMuxInh(MuxC,true);
  //setMuxCh(MuxD,7);//ch7 is N/C
}

void setMuxCh(int mux,int ch){
  int A=(ch>>0)%2;
  int B=(ch>>1)%2;
  int C=(ch>>2)%2;

  printf("   ");
  if(mux==MuxR){
      printf("row");
  }else if(mux==MuxC){
      printf("col");
  }else{
      printf("dev");
  }
  
  printf(" [C,B,A]\n\r");
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

void setMuxInh(int mux,boolean inhibit){
    digitalWrite(inh[mux], inhibit);
}


