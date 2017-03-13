define([
    'base/js/namespace'
], function(
    Jupyter
) {
    function load_ipython_extension() {

        var import_all = function () {
            Jupyter.notebook.insert_cell_above('code', 0).set_text('' + 
            'import numpy as np\n' + 
            'import pandas as pd\n' + 
            'pd.options.display.html.table_schema = True\n' + 
            'import matplotlib.pyplot as plt\n' +
            'import matplotlib as mpl\n' +
            '%pylab inline\n' +
            'import seaborn as sns\n' +
            'import re\n' +
            'from collections import Counter, defaultdict\n' +
            'from operator import itemgetter\n' +
            'from joblib import Parallel, delayed\n' +
            'from tqdm import tqdm, tqdm_notebook\n' +
            'from IPython.display import display\n' +
            'import os\n' +
            'import datetime');
        };

        var action = {
            icon: 'fa-rocket', // a font-awesome class used on buttons, etc
            help    : 'Import all the libs :D',
            help_index : 'zz',
            handler : import_all
        };
        var prefix = 'py_default_imports';
        var action_name = 'import python libs';

        var full_action_name = Jupyter.actions.register(action, action_name, prefix);
        Jupyter.toolbar.add_buttons_group([full_action_name]);
    }

    return {
        load_ipython_extension: load_ipython_extension
    };
});
