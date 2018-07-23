//
//  Filters.swift
//  App
//
//  Created by Alessandro Pettenuzzo on 18/07/18.
//

//
//  Actions.swift
//  App
//
//  Created by Alessandro Pettenuzzo on 18/07/18.
//

class Filters {
    
    static let shared = Filters();
    private init() {
        self.filters = [:];
    }
    
    private var filters: [String: [Filter]];
    
    func add(_ filter: Filter, for hook: String) {
        guard let _ = self.filters[hook] else {
            self.filters[hook] = [filter];
            return;
        }
        self.filters[hook]!.append(filter);
    }
    
    func remove(_ name: String, from hook: String) {
        self.filters[hook] = self.filters[hook]?.filter({ (filter) -> Bool in
            return filter.name == name;
        });
    }
    
    
    func apply(_ hook: String, _ initial: Any?) -> Any? {
        var res = initial;
        self.filters[hook]?.sorted(by: { (a, b) -> Bool in
            return a.priority > b.priority;
        }).forEach({ filter in
            res = filter.callback(res);
        });
        return res;
    }
    
}

class Filter {
    var name: String;
    var callback: (Any?)->Any?;
    var priority: Int = 0;
    
    init(name: String, callback: @escaping (Any?)->Any?, priority: Int) {
        self.name = name;
        self.callback = callback;
        self.priority = priority;
    }
    
    convenience init(name: String, callback: @escaping (Any?)->Any?) {
        self.init(name: name, callback: callback, priority: 0);
    }
}

