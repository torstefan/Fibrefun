

$(document).ready(function() { 
	var pVar ={message:"Hei, eg e ett bilde"};
	function showMessage(evt){
		var img_id = $(this).attr('id');
		var id_regx = /(up_)|(down_)/;		
		var row_id = img_id.replace(id_regx, '');		
		alert(row_id);
		
		$('<input>').attr({
		    type: 'hidden',		    
		    name: 'row_id',
		    value: row_id
		}).appendTo("#update_amount");
		
	}
	
	function submitRow(evt){
		var img_id = $(this).attr('id');
		var id_regx = /(up_)|(down_)/;		
		var row_id = img_id.replace(id_regx, '');		
				
		$('<input>').attr({
		    type: 	'hidden',		    
		    name: 	'row_id',
		    value: 	img_id
		}).appendTo("#update_amount");
		
		$( "#update_amount" ).submit();
		
	}
	$.tablesorter.defaults.widgets = ['zebra'];
	 
    // call the tablesorter plugin 
    $("#table1").tablesorter({ 
        // sort on the first column , second and and fith column, order asc 
        sortList: [[0,0],[1,0],[4,0]] 
    });
    
    // $(".up").bind('mouseover',pVar,showMessage);
    
    $( ".up" ).bind('click',submitRow);
    $( ".down" ).bind('click',submitRow);
    
    
    $("#info_msg").fadeOut(5000);
    
    
}); 

  