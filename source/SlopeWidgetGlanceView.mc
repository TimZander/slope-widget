using Toybox.WatchUi;
using Toybox.System;
using Toybox.Graphics;
using Toybox.Timer;

(:glance)
class SlopeWidgetGlanceView extends WatchUi.GlanceView {
    var degreeSymbol = StringUtil.utf8ArrayToString([0xC2,0xB0]);
    var alphaSymbol = StringUtil.utf8ArrayToString([0xce,0xb1]);
    hidden var _timer, _c;
    hidden var _centerX;
    hidden var _centerY;

    function initialize() {
        GlanceView.initialize();
    }

    function onShow() {
        _c = new CalculateInclinations();
        _timer = new Timer.Timer();
    	_timer.start(method(:timerCallback), 1000, true);
    }

    // Update the view
    function onUpdate(dc) {
        _c.calculate();
        var glanceAlphaText = alphaSymbol;
        if(!_c.alphaSafe){
            glanceAlphaText = "X"+glanceAlphaText;
        }
        //System.println( _c.inclination.format("%.1f"));
        dc.setColor(_c.color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            dc.getWidth() / 2, 
            dc.getHeight() / 2, 
            Graphics.FONT_GLANCE_NUMBER, 
            _c.inclination.format("%.1f") + degreeSymbol + " " + glanceAlphaText, 
            Graphics.TEXT_JUSTIFY_CENTER
        );
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
