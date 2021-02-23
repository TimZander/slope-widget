using Toybox.WatchUi;
using Toybox.Timer;

class SlopeWidgetView extends WatchUi.View {

    var debugLabel, pitchLabel, rollLabel, inclinationLabel, alphaLabel;
    hidden var timer;
    var degreeSymbol = StringUtil.utf8ArrayToString([0xC2,0xB0]);
    var alphaSymbol = StringUtil.utf8ArrayToString([0xce,0xb1]);
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
            inclinationLabel = View.findDrawableById("inclination");
            alphaLabel = View.findDrawableById("alpha");
        }
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
        _c = new CalculateInclinations();
        timer = new Timer.Timer();
        var refreshFrequency = _app.getProperty("refreshFrequency") == null ? 1000 : _app.getProperty("refreshFrequency");
    	timer.start(method(:timerCallback), refreshFrequency, true);
    }

    // Update the view
    function onUpdate(dc) {
        _c.calculate();
        //System.println("x: " + _c.xAccel + ", y: " + _c.yAccel + ", z: " + _c.zAccel);
        //System.println("pitch: " + _c.pitch.format("%.1f") + ", roll: " + _c.roll.format("%.1f"));
        if(_app.getProperty("showDebug") == null ? true : _app.getProperty("showDebug")){
            debugLabel.setText("x: " + _c.xAccel + ", y: " + _c.yAccel + ", z: " + _c.zAccel);
            pitchLabel.setText("pitch: " + _c.pitch.format("%.1f") + degreeSymbol);
            rollLabel.setText("roll: " + _c.roll.format("%.1f") + degreeSymbol);
            inclinationLabel.setText("incl: " + _c.inclination.format("%.1f") + degreeSymbol);
            inclinationLabel.setText(_c.inclination.format("%.1f") + degreeSymbol);
            if(_app.getProperty("changeColor") == null ? true : _app.getProperty("changeColor")){
                inclinationLabel.setColor(_c.color);
            }
            alphaLabel.setColor(_c.alphaColor);
            alphaLabel.setText(alphaSymbol + ">");
            View.onUpdate(dc);
        }
        else {
            dc.clear();
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight());
            
            var titleText = new WatchUi.Text(
                {
                    :text=>"Slope Angle", 
                    :font=>Graphics.FONT_MEDIUM,
                    :locX=>WatchUi.LAYOUT_HALIGN_CENTER,
                    :locY=>10
                }
            );
            titleText.draw(dc);

            var inclinationFont = Graphics.FONT_NUMBER_THAI_HOT;
            var inclinationText = new WatchUi.Text(
                {
                    :text=>_c.inclination.format("%.1f") + degreeSymbol, 
                    :color=>_c.color,
                    :font=>inclinationFont,
                    :locX=>WatchUi.LAYOUT_HALIGN_CENTER,
                    :locY=>WatchUi.LAYOUT_VALIGN_CENTER
                }
            );
            inclinationText.draw(dc);

            if(_app.getProperty("showAlpha") == null ? true : _app.getProperty("showAlpha")){
                var alphaFont = Graphics.FONT_LARGE;
                var locY = (dc.getHeight() / 2) + (Graphics.getFontHeight(inclinationFont) / 4) + (Graphics.getFontHeight(alphaFont) / 4);                
                var alphaText = new WatchUi.Text(
                    {
                        :text=>alphaSymbol + ">", 
                        :color=>_c.alphaColor,
                        :font=>alphaFont,
                        :locX=>WatchUi.LAYOUT_HALIGN_CENTER,
                        :locY=>locY
                    }
                );
                alphaText.draw(dc);
            }
        }
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
