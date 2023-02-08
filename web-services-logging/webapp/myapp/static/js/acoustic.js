const preStringData = JSON.parse(document.getElementById('logfile-data').textContent)
const logfileData = JSON.parse(preStringData)
const collection = document.getElementsByClassName("view-button");

var overlayContents = document.getElementById("logfile-contents");

console.log(collection);
console.log(preStringData);
console.log(logfileData);

// Source: https://stackoverflow.com/questions/36921947/read-a-server-side-file-using-javascript
function loadFile(filePath) {
    var result = null;
    var xmlhttp = new XMLHttpRequest();
    xmlhttp.open("GET", filePath, false);
    xmlhttp.send();

    if (xmlhttp.status == 200) {
        result = xmlhttp.responseText;
    }

    return result;
}

function addClickHandler(viewButton) {
    const logfilePath = logfileData[viewButton.id]

    viewButton.addEventListener("click", function() {
        overlayContents.innerText = loadFile(logfilePath);
        
        overlayOn();
    });
}

for (var i = 0; i < collection.length; i++) {
    var viewButton = collection[i];
    const logfilePath = logfileData[viewButton.id]

    addClickHandler(viewButton);
}