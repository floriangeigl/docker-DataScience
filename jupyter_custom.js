// auto-save
define([
    'base/js/namespace',
    'base/js/events'
    ],
    function(IPython, events) {
        events.on("notebook_loaded.Notebook",
        	function () {
  				IPython.notebook.set_autosave_interval(3600000); //1H
			}
  		);
        //may include additional events.on() statements
    }
);
