using Toybox.WatchUi;
using Toybox.Timer;

class SlopeWidgetView extends WatchUi.View {

    var debugLabel;
    var pitchLabel;
    var rollLabel;
    var inclinationLabel;
    hidden var timer;
    var degreeSymbol = StringUtil.utf8ArrayToString([0xC2,0xB0]);
    hidden var xAccel;
    hidden var yAccel;
    hidden var zAccel;
    hidden var pitch;
    hidden var roll;
    hidden var inclination;

    function initialize() {
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.MainLayout(dc));
        debugLabel = View.findDrawableById("debugOutput");
        pitchLabel = View.findDrawableById("pitch");
        rollLabel = View.findDrawableById("roll");
        inclinationLabel = View.findDrawableById("inclination");
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
        timer = new Timer.Timer();
    	timer.start(method(:timerCallback), 1000, true);
    }

    // Update the view
    function onUpdate(dc) {
        calculate();
        //System.println("x: " + xAccel + ", y: " + yAccel + ", z: " + zAccel);
        //System.println("pitch: " + pitch.format("%.1f") + ", roll: " + roll.format("%.1f"));
        debugLabel.setText("x: " + xAccel + ", y: " + yAccel + ", z: " + zAccel);
        pitchLabel.setText("pitch: " + pitch.format("%.1f") + degreeSymbol);
        rollLabel.setText("roll: " + roll.format("%.1f") + degreeSymbol);
        inclinationLabel.setText("incl: " + inclination.format("%.2f") + degreeSymbol);
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
        timer.stop();
    }

    function timerCallback() {
    	requestUpdate();
	}

    function calculate() {
        var sensorInfo = Sensor.getInfo();
        if (sensorInfo has :accel && sensorInfo.accel != null) {
            var accel = sensorInfo.accel;
            xAccel = accel[0];
            yAccel = accel[1];
            zAccel = accel[2];
            //test inputs
            //xAccel = -921;
            //yAccel = -37;
            //zAccel = -305;
            
            var pitchRad = Math.atan2(yAccel, Math.sqrt(Math.pow(xAccel, 2) + Math.pow(zAccel, 2)));
            var rollRad = Math.atan2(-xAccel, zAccel);
            var inclinationRad = Math.atan(Math.sqrt(Math.pow(Math.tan(pitchRad), 2) + Math.pow(Math.tan(rollRad), 2)));
            pitch = Math.toDegrees(pitchRad);
            roll = Math.toDegrees(rollRad);
            inclination = Math.toDegrees(inclinationRad);
            sanitizeAngles();
        }
    }

    function sanitizeAngles(){
        if(pitch > -180 and pitch < 0){
            pitch = -pitch;
        }
        // while(pitch < -90){
        //     pitch = pitch + 90;
        // }
        while(roll > 90){
            roll = roll - 180;
        }
        while(roll < -90){
            roll = roll + 180;
        }
        if(roll > -180 and roll < 0){
            roll = -roll;
        }
    }
}
