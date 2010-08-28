<html>
 <head>
  <title>Remote</title>
  <link rel="stylesheet" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.3/themes/base/jquery-ui.css" type="text/css" media="all" /> 
  <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js" type="text/javascript" ></script>
  <script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.4/jquery-ui.min.js" type="text/javascript" ></script>

  <script type="text/javascript">
	$(function(){
		
		$('a').click(function(e){
			e.preventDefault();
			$.post($(this).attr('href'));
		})
		$cmd=$('.cmd').hide();
		$('#togglecommands').button().toggle(function(){$cmd.show();},function(){$cmd.hide();})
		
		$('#space').resizable({maxWidth: 300,minWidth: 300})
		
		$('#commands li').resizable().draggable();
		
		
		$('#savepositions').button().click(function(){
			//show save positions dialog
		});
		
		$('#load').button();
		
		/*
		.droppable({
		accept: '#commands li',
		activeClass: 'ui-state-hover',
		hoverClass: 'ui-state-active',
		});
		*/
	});
  </script>
	<style type="text/css">
		#space,#matrix,#commands{
			float:left;
			margin-right:6px;
		}
		#space{
			width:300px;
			height:450px;
			border:1px solid black;
			margin:10px;
			background:#DEF;
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
			-moz-border-radius:10px;
			-webkit-border-radius:10px;
			border-radius: 15px;
		}
		#commands li.unset{
			background:red;
			opacity:.4;
		}
	</style>
 </head>
 <body>
	<div id="intro">
		<big>Position Keys</big> 
	</div>
	<div id="space">
		
	</div>

	<ul id="commands">
	%for cmd in allCommands:
		%haskey=keysOp.has_key(cmd)
		<li id="{{cmd}}" class="{{'set' if haskey else 'unset'}}">
			%if haskey:
			<a href="{{'/op/%s'%keysOp[cmd]}}">{{cmd}} </a> <span class="cmd">{{ ' %s'%keysOp[cmd]}}</span>
			%else:
				{{cmd}}
			%end
		</li>
	%end
		<li id="g0"><a href="/op/dg0">green 0</a></>
		<li id="g1"><a href="/op/dg1">green 1</a></>
		<li id="d"><a href="/op/dd">door</a></>	

	</ul>
	<div style="clear:both;float:left">
		<span id="togglecommands">toggle cmds</span>
		<pre class="cmd"><!--raw key dictionary-->{{keysOp}}</pre>
		<span id="savepositions">save positions</span>
		<select style="font-size:1.4em">
			%for mapping in mappings:
				<option>{{mapping}}</option>
			%end
		</select>
		<span id="load">load</span>
	</div>
 </body>
</html>