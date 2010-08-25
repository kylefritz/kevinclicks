#!/usr/bin/env python 

import serial,logging,time,sys, emailrobot,string
from logging.handlers import RotatingFileHandler, SMTPHandler
from redis import Redis

class fakeSerial():
  def __init__(self,log):
    self.log=log
    log.debug('fake serial>>open')
  def write(self,op):
    log.debug('fake serial> %s'%op)
  def close(self):
    log.debug('fake serial<<close')
  
class worker():
  def __init__(self,redis,log,misslimit,getserial):
    self.serial=None
    self.redis=redis
    self.misses=0
    self.getserial=getserial
    self.misslimit=misslimit
    
  def handleItem(self,op):
    if self.serial is None:
      log.debug("opened serial port")
      self.serial= self.getserial();
      #todo: don't return multi line output, so don't have to wait on timeout
      time.sleep(1.5) #hang on for serial port to start up
      
    
    self.serial.write(op)
      
    log.debug("sent %s"%op)   
    self.redis.rpush("arduino:remote-command:sent",op);
    
  def work(self):
    while True:
      item=self.redis.blpop("arduino:remote-command",timeout=1);
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
  
  LOGFILE='worker.log'

  # Set up logging
  log = logging.getLogger('arduino_remote_worker')
  filehander=RotatingFileHandler(LOGFILE, maxBytes=2*10**6, backupCount=5)
  filehander.setFormatter(logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s"))
  console = logging.StreamHandler()
  console.setLevel(logging.DEBUG)
  
  log.addHandler(console)  
  log.addHandler(filehander)
  
  #set up redis
  rdb=Redis()
  
  #setup serial
  PORT="COM3"
  MISSLIMIT=10000000000
  if len(sys.argv) > 1 and sys.argv[1]=='fake':
    getserial=lambda: fakeSerial(log)
  else:
    getserial=lambda: serial.Serial(port=PORT, baudrate=9600,timeout=2)
  
  while True:
    try:
      worker(rdb,log,MISSLIMIT,getserial).work()
    except KeyboardInterrupt:
      break
    except:
      log.exception('exception> oh boy')
      contents="couldn't read log"
      try:
        with open(LOGFILE,'r') as fp:
          contents=string.join(fp.readlines(),'\n')
      except:
        pass
      emailrobot.sendgmail("arduino_remote_worker exception %s"%sys.exc_info()[0],contents)
  