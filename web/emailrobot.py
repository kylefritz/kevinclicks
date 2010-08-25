# #
# #  robotSendEmail.py
# #  Created by Kyle Fritz on 2009-01-10.
# #  TO USE: should define EMAIL_TO, EMAIL_USER and EMAIL_PWD in django settings
# #


import smtplib
from email.MIMEMultipart import MIMEMultipart
from email.MIMEText import MIMEText

TO = "kyle.p.fritz@gmail.com"
FROM = "email.robot@simplicitysignals.com"
PWD = "robotpassword1984"

def sendgmail(subject,body,EMAIL_TO=TO,EMAIL_USER=FROM,EMAIL_PWD=PWD):
       msg = MIMEMultipart()
       
       msg['From'] = EMAIL_USER
       msg['To'] = EMAIL_TO
       msg['Subject'] = subject
       
       msg.attach(MIMEText(body))
       
       mailServer = smtplib.SMTP("smtp.gmail.com", 587)
       mailServer.ehlo()
       mailServer.starttls()
       mailServer.ehlo()
       mailServer.login(EMAIL_USER, EMAIL_PWD)
       mailServer.sendmail(EMAIL_USER, EMAIL_TO, msg.as_string())
       mailServer.close()
