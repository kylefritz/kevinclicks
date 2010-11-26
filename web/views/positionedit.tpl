<html>
 <head>
  <title>Mappings</title>
    <link rel="stylesheet" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.3/themes/base/jquery-ui.css" type="text/css" media="all" />
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js" type="text/javascript" ></script>
    <script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.4/jquery-ui.min.js" type="text/javascript" ></script>

    <script type="text/javascript">
    $(function(){
      $('#save').button().click(function(){
        $.post('/positionedit',{positionedit:$('textarea').val()},function(data){
          if(data!="OK"){
            alert('sorry, that didnt save');
          }else{
            window.location="/remote/position";
          }
        });
      })
    });
    </script>
    <style type="text/css">
    </style>
 </head>
<body>
<textarea name="positionedit" rows="10" cols="40">{{positionedit}}</textarea>
<br/>
<span id="save">save</span>
</body>
</html>