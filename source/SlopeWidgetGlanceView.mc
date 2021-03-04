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
    hidden var _app;

    function initialize() {
        _app = Application.getApp();
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
        if (_c.noData) {
            drawNoData(dc);
        }
        else {
            drawInclination(dc);
            drawAlpha(dc);
        }
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

    function drawAlpha(dc) {
        if(_app.getProperty("showAlpha") == null ? true : _app.getProperty("showAlpha")){
            var alphaText = new WatchUi.Text(
                {
                    :text=>alphaSymbol + ">", 
                    :color=>_c.alphaColor,
                    :font=>Graphics.FONT_MEDIUM,
                    :locX=>WatchUi.LAYOUT_HALIGN_START + 60,
                    :locY=>WatchUi.LAYOUT_VALIGN_CENTER
                }
            );
            alphaText.draw(dc);
        }
    }

    function drawNoData(dc) {
        var text;
        if(dc.getWidth() >= 151) {
            text = "Accelerometer error";
        }
        else {
            text = "Accel error";
        }
        var noDataText = new WatchUi.Text(
            {
                :text=>text, 
                :color=>Graphics.COLOR_WHITE,
                :font=>Graphics.FONT_GLANCE,
                :locX=>WatchUi.LAYOUT_HALIGN_CENTER,
                :locY=>WatchUi.LAYOUT_VALIGN_CENTER
            }
        );
        noDataText.draw(dc);
    }

    function drawInclination(dc) {
        var inclinationText = new WatchUi.Text(
            {
                :text=>_c.inclination.format("%.1f") + degreeSymbol, 
                :color=>_c.color,
                :font=>Graphics.FONT_GLANCE_NUMBER,
                :locX=>WatchUi.LAYOUT_HALIGN_LEFT,
                :locY=>WatchUi.LAYOUT_VALIGN_CENTER
            }
        );
        inclinationText.draw(dc);
    }

}
