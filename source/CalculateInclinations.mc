using Toybox.Application;
using Toybox.System;

(:glance)
class CalculateInclinations{
    var pitch, roll, inclination;
    var xAccel, yAccel, zAccel;
    var color, alphaColor;
    var alphaSafe;
    function calculate() {
        var sensorInfo = Sensor.getInfo();
        if (sensorInfo has :accel && sensorInfo.accel != null) {
            var accel = sensorInfo.accel;
            xAccel = accel[0];
            yAccel = accel[1];
            zAccel = accel[2];
        }
        else{
            //test inputs
            xAccel = -921;
            yAccel = -37;
            zAccel = -305;
        }
        var pitchRad = Math.atan2(yAccel, Math.sqrt(Math.pow(xAccel, 2) + Math.pow(zAccel, 2)));
        var rollRad = Math.atan2(-xAccel, zAccel);
        var inclinationRad = Math.atan(Math.sqrt(Math.pow(Math.tan(pitchRad), 2) + Math.pow(Math.tan(rollRad), 2)));
        pitch = Math.toDegrees(pitchRad);
        roll = Math.toDegrees(rollRad);
        inclination = Math.toDegrees(inclinationRad);
        alphaSafe = isAlphaSafe();
        setColor();
    }

    function isAlphaSafe() {
        var alphaAngle = Application.Properties.getValue("alphaAngle") == null ? 50 : Application.Properties.getValue("alphaAngle");
        if(inclination < alphaAngle){
            return true;
        }
        else{
            return false;
        }
    }

    function setColor(){
        if(inclination < 25){
            color = Graphics.COLOR_GREEN;
        }
        else if(inclination < 30){
            color = Graphics.COLOR_YELLOW;
        }
        else if(inclination < 50){
            color = Graphics.COLOR_RED;
        }
        else{
            color = Graphics.COLOR_YELLOW;
        }
        
        if(alphaSafe){
            alphaColor = Graphics.COLOR_GREEN;
        }
        else{
            alphaColor = Graphics.COLOR_RED;
        }
    }
}