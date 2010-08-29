import os

# Change working directory so relative paths (and template lookup) work again
os.chdir(os.path.dirname(__file__))

#include pwd
import sys
sys.path = [os.path.dirname(__file__)] + sys.path

# ... add or import your bottle app code here ...
from remoteserver import *
import bottle
app = bottle.app() #bottle.default_app()
myapp = StripPathMiddleware(app)

# Do NOT use bottle.run() with mod_wsgi
application = myapp
