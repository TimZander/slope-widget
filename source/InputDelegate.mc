using Toybox.WatchUi;

class InputDelegate extends WatchUi.BehaviorDelegate {

    var callback;

    function initialize(c) {
        BehaviorDelegate.initialize();
        callback = c;
    }

    function onKey(keyEvent) {
        if(keyEvent.getKey() == WatchUi.KEY_DOWN) {
            callback.setPause();
        }
    }
}