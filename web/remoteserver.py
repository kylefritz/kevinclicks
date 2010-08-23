from bottle import send_file, redirect, abort, request, response, route, view, run
from redis import Redis
from datetime import datetime
import json


@route('/op/:op')#, method='POST')
def do_op(op):
	r=Redis()
    #r.rpush("arduino:remote-command",json.dumps({'op':op,'push-time':datetime.now().isoformat()}))
	r.rpush("arduino:remote-command",op)
		
	return 'OK: %s'%op

@route('/static/:filename')
def static_file(filename):
	send_file(filename, root='static')

@route('/remote/train')
@view('train')
def remote_train():
	return dict()

@route('/hello/template/:names')
@view('hello')
def remote_trainer(names):
	names = names.split(',')
	return dict(title='Hello World', names=names)
	
	
#auth	
@route('/hello/cookie')
def cookie():
	name = request.COOKIES.get('name', 'Stranger')
	response.headers['Content-Type'] = 'text/plain'
	return 'Hello, %s' % name

	
@route('/wrong/url')
def wrong():
	redirect("/right/url")

@route('/restricted')
def restricted():
	abort(401, "Sorry, access denied.")	

import bottle
bottle.debug(True)
run(host='localhost', port=8080)