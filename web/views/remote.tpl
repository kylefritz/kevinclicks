<html>
 <head>
  <title>Remote</title>
  <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js" type="text/javascript" ></script>
  <script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.4/jquery-ui.min.js" type="text/javascript" ></script>

  <script type="text/javascript">
	$(function(){
		
		$('a').click(function(e){
			e.preventDefault();
			$.post($(this).attr('href'));
		})
		$cmd=$('.cmd').hide();
		$('#togglecommands').toggle(function(){$cmd.show();},function(){$cmd.hide();})
	});
  </script>
	<style type="text/css">
		#matrix,#commands{
			float:left;
			margin-right:6px;
		}
		#commands{
			width:325px;
			margin:0;
			padding:0;
		}
		#commands li{
			display:inline-block;
			width:60px;
			padding:4px;
			margin:4px;
			border:1px solid black;
			background:white;
		}
		#commands li.unset{
			background:red;
			opacity:.4;
		}
	</style>
 </head>
 <body>
	<div id="intro">
		<big>Remote</big> <a href="/op/dg0">green on</a> |  <a href="/op/dg1">green off</a> | <a href="/op/dd">door</a>
	</div>
	
	<ul id="commands">
	%for cmd in allCommands:
		%haskey=keysOp.has_key(cmd)
		<li class="{{'set' if haskey else 'unset'}}">
			%if haskey:
			<a href="{{'/op/%s'%keysOp[cmd]}}">{{cmd}} </a> <span class="cmd">{{ ' %s'%keysOp[cmd]}}</span>
			%else:
				{{cmd}}
			%end
		</li>
	%end
	<span style="cursor:pointer" id="togglecommands" href="#togglecommands">toggle cmds</span>
	<div class="cmd">
			{{keysOp}}
	</div>
	</ul>
	

 </body>
</html>