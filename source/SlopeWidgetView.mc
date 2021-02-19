using Toybox.WatchUi;
using Toybox.Timer;

class SlopeWidgetView extends WatchUi.View {

    var debugLabel;
    var pitchLabel;
    var rollLabel;
    var inclinationLabel;
    hidden var timer;
    var degreeSymbol = StringUtil.utf8ArrayToString([0xC2,0xB0]);
    hidden var _c;
    hidden var _app;

    function initialize() {
        _app = Application.getApp();
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        if(_app.getProperty("showDebug") == null ? true : _app.getProperty("showDebug")){
            setLayout(Rez.Layouts.DebugLayout(dc));
            debugLabel = View.findDrawableById("debugOutput");
            pitchLabel = View.findDrawableById("pitch");
            rollLabel = View.findDrawableById("roll");
        }
        else{
            setLayout(Rez.Layouts.MainLayout(dc));
        }
        inclinationLabel = View.findDrawableById("inclination");
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
        _c = new CalculateInclinations();
        timer = new Timer.Timer();
    	timer.start(method(:timerCallback), 1000, true);
    }

    // Update the view
    function onUpdate(dc) {
        _c.calculate();
        //System.println("x: " + xAccel + ", y: " + yAccel + ", z: " + zAccel);
        //System.println("pitch: " + pitch.format("%.1f") + ", roll: " + roll.format("%.1f"));
        if(_app.getProperty("showDebug") == null ? true : _app.getProperty("showDebug")){
            debugLabel.setText("x: " + _c.xAccel + ", y: " + _c.yAccel + ", z: " + _c.zAccel);
            pitchLabel.setText("pitch: " + _c.pitch.format("%.1f") + degreeSymbol);
            rollLabel.setText("roll: " + _c.roll.format("%.1f") + degreeSymbol);
        }
        inclinationLabel.setText("incl: " + _c.inclination.format("%.1f") + degreeSymbol);
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
}
