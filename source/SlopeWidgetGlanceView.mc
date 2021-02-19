using Toybox.WatchUi;
using Toybox.Timer;

(:glance)
class SlopeWidgetGlanceView extends WatchUi.GlanceView {

    hidden var _timer;
    var degreeSymbol = StringUtil.utf8ArrayToString([0xC2,0xB0]);
    hidden var _centerX;
    hidden var _centerY;
    hidden var _c;

    function initialize() {
        GlanceView.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        _centerX = dc.getWidth() / 2;
        _centerY = dc.getHeight() / 2;
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
        _c = new CalculateInclinations();
        _timer = new Timer.Timer();
    	_timer.start(method(:timerCallback), 1000, true);
    }

    // Update the view
    function onUpdate(dc) {
        _c.calculate();
        dc.drawText(5, 5, Graphics.FONT_GLANCE, "incl: " + _c.inclination.format("%.1f") + degreeSymbol, Graphics.TEXT_JUSTIFY_VCENTER);
        GlanceView.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
        _timer.stop();
    }

    function timerCallback() {
    	requestUpdate();
	}
}