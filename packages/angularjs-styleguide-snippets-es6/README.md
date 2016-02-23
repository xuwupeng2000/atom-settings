# angularjs-styleguide-snippets package

A set of AngularJS snippets based on John Papa's style guide in es6.

### Snippets

You can use the following snippets in JavaScript.

##### ngmodule
```
(() => {
    'use strict';

    /**
     * @ngdoc module
     * @name ${1:module}
     * @requires ${2:dependencies}
     * @description
     *
     * The `${1:module}` ${4:description}.
     *
     */
    angular
        .module('${1:module}', [
            '${2:dependencies}'
        ]);
})();
```

##### ngcontroller
```
(() => {
    'use strict';

    /**
     * @ngdoc function
     * @name ${2:controller}
     * @module ${1:module}
     * @description
     *
     * The `${2:controller}` controller ${5:description}.
     *
     */
    angular
        .module('${1:module}')
        .controller('${2:controller}', ${2:controller});

    ${2:controller}.$inject = ['${3:dependencies}'];

    function ${2:controller}(${3:dependencies}) {
        'ngInject';
        const self = this;

        activate();

        ///////////

        function activate() {

        }
    }
})();
```

##### ngfactory
```
(() => {
    'use strict';

    /**
     * @ngdoc service
     * @name ${2:factory}
     * @module ${1:module}
     * @requires ${3:dependencies}
     * @description
     *
     * The `${2:factory}` factory ${5:description}.
     *
     */
    angular
        .module('${1:module}')
        .factory('${2:factory}', ${2:factory});

    ${2:factory}.$inject = ['${3:dependencies}'];

    function ${2:factory}(${3:dependencies}) {
        'ngInject';
        const service = {
            ${4:function}: ${4:function}
        };

        return service;

        ///////////

        function ${4:function}() {

        }
    }
})();
```

##### ngdirective
```
(() => {
    'use strict';

    /**
     * @ngdoc directive
     * @name ${2:directive}
     * @module ${1:module}
     * @restrict ${3:EA}
     * @description
     *
     * The `${2:directive}` directive ${7:description}.
     *
     */
    angular
        .module('${1:module}')
        .directive('${2:directive}', ${2:directive});

    function ${2:directive}() {
        const directive = {
            restrict: '${3:EA}',
            templateUrl: '${4:templateUrl}',
            scope: {
            },
            link: link,
            controller: ${5:Controller},
            controllerAs: 'self',
            bindToController: true
        };

        return directive;

        ///////////

        function link(scope, el, attr, ctrl) {

        }
    }

    ${5:Controller}.$inject = ['${6:dependencies}'];

    function ${5:Controller}(${6:dependencies}) {
        'ngInject';
        const self = this;

        activate();

        ///////////

        function activate() {

        }
    }
})();
```

##### ngservice
```
(() => {
    'use strict';

    /**
     * @ngdoc service
     * @name ${2:service}
     * @module ${1:module}
     * @requires ${3:dependencies}
     * @description
     *
     * The `${2:service}` service ${5:description}.
     *
     */
    angular
        .module('${1:module}')
        .service('${2:service}', ${2:service});

    ${2:service}.$inject = ['${3:dependencies}'];

    function ${2:service}(${3:dependencies}) {
        'ngInject';
        this.${4:function} = ${4:function};

        function ${4:function}() {

        }
    }
})();
```

##### ngfilter
```
(() => {
    'use strict';

    angular
        .module('${1:module}')
        .filter('${2:filter}', ${2:filter});

    function ${2:filter}() {
        return ${2:filter}Filter

        ///////////

        function ${2:filter}Filter(${3:params}) {
            return ${3:params};
        }
    }
})();
```
