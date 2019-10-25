package;

typedef Route = {
    var endpoint: Array<String>;
    var ?getMapping: Any;
    var ?postMapping: Any;
    var ?putMapping: Any;
    var ?deleteMapping: Any;
};
