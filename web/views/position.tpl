<html>
 <head>
  <title>Remote</title>
  <link rel="stylesheet" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.3/themes/base/jquery-ui.css" type="text/css" media="all" /> 
  <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js" type="text/javascript" ></script>
  <script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.4/jquery-ui.min.js" type="text/javascript" ></script>
  <script src="/static/json2.min.js" type="text/javascript" ></script>
 <script type="text/javascript" src="/static/farbtastic.js"></script>
 <link rel="stylesheet" href="/static/farbtastic.css" type="text/css" />  

  <script type="text/javascript">
	$(function(){
		
		var btn=null;
		
		$('#picker').farbtastic(function(color){
		  if(btn==null) return;
		  
		  btn.background=color;
		  $(btn).css('background',color);
		});

		$cmd=$('.cmd').hide();
		$('#togglecommands').button().toggle(function(){$cmd.show();},function(){$cmd.hide();})
		
		$('#commands li').draggable().click(function(){
		  $('.selected').removeClass('selected');
		  btn=this;
		  $(this).addClass('selected');
		});
		$('#resize').button().toggle(
			function(){$('#commands li').resizable({ disabled: false });},
			function(){$('#commands li').resizable({ disabled: true });}
			);


		$savedlg=$('#namedlg').dialog({autoOpen: false, modal:true});
		var $savebtn=$('#namedlg span').button().click(function(){
			var positions={};
			$space=$('#space');
			var sp=$space.position();
			$('#commands li').each(function(){
				$this=$(this);
				var pos=$this.position();
				positions[this.id]= (pos.left-sp.left)+","+(pos.top-sp.top)+","+$this.height()+","+$this.width();
				if(this.background){
				  //add in color
				  positions[this.id]+=","+this.background;
				}
			})
			positions['space']=$space.height()+","+320;//only set height
			var name=$('#namedlg input').val();
			$.post('/remote/position/'+name,{position:JSON.stringify(positions)})
			$savedlg.dialog('close')
		});

		$('#savepositions').button().click(function(){
			if($('select').val()!=null)
				$('#namedlg input').val($('select').val());
			$savedlg.dialog('open');
			});
		
			var loadPostion=function(){
				$.get('/remote/position/'+$('select').val(),function(data){
					var dict=JSON.parse(data);
					var sp=$('#space').position();
					for(key in dict){
						var $i=$('#'+key);
						var vals=dict[key].split(',').reverse(); //pop in reverse order

						$i.css('left',parseInt(vals.pop())+sp.left);
						$i.css('top',parseInt(vals.pop())+sp.top);
						$i.height(vals.pop());
						$i.width(vals.pop());

						if(vals.length>0){
						  //set color
						  $i.css('background',vals.pop());
						}
					}
				});
			};

			$('#load').button().click(loadPostion);
			
			if($('select').val()!=null)
				loadPostion();
		
	});
  </script>
	<style type="text/css">
	body{margin:0;padding:0;}
		#space,#matrix,#commands{
			float:left;
			margin-right:6px;
		}
		#space{
		  float:left;
			width:300px;
			height:450px;
			border:1px solid black;
			background:#DEF;
		}
		#commands{
		  float:left;
		  height:100px;
			width:175px;
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
			position:absolute;
			float:left;
		}
		#commands li.unset{
			background:red;
		}
		.ui-state-disabled{
			opacity:1;
		}
		#commands li.selected{
		  border:3px solid yellow;
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
			{{cmd}} <span class="cmd">{{ ' %s'%keysOp[cmd]}}</span>
			%else:
				{{cmd}}
			%end
		</li>
	%end
		<li id="g0">green 0 <span class="cmd">dg0</span></li>
		<li id="g1">green 1 <span class="cmd">dg1</span></li>
		<li id="d">door <span class="cmd">dd</span></li>	

	</ul>
	
	<div style="float:left;">
	<div id="picker"></div>
	</div>
	
	<div style="clear:both;float:left">
		<span id="resize">toggle resize</span>
		<span id="togglecommands">toggle cmds</span>
		<span id="savepositions">save positions</span>
		<select style="font-size:1.4em">
			%for mapping in mappings:
				<option>{{mapping}}</option>
			%end
		</select>
		<span id="load">load</span>
		<br/>
		<a href="/remote">try it out</a>
	</div>
	
	<div id="namedlg" style="display:none" title="Name your position">
		<input value="ooja" />
		<span>save</span>
	</div>
	
 </body>
</html>