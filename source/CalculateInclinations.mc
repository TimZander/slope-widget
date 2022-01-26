using Toybox.Application;
using Toybox.System;

(:glance)
class CalculateInclinations{
    var pitch, roll, inclination, rollNormalized;
    var xAccel, yAccel, zAccel;
    var color, alphaColor, rollColor, pitchColor;
    var alphaSafe;
    var noData;
    var greenAngle = 25;
    var yellowAngle = 30;
    var redAngle = 50;

    function calculate() {
        var sensorInfo = Sensor.getInfo();
        if (sensorInfo has :accel && sensorInfo.accel != null) {
            noData = false;
            var accel = sensorInfo.accel;
            xAccel = accel[0];
            yAccel = accel[1];
            zAccel = accel[2];
        }
        else{
            noData = true;
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

        if(roll > 90){
            rollNormalized = roll - 180;
        }
        else if(roll < -90){
            rollNormalized = roll + 180; 
        }
        else{
            rollNormalized = roll;
        }
        
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
        if(inclination < greenAngle){
            color = Graphics.COLOR_GREEN;
        }
        else if(inclination < yellowAngle){
            color = Graphics.COLOR_YELLOW;
        }
        else if(inclination < redAngle){
            color = Graphics.COLOR_RED;
        }
        else{
            color = Graphics.COLOR_YELLOW;
        }

        if(rollNormalized.abs() < greenAngle){
            rollColor = Graphics.COLOR_GREEN;
        }
        else if(rollNormalized.abs() < yellowAngle){
            rollColor = Graphics.COLOR_YELLOW;
        }
        else if(rollNormalized.abs() < redAngle){
            rollColor = Graphics.COLOR_RED;
        }
        else{
            rollColor = Graphics.COLOR_YELLOW;
        }

        if(pitch.abs() < greenAngle){
            pitchColor = Graphics.COLOR_GREEN;
        }
        else if(pitch.abs() < yellowAngle){
            pitchColor = Graphics.COLOR_YELLOW;
        }
        else if(pitch.abs() < redAngle){
            pitchColor = Graphics.COLOR_RED;
        }
        else{
            pitchColor = Graphics.COLOR_YELLOW;
        }


        if(alphaSafe){
            alphaColor = Graphics.COLOR_GREEN;
        }
        else{
            alphaColor = Graphics.COLOR_RED;
        }
    }
}