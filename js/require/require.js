(function() {
    var loadHandlers = new Map();
    var libs = new Map();

    var loadScript = function(name) {
        var tag = document.createElement('script');
        tag.setAttribute('src', name + '.js');
        document.head.appendChild(tag);
    };

    var requireSingle = function(name) {
        return new Promise(function(resolve, reject) {
            var handlers, lib;

            lib = libs.get(name);
            console.log('lib:', name, lib);
            if (lib) {
                resolve(lib);
                return;
            }

            handlers = loadHandlers.get(name);
            console.log('handlers:', name, handlers);
            if (!handlers) {
                handlers = [];
                loadHandlers.set(name, handlers);
                loadScript(name);
            }

            handlers.push(resolve);
        });
    };

    var require = function() {
        var i,
            promises = [];

        for (i = 0; i < arguments.length; i++) {
            promises.push(requireSingle(arguments[0]));
        }

        return Promise.all(promises);
    };

    var provide = function(name, lib) {
        var handlers = loadHandlers.get(name);

        libs.set(name, lib);
        if (handlers) {
            handlers.forEach(function(h) {
                h(lib);
            });
        }
        loadHandlers.delete(name);
    };

    // Stolen from: http://www.html5rocks.com/en/tutorials/es6/promises/?redirect_from_locale=de
    var spawn = function(generator) {
        function continuer(verb, arg) {
            var result;
            try {
                result = generator[verb](arg);
            } catch (err) {
                return Promise.reject(err);
            }
            if (result.done) {
                return result.value;
            } else {
                return Promise.resolve(result.value).then(onFulfilled, onRejected);
            }
        }
        var onFulfilled = continuer.bind(continuer, "next");
        var onRejected = continuer.bind(continuer, "throw");
        return onFulfilled();
    };

    var inlineCallbacks = function(generatorFunc) {
        return function() {
            return spawn(generatorFunc.apply(null, arguments));
        };
    };

    window.require = require;
    window.provide = provide;
    window.inlineCallbacks = inlineCallbacks;
})();

console.log('1');
require('module1')
    .then(function(modules) {
        var module1;
        [module1] = modules;
        console.log("Module1 loaded", module1.name);
        require('module1')
            .then(function(modules) {
                var module1;
                [module1] = modules;
                console.log("Module1 inner loaded", module1.name);
            });
    });

console.log('2');
(inlineCallbacks(function*() {
    var module1;

    console.log('Inline started');
    [module1] = yield require('module1');
    console.log('Inline module1 loaded', module1.name);
}))();

console.log('3');
