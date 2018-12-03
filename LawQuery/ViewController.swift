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
import MBProgressHUD

class ViewController: UIViewController {
    @IBOutlet weak var webview: WKWebView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var numberTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.webview.contentMode = .scaleAspectFit
        self.yearTextField.becomeFirstResponder()
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let originalString = String(format: "id=1&v_court=TPS+最高法院&v_sys=M&jud_year=%@&jud_case=台上&jud_no=%@&jud_no_end=&jud_title=&keyword=&sdate=&edate=&page=&searchkw=&jmain=&JSTOCK=&JDG_COMMIS=&JDG_PRESID=&cw=0", self.yearTextField.text!, self.numberTextField.text!)
        let escapedString = originalString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let url = URL(string: "http://jirs.judicial.gov.tw/FJUD/FJUDQRY03_1.aspx?" + escapedString)!
        let session = URLSession(configuration: .default)
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("http://jirs.judicial.gov.tw/FJUD/FJUDQRY02_1.aspx?" + escapedString, forHTTPHeaderField: "Referer")
        
        session.dataTask(with: request as URLRequest) { data, response, error in
            
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
                self.numberTextField.resignFirstResponder()
            }
            
            guard let data = data else {
                return
            }
            
            do {
                let html = String(data: data, encoding: String.Encoding.utf8)
                let doc: Document = try SwiftSoup.parse(html ?? "")
                let masthead: Element? = try doc.select("td#jfull").first()
                var content = try masthead?.text() ?? ""
                let mainRange = content.range(of: "理  由")!
                content = content.replacingOccurrences(of: "\r\n    ", with: "", options: .literal, range: Range(NSRange(location: mainRange.upperBound.encodedOffset, length: content.endIndex.encodedOffset - mainRange.upperBound.encodedOffset), in: content))
                content = content.replacingOccurrences(of: "\r\n", with: "<br>")
                
                DispatchQueue.main.async {
                    self.webview.loadHTMLString("<html><head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no\"></head><body><span>" + content + "</span></body>", baseURL: nil)
                }
            } catch Exception.Error( _, let message) {
                print(message)
            } catch {
                print("error")
            }
        }.resume()
    }
}

