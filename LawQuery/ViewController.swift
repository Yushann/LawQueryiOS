//
//  ViewController.swift
//  LawQuery
//
//  Created by Yushan Chen on 2018/9/25.
//  Copyright © 2018 Yushan Chen. All rights reserved.
//

import UIKit
import WebKit
import SwiftSoup

class ViewController: UIViewController {
    @IBOutlet weak var webview: WKWebView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var numberTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.webview.contentMode = .scaleAspectFit
        self.searchButtonTapped(self.searchButton)
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        let originalString = String(format: "id=1&v_court=TPS+最高法院&v_sys=M&jud_year=%@&jud_case=台上&jud_no=%@&jud_no_end=&jud_title=&keyword=&sdate=&edate=&page=&searchkw=&jmain=&JSTOCK=&JDG_COMMIS=&JDG_PRESID=&cw=0", self.yearTextField.text!, self.numberTextField.text!)
        let escapedString = originalString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let url = URL(string: "http://jirs.judicial.gov.tw/FJUD/FJUDQRY03_1.aspx?" + escapedString)!
        let session = URLSession(configuration: .default)
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("http://jirs.judicial.gov.tw/FJUD/FJUDQRY02_1.aspx?" + escapedString, forHTTPHeaderField: "Referer")
        
        session.dataTask(with: request as URLRequest) { data, response, error in
            guard let data = data else {
                return
            }
            
            do {
                var html = String(data: data, encoding: String.Encoding.utf8)!
                let doc: Document = try SwiftSoup.parse(html)
                return try doc.text()
            } catch Exception.Error(let type, let message) {
                print(message)
            } catch {
                print("error")
            }
           
//                var html = String(data: data!, encoding: String.Encoding.utf8)!
//                html = html.replacingOccurrences(of: "<HEAD>", with: "<HEAD><meta name=\"viewport\" content=\"width=device-width; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;\" />", options: .literal, range: nil)
//                //                html = html.replacingOccurrences(of: "\r\n", with: "", options: .literal, range: nil)
//                html = html.replacingOccurrences(of: "\t", with: "", options: .literal, range: nil)
//                DispatchQueue.main.async {
//                    self.webview.loadHTMLString(html, baseURL: nil)
//                }
            
            
            
            }.resume()
    }
}

