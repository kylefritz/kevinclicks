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
		
    $('#space').resizable();
		$('#resize').button().toggle(
			function(){$('#commands li').resizable({ disabled: false });},
			function(){$('#commands li').resizable({ disabled: true });}
			);


		$savedlg=$('#namedlg').dialog({autoOpen: false, modal:true});
		var $savebtn=$('#namedlg span').button().click(function(){
			var positions={};
			$space=$('#space');
			var all={}
			all['space-height']=$space.height();
			
			$('#commands li').each(function(){
				$this=$(this);
				var d={};
				var pos=$this.position();
				d.left=pos.left;
				d.top=pos.top;
				d.height=$this.height();
				d.width=$this.width();
				d.color=$this.css('background');
				all[$this.text()]=d;

			})

			var name=$('#namedlg input').val();
			$.post('/positions/'+name,{position:JSON.stringify(all)});
			$savedlg.dialog('close');
		});

		$('#savepositions').button().click(function(){
			if($('select').val()!=null)
				$('#namedlg input').val($('select').val());
			$savedlg.dialog('open');
			});
		
			var loadPostion=function(){
				$.get('/positions/'+$('select').val(),function(data){
				  dict=JSON.parse(data);
				  
				  //set space size
				  $('#space').height(dict['space-height']);
				  delete dict['space-height'];
          
					var $sp=$('#commands').empty();
					for(key in dict){
					  var el=dict[key];
					  var li=$('<li/>').text(key)
					  .height(el.height)
					  .width(el.width)
					  .css('top',el.top)
					  .css('left',el.left)
					  .css('background',el.color);
					  $sp.append(li)
					}
					
					//wire draggable
					$('#commands li').draggable().click(function(){
      		  $('.selected').removeClass('selected');
      		  btn=this;
      		  $(this).addClass('selected');
      		});
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
	<div id="space">
		
	</div>

	<ul id="commands">
	</ul>
	
	<div style="float:left;">
	<div id="picker"></div>
	</div>
	
	<div style="clear:both;float:left">
		<span id="resize">toggle resize</span>
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