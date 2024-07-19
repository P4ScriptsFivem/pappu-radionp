radioUI = false;
radioState = false;
maxValue = 0;
window.addEventListener('message', function(event) {
    ed = event.data;
    if (ed.action === "openRadio") {
		maxValue = Number(ed.max);
		radioUI = true;
		$("#mainDiv").show().css({bottom: "-40%", position:'absolute', display:'flex'}).animate({bottom: "-5%"}, 800, function() {});
		document.getElementById("mainDivText").innerHTML = "VOLUME: " + ed.volume;
	} else if (ed.action === "closeRadio") {
		radioUI = false;
		$("#mainDiv").show().css({bottom: "-5%", position:'absolute', display:'flex'}).animate({bottom: "-40%"}, 800, function() {});
	} else if (ed.action === "updateVolume") {
		document.getElementById("mainDivText").innerHTML = `VOLUME: ` + ed.volume;
	}
	document.onkeyup = function(data) {
		if (data.which == 27 && radioUI) {
            radioUI = false;
			$("#mainDiv").show().css({bottom: "-5%", position:'absolute', display:'flex'}).animate({bottom: "-40%"}, 800, function() {});
			var xhr = new XMLHttpRequest();
			xhr.open("POST", `https://pappu-radionp/callback`, true);
			xhr.setRequestHeader('Content-Type', 'application/json');
			xhr.send(JSON.stringify({action: "nuiFocus"}));
		}
	}
});

document.addEventListener("keypress", function(event){
	if (radioUI && radioState) {
		var keyName = event.key;
		if (keyName === "Enter") {
			var xhr = new XMLHttpRequest();
			xhr.open("POST", `https://pappu-radionp/callback`, true);
			xhr.setRequestHeader('Content-Type', 'application/json');
			xhr.send(JSON.stringify({action: "joinRadio", channel: Number(document.getElementById("MDRadioFreq").value)}));
		}
	}
});

function clFunc(name1, name2, name3) {
	if (name1 === "clickOnOff") {
		if (radioState) {
			radioState = false;
			document.getElementById("mainDivOnOff").classList.remove("mainDivOn");
			document.getElementById("mainDivOnOff").classList.add("mainDivOff");
			document.getElementById("mainDivOnOff").innerHTML="<h4>OFF</h4>";
			document.getElementById("mainDivScreen").innerHTML=`<h4 style="font-size: 1.3vw;">POWERED OFF</h4>`;
			var xhr = new XMLHttpRequest();
			xhr.open("POST", `https://pappu-radionp/callback`, true);
			xhr.setRequestHeader('Content-Type', 'application/json');
			xhr.send(JSON.stringify({action: "powerOff"}));
		} else {
			radioState = true;
			document.getElementById("mainDivOnOff").classList.add("mainDivOn");
			document.getElementById("mainDivOnOff").classList.remove("mainDivOff");
			document.getElementById("mainDivOnOff").innerHTML="<h4>ON</h4>";
			document.getElementById("mainDivScreen").innerHTML=`<h4 style="font-size: 1vw;">POWERED ON</h4><div id="MDSInputDiv"><input type="number" placeholder="000.0" id="MDRadioFreq" onkeydown="return event.keyCode !== 69" min="1" max="100.0" oninput="checkValue(this);"><h4 style="font-size: 2vw;">MHZ</h4></div>`;
			document.getElementById("MDRadioFreq").max = maxValue;
		}
	} else if (name1 === "volumeDown") {
		var xhr = new XMLHttpRequest();
		xhr.open("POST", `https://pappu-radionp/callback`, true);
		xhr.setRequestHeader('Content-Type', 'application/json');
		xhr.send(JSON.stringify({action: "volumeDown"}));
	} else if (name1 === "volumeUp") {
		var xhr = new XMLHttpRequest();
		xhr.open("POST", `https://pappu-radionp/callback`, true);
		xhr.setRequestHeader('Content-Type', 'application/json');
		xhr.send(JSON.stringify({action: "volumeUp"}));
	}
}

function int(value) {
    return parseInt(value);
}

// this checks the value and updates it on the control, if needed
function checkValue(sender) {
    let min = sender.min;
    let max = sender.max;
    let value = int(sender.value);
    if (value > max) {
        sender.value = min;
    } else if (value < min) {
        sender.value = max;
    }
}