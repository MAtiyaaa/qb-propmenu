// I know nothing about js, thanks google
document.addEventListener('DOMContentLoaded', function() {
    populateSelectors();
    setupLiveUpdateListeners();

    window.addEventListener('message', function(event) {
        if (event.data.action === 'openMenu') {
            document.getElementById('menu').style.display = 'block';
        }
    });

    document.getElementById('spawnPropButton').addEventListener('click', function() {
        sendPropData();
        sendLiveUpdate();
    });
    document.getElementById('closeMenuButton').addEventListener('click', function() {
        const propDetails = {
            prop: document.getElementById('propSelect').value,
            boneId: parseInt(document.getElementById('boneSelect').value, 10),
            positionOffset: getPositionOffset(),
            rotation: getRotation()
        };
    
        const propDetailsString = `Prop: ${propDetails.prop}, Bone ID: ${propDetails.boneId}, Position Offset: ${JSON.stringify(propDetails.positionOffset)}, Rotation: ${JSON.stringify(propDetails.rotation)}`;

        copyToClipboard(propDetailsString);
    
        fetch(`https://${GetParentResourceName()}/notifyClipboard`, { method: 'POST' });
    
        fetch(`https://${GetParentResourceName()}/closeMenu`, { method: 'POST' });
        document.getElementById('menu').style.display = 'none';
    });   
});

function copyToClipboard(text) {
    var textArea = document.createElement("textarea");
    textArea.value = text;

    textArea.style.position = "fixed";
    textArea.style.left = "-9999px";
    textArea.style.top = "-9999px";

    document.body.appendChild(textArea);
    textArea.focus();
    textArea.select();

    try {
        var successful = document.execCommand('copy');
        if (successful) {
            console.log('Copied to clipboard successfully.');
        } else {
            throw new Error('Failed to copy');
        }
    } catch (err) {
        console.error('Fallback: Could not copy text: ', err);
    }

    document.body.removeChild(textArea);
}


function sendPropData() {
    const prop = document.getElementById('propSelect').value;
    const boneIndex = parseInt(document.getElementById('boneSelect').value, 10);
    const positionOffset = getPositionOffset();
    const rotation = getRotation();

    fetch(`https://${GetParentResourceName()}/spawnProp`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify({ prop, boneIndex, positionOffset, rotation })
    }).then(response => response.json()).then(data => {
        console.log("Spawn prop response:", data);
    }).catch(error => console.error("Error spawning prop:", error));

}


function getPositionOffset() {
    return {
        x: parseFloat(document.getElementById('positionX').value),
        y: parseFloat(document.getElementById('positionY').value),
        z: parseFloat(document.getElementById('positionZ').value)
    };
}




function sendLiveUpdate() {
    const prop = document.getElementById('propSelect').value;
    const boneIndex = parseInt(document.getElementById('boneSelect').value, 10);
    const positionOffset = getPositionOffset();
    const rotation = getRotation();

    fetch(`https://${GetParentResourceName()}/updateProp`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify({ prop, boneIndex, positionOffset, rotation })
    });
}

function setupLiveUpdateListeners() {
    const updateElements = document.querySelectorAll('.coordinate-control input');
    updateElements.forEach(element => {
        element.addEventListener('change', sendLiveUpdate);
    });
}

function getRotation() {
    return {
        x: parseFloat(document.getElementById('rotationX').value),
        y: parseFloat(document.getElementById('rotationY').value),
        z: parseFloat(document.getElementById('rotationZ').value)
    };
}

function degreesToRadians(degrees) {
    return degrees * Math.PI / 180;
}


function adjustCoordinate(coordinateId, adjustment) {
    var input = document.getElementById(coordinateId);
    if (input) {
        input.value = parseFloat(input.value) + adjustment;
    }
}

window.onload = function() {
    const menuElement = document.getElementById('menu');
    menuElement.addEventListener('mousedown', function(e) {
        let offsetX = e.clientX - parseInt(window.getComputedStyle(this).left);
        let offsetY = e.clientY - parseInt(window.getComputedStyle(this).top);

        function mouseMoveHandler(e) {
            menuElement.style.top = (e.clientY - offsetY) + 'px';
            menuElement.style.left = (e.clientX - offsetX) + 'px';
        }

        function reset() {
            window.removeEventListener('mousemove', mouseMoveHandler);
            window.removeEventListener('mouseup', reset);
        }

        window.addEventListener('mousemove', mouseMoveHandler);
        window.addEventListener('mouseup', reset);
    });
};

$(document).ready(function() {
    $('#propSelect').select2({ width: '300px' });
    $('#boneSelect').select2({ width: '300px' }); 
});

window.addEventListener('message', function(event) {
    if (event.data.action === "copyToClipboard") {
        const propDetails = event.data.propDetails;
        const propDetailsString = `Prop: ${propDetails.prop}, Bone ID: ${propDetails.boneId}, Position Offset: ${JSON.stringify(propDetails.positionOffset)}, Rotation: ${JSON.stringify(propDetails.rotation)}`;
        navigator.clipboard.writeText(propDetailsString).then(function() {
            console.log('Copied to clipboard successfully.');
        }, function(err) {
            console.error('Could not copy text: ', err);
        });
    }
});

function populateSelectors() {
    const propSelect = document.getElementById('propSelect');
        const boneSelect = document.getElementById('boneSelect');
    boneIndices.forEach(function(index) {
        let option = new Option("Bone " + index, index);
        boneSelect.appendChild(option);
    });
    propNames.forEach(function(prop) {
        let option = new Option(prop, prop);
        propSelect.appendChild(option);
    });
}
