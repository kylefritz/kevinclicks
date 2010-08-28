#!/usr/bin/env python 
import serial,time,sys,util
from redis import Redis

class worker():
  def __init__(self,redis,log,misslimit,getserial):
    self.serial=None
    self.redis=redis
    self.misses=0
    self.getserial=getserial
    self.misslimit=misslimit
    self.log=log
    
  def handleItem(self,op):
    if self.serial is None:
      self.log.debug("opened serial port")
      self.serial= self.getserial();
      #todo: don't return multi line output, so don't have to wait on timeout
      time.sleep(1.5) #hang on for serial port to start up
    
    try:
      self.serial.write(op)
      line=self.serial.readline(eol='\r') #all responses are 1 line ending in \n\r now
      self.log.debug("%s> %s"% (op,line ))
    except SerialException:
      log.exception('exception> SerialException')
      self.redis.lpush("arduino:remote-command",op) #push op back on
      self.serial=None #let serial get remade next time
    
  def work(self):
    while True:
      item=self.redis.blpop("arduino:remote-command",timeout=5);
      if item:
        self.misses=0
        self.handleItem(item[1]) #0=> key
      else:
        self.misses+=1
        if self.misses > self.misslimit and self.serial:
          self.serial.close()
          self.serial=None
          log.debug("closed serial port")

if __name__ =="__main__":
  log=util.getLogger('arduino_remote_worker')
  #set up redis
  rdb=Redis()
  
  #setup serial
  PORT="COM4" #kevin is on COM4
  MISSLIMIT=10000000000
  getserial=lambda: serial.Serial(port=PORT, baudrate=115200,timeout=2)
    
  while True:
    try:
      worker(rdb,log,MISSLIMIT,getserial).work()
    except KeyboardInterrupt:
      log.info("KeyboardInterrupt>>shutdown")
      break
    except:
      log.exception('exception> oh boy')