import logging,string,sys
from logging.handlers import RotatingFileHandler, SMTPHandler
import smtplib
import email.MIMEMultipart
import email.MIMEText

def getLogger(appname):
  if(sys.platform=='darwin'):
    LOGFILE=r'%s.log'%appname #mac
  else:
    LOGFILE=r'C:\Remote\ArduinoRemote.git\%s.log'%appname #kevin's install is there

  # Set up logging
  log = logging.getLogger(appname)
  log.setLevel(logging.DEBUG)
  filehander=RotatingFileHandler(LOGFILE, maxBytes=2*10**6, backupCount=5)
  filehander.setFormatter(logging.Formatter("%(asctime)s %(levelname)s > %(message)s"))
  console = logging.StreamHandler()
  console.setFormatter(logging.Formatter("%(asctime)s > %(message)s"))
  log.addHandler(console)
  log.addHandler(filehander)
  log.info("starting up %s!!"%appname)
  
  #switch out exception handling
  oldEx=log.exception
  def newEx(msg):
    oldEx(msg)
    contents="couldn't read log"
    try:
      with open(LOGFILE,'r') as fp:
        contents=string.join(fp.readlines(),'\n')
    except:
      pass
    sendgmail("arduino_remote_worker exception %s"%sys.exc_info()[0],contents)
  
  log.exception=newEx
  
  return log

TO = "kyle.p.fritz@gmail.com"
FROM = "email.robot@simplicitysignals.com"
PWD = "robotpassword1984"

def sendgmail(subject,body,EMAIL_TO=TO,EMAIL_USER=FROM,EMAIL_PWD=PWD):
  msg = email.MIMEMultipart.MIMEMultipart()
  
  msg['From'] = EMAIL_USER
  msg['To'] = EMAIL_TO
  msg['Subject'] = subject
  
  msg.attach(email.MIMEText.MIMEText(body))
  
  mailServer = smtplib.SMTP("smtp.gmail.com", 587)
  mailServer.ehlo()
  mailServer.starttls()
  mailServer.ehlo()
  mailServer.login(EMAIL_USER, EMAIL_PWD)
  mailServer.sendmail(EMAIL_USER, EMAIL_TO, msg.as_string())
  mailServer.close()

	
    
ALL_COMMANDS="""power   
star    
ticker  
square  
livetv  
info    
zoom    
back    
next    
dirUp   
dirDown 
dirLeft 
dirRight
moxi    
replay  
skip    
ok      
play    
rewind  
fastfwrd
Pause   
Record  
Stop    
Mute    
Jump    
VolUp   
VolDown 
ChUp    
ChDown  
One     
Two     
Three   
Four    
Five    
Six     
Seven   
Eight   
Nine    
Clear   
Zero    
Enter"""