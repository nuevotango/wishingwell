
$("#invoice").hide();
$("#peer").hide();
$("#paymentsuccess").hide();
$("#peerqrcode").hide();
$("#payqrcode").hide();
$("#edit").hide();
$("#done").hide();
$(".coin").hide();
$("#step2").hide();
$("#step3").hide();

window.onload = function() {

	getWishCount();

	$( "#wish" ).keyup(function() {
		var len = $("#wish").val().length;
		$("#charcount").text(len+"/140");
	});

	$("#next").click(function(){
		if ($("#wish").val().length == 0) {
			alert("Wish cannot be empty");
			return;
		}
		$("#next").hide();
		$("#wishtext").text($("#wish").val());
		$("#wish").hide();
		$("#wishtext").show();
		$("#edit").show();
		$("#charcount").hide();
		$("#step2").show();
		$(".coin").show();
	});

	$("#edit").click(function(){
		$("#edit").hide();
		$("#wishtext").hide();
		$("#wish").show();
		$("#done").show();
		$("#charcount").show();
	});

	$("#done").click(function (){
		$("#edit").show();
		$("#done").hide();
		$("#wish").hide();
		$("#wishtext").text($("#wish").val());
		$("#wishtext").show();
		$("#charcount").hide();
	});

	$("#done").click(function (){
		$("#edit").show();
		$("#done").hide();
		$("#wish").hide();
		$("#wishtext").text($("#wish").val());
		$("#wishtext").show();
		$("#charcount").hide();
	});

	$("#submitemail").click(function (){
		var email = $("#email").val();
		if (!isEmail(email)){
			alert("Please enter a valid email");
			return
		}
		$.getJSON("/wishes/update_email?email="+email, function(data) {
			$("#submitemail").hide();
	    	$("#email").hide();
	    	$("#emailreceived").text("I'll be in touch!");
		});
	});


	setupCoins();


	function isEmail(email) {
			var regex = /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/;
			return regex.test(email);
	}

	function getWishCount(){
		$.getJSON("/wishes/get_count", function(data) {
	    	count = data["count"];
	    	$("#wishesreceived").text("#"+count+ " wishes received")
		});
	}

    function setupCoins(){
        var coins = $(".coin")
        for(var i = 0; i < coins.length; i++) {
            var denomination = coins[i].id;
            coins[i].onclick = function() {
                {generateInvoice(this.id)}
            }
        }
    }

	function generateInvoice(coin) {
		$("#step3").show();
		var wish = $("#wish").val();
		//TODO:configure URL according to environment 
		url = "/wishes/create_invoice?wish="+wish+"&coin="+coin;
		var values = [];

		convertCoinToBitcoin(coin);

		$.getJSON( url, function( data ) {
		  $.each( data, function( key, val ) {
		    values.push(val);
		  });			 
		  showinvoice(values);
			  checkpayment();
		});
	}

	function convertCoinToBitcoin(coin){
		$(".coin").hide();
		$("#"+coin).show();
		$("#"+coin).prop("onclick", null);
		$("#"+coin).css("margin-left","12%");
		$("#"+coin).css("margin-top","970px");

		$("#"+coin).css("zoom","28%");
		$.getJSON("/wishes/convert_coin_to_bitcoins?coin="+coin, function(data) {
	    	var bitcoins = String((parseFloat(data["bitcoins"]))/100000000);
	    	$("#bitcoins").text("is equivalent to "+bitcoins+" test Bitcoins");
	    });
	}

	function showinvoice(values){
		$('#invoice').val(values[0]);
		$('#peer').val(values[1]);
		$('#invoice').prop("readonly", true);
		$('#invoice').show();
		$('#peer').prop("readonly", true);
		$('#peer').show();
		$('#payqrcode').qrcode({width: 150,height: 150,text: values[0]});
		$('#peerqrcode').qrcode({width: 150,height: 150,text: values[1]});
		$('#invoicelabel').text("Invoice:");
		$('#peerlabel').text("Peer:");
		$("#peerqrcode").show();
		$("#payqrcode").show();
		$("#lightningwallet").text("Need a Lightning Network wallet?");
	}

	function checkpayment(){
		var wish = $("#wish").val()
		url = "/wishes/check_payment?wish="+wish
	   	$.getJSON(url, function(data) {
	    	if (data["settled"] == true){
	    		$("#paymentsuccess").show();
	    		$("#payflow").hide();
	    		$.get("/wishes/save_wish");
	    	}
	    	else{
	    		setTimeout(checkpayment,1000);
	    	}
		});
	}
}