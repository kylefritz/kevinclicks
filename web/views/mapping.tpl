<html>
 <head>
  <title>Mappings</title>
    <link rel="stylesheet" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.3/themes/base/jquery-ui.css" type="text/css" media="all" />
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js" type="text/javascript" ></script>
    <script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.4/jquery-ui.min.js" type="text/javascript" ></script>

    <script type="text/javascript">
    $(function(){
      $('#save').button().click(function(){
        $.post('/mapping',{mapping:$('textarea').val()},function(data){
          if(data!="OK"){
            alert('sorry, that didnt save');
          }
        });
      })
    });
    </script>
    <style type="text/css">
    </style>
 </head>
<body>
<textarea name="mapping" rows="10" cols="40">{{mapping}}</textarea>
<br/>
<span id="save">save</span>
</body>
</html>