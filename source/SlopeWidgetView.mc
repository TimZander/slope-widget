using Toybox.WatchUi;
using Toybox.Timer;

class SlopeWidgetView extends WatchUi.View {

    var debugLabel, pitchLabel, rollLabel, inclinationLabel, alphaLabel;
    hidden var timer;
    var degreeSymbol = StringUtil.utf8ArrayToString([0xC2,0xB0]);
    var alphaSymbol = StringUtil.utf8ArrayToString([0xce,0xb1]);
    var flatConstant = 2;
    hidden var _c;
    hidden var _app;
    hidden var _paused;
    hidden var _inclinationFont = Graphics.FONT_NUMBER_THAI_HOT;

    function initialize() {
        _app = Application.getApp();
        _paused = false;
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
        if(!_paused) { 
            _c.calculate();
        }

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

            if (_c.noData) {
                drawTitle(dc);
                drawNoData(dc);
            }
            else {
                if(_app.getProperty("showComponentAngles") == null ? false : _app.getProperty("showComponentAngles"))
                {
                    drawHold(dc);
                    drawPitch(dc);
                    drawRoll(dc);
                    drawFlat(dc);
                }
                else 
                {
                    drawTitle(dc);
                    drawInclination(dc);
                    drawAlpha(dc);
                    drawHold(dc);
                }
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

    function setPause() {
        if(_app.getProperty("enableHold") == null ? false : _app.getProperty("enableHold")) {
            _paused = !_paused;
        } else {
            _paused = false;
        }
    }

    (:buttonDevice)
    function drawHold(dc) {
        if(_app.getProperty("enableHold") == null ? false : _app.getProperty("enableHold")) {
            //highlight the hold button
            var arcColor = _paused == true ? Graphics.COLOR_GREEN : Graphics.COLOR_RED;
            dc.setColor(arcColor, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(10);
            dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, dc.getWidth()/2, Graphics.ARC_COUNTER_CLOCKWISE, 197, 215);
        }
    }

    (:touchDevice)
    function drawHold(dc) {
    }

    function drawAlpha(dc) {
        if(_app.getProperty("showAlpha") == null ? true : _app.getProperty("showAlpha")){
            var alphaFont = Graphics.FONT_LARGE;
            var locY = (dc.getHeight() / 2) + (Graphics.getFontHeight(_inclinationFont) / 4) + (Graphics.getFontHeight(alphaFont) / 4);                
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

    function drawNoData(dc) {
        var text;
        if(dc.getWidth() >= 240) {
            text = "Error getting \naccelerometer data";
        }
        else {
            text = "Error getting \naccelerometer \ndata";
        }
        var noDataText = new WatchUi.Text(
            {
                :text=>text, 
                :color=>Graphics.COLOR_WHITE,
                :font=>Graphics.FONT_MEDIUM,
                :locX=>WatchUi.LAYOUT_HALIGN_CENTER,
                :locY=>WatchUi.LAYOUT_VALIGN_CENTER
            }
        );
        noDataText.draw(dc);
    }

    function drawTitle(dc) {
        var titleText = new WatchUi.Text(
            {
                :text=>"SLOPE ANGLE", 
                :font=>Graphics.FONT_SMALL,
                :locX=>WatchUi.LAYOUT_HALIGN_CENTER,
                :locY=>10
            }
        );
        titleText.draw(dc);
    }

    function drawInclination(dc) {
        var inclinationText = new WatchUi.Text(
            {
                :text=>_c.inclination.format("%.1f") + degreeSymbol, 
                :color=>_c.color,
                :font=>_inclinationFont,
                :locX=>WatchUi.LAYOUT_HALIGN_CENTER,
                :locY=>WatchUi.LAYOUT_VALIGN_CENTER
            }
        );
        inclinationText.draw(dc);
    }

    function drawPitch(dc) {
        var vAlign = WatchUi.LAYOUT_VALIGN_BOTTOM;
        if(_c.pitch < 0){
            vAlign = WatchUi.LAYOUT_VALIGN_TOP;
        }
        var pitchText = new WatchUi.Text(
            {
                :text=>_c.pitch.abs().format("%.1f") + degreeSymbol,
                :color=>_c.pitchColor,
                :font=>Graphics.FONT_NUMBER_MEDIUM,
                :locX=>WatchUi.LAYOUT_HALIGN_CENTER,
                :locY=>vAlign
            }
        );
        if(_c.pitch.abs() > flatConstant){
            pitchText.draw(dc);
        }
    }

    function drawRoll(dc) {
        var hAlign = WatchUi.LAYOUT_HALIGN_LEFT;
        if(_c.rollNormalized < 0){
            hAlign = WatchUi.LAYOUT_HALIGN_RIGHT;
        }
        var rollText = new WatchUi.Text(
            {
                :text=>_c.rollNormalized.abs().format("%.1f") + degreeSymbol,
                :color=>_c.rollColor,
                :font=>Graphics.FONT_NUMBER_MEDIUM,
                :locX=>hAlign,
                :locY=>WatchUi.LAYOUT_VALIGN_CENTER
            }
        );

        if(_c.rollNormalized.abs() > flatConstant){
            rollText.draw(dc);
        }
    }

    function drawFlat(dc) {
        if(_c.rollNormalized.abs() < flatConstant && _c.pitch.abs() < flatConstant)
        {
            var flatText = new WatchUi.Text(
                {
                    :text=>"LEVEL",
                    :color=>Graphics.COLOR_WHITE,
                    :font=>Graphics.FONT_MEDIUM,
                    :locX=>WatchUi.LAYOUT_HALIGN_CENTER,
                    :locY=>WatchUi.LAYOUT_VALIGN_CENTER
                }
            );

            flatText.draw(dc);
        }
    }

}
