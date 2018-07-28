//
//  SMSSender.swift
//  App
//
//  Created by Alessandro Pettenuzzo on 28/07/18.
//

import Vapor


class SMSSender {
    
    let dest: String;
    let message: String;
    
    static let api_key = "25bed996";
    static let api_secret = "yD9PyFRKEGdW2hqh";
    static let from = "RENDEZVOUS";
    
    init(to dest: String, with message: String) {
        self.dest = dest;
        self.message = message;
    }
    
    func send(on req: Request) throws -> Future<HTTPStatus> {
        
        return HTTPClient.connect(scheme: HTTPScheme.https, hostname: "rest.nexmo.com", on: req).flatMap({ client throws -> Future<HTTPStatus> in
            
            var message = "api_key="+SMSSender.api_key+"&api_secret="+SMSSender.api_secret+"&to=39"+self.dest+"&from="+SMSSender.from+"&text="+self.message;
            
            message = message.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!;
            
            let request = HTTPRequest(method: .POST, url: "/sms/json", headers: HTTPHeaders.init([("Content-type", "application/x-www-form-urlencoded")]), body: HTTPBody(string: message))
            
            return client.send(request).flatMap { res throws -> Future<HTTPStatus> in
                
                return req.eventLoop.newSucceededFuture(result: res.status);
                
            }
            
        })
        
    }
    
}
