<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en" >
<head>
	<!-- 
	don't know why but setting the doc-type screws up element sizing :(
	-->
	<meta http-equiv="Content-type" content="text/html; charset=utf-8">
  <title>Remote</title>
	<meta name="viewport" content="width=device-width, minimum-scale=1, maximum-scale=1">
	
	<link rel="icon" type="image/ico" href="/static/head-16.gif" />
	<link rel="apple-touch-icon" href="/static/head-114.png" />
	
  <link rel="stylesheet" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.3/themes/base/jquery-ui.css" type="text/css" media="all" /> 
  <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js" type="text/javascript" ></script>
  <script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.4/jquery-ui.min.js" type="text/javascript" ></script>
  <script type="text/javascript">
	invert = function(c){
		var p = /rgb\((\d{1,3}),\s*(\d{1,3}),\s*(\d{1,3})\)/.exec(c);
		return "rgb("+(255-parseInt(p [1]))+", "+(255-parseInt(p [2]))+", "+(255-parseInt(p [3]))+")";
	}
  
	toggleInvert = function($t){
		var color = $t.css("background-color");
		var i = invert(color);
		$t.css("background-color",i);
		$t.css("color",color);
	}
	$(function(){
		
		var loadPostion=function(){
			$.get('/positions',function(data){
			  dict=JSON.parse(data);
			  
			  //set space size
			  $('#space').height(dict['space-height']);
			  delete dict['space-height'];
        
        //get keys and positions
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
				  li.css('color',invert(li.css('background-color')));
				}
				
				//wire action
				$('#commands li').click(function(){
				  var $this=$(this);
				  toggleInvert($(this));
				  var url='/key/'+$this.text();
				  console.log(url);
				  $.post(url,null,function(){toggleInvert($this);});
    		});
    		
			});				
		};
		
		loadPostion();
		
	});
  </script>
	<style type="text/css">
		body{margin:0;background:#555;font-family:arial;font-size:14pt;}
		a:visited,a{color:white;}
		#space{
			width:300px;
			height:450px;
			margin-bottom:40px;
		}
		#commands{
			-moz-user-select: none;
			-webkit-user-select: none;	
			margin:0px;
			height:0px;
			padding:0;
		}
		#commands li:hover{opacity:.5;cursor:pointer;}
		#commands li{
			-moz-user-select: none;
            -webkit-user-select: none;
			text-align: center;
			display:inline-block;
			width:60px;
			padding:4px;
			margin:4px;
			border:3px solid black;
			background:white;
			-moz-border-radius:10px;
			-webkit-border-radius:10px;
			border-radius: 15px;
			position:absolute;
			-moz-user-select:none;
			-webkit-user-select:none;
		}
		#aux{
			width:300px;
		}
	</style>
 </head>
 <body>
	<div id="space">
		<ul id="commands">
		</ul>
	</div>
<hl/>
	<div id="aux">
		<a href="/remote/position">edit position</a>
	</div>
 </body>
</html>