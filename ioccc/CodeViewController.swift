//
//  CodeViewController.swift
//  ioccc
//
//  Created by iOS Dev Log on 2017/7/22.
//  Copyright © 2017年 iOSDevLog. All rights reserved.
//

import UIKit

class CodeViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    var textView : UITextView!
    var barButtonItem: UIBarButtonItem!

    var filePath: String! {
        didSet {
            configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        textView = UITextView(frame: CGRect.zero, textContainer: HighlightModel.sharedInstance.textContainer)
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        
        textView.isEditable = false
        textView.autocorrectionType = UITextAutocorrectionType.no
        textView.autocapitalizationType = UITextAutocapitalizationType.none
        textView.textColor = UIColor(white: 0.8, alpha: 1.0)
        let topConstraint = NSLayoutConstraint(item: textView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: topLayoutGuide, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: textView, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.right, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: textView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: bottomLayoutGuide, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0)
        let leftConstraint = NSLayoutConstraint(item: textView, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 0)
        
        view.addConstraints([topConstraint, rightConstraint, bottomConstraint, leftConstraint])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureView()
    }
    
    func updateColors() {
        let navBar = self.navigationController!.navigationBar
        navBar.barTintColor = HighlightModel.sharedInstance.highlightr.theme.themeBackgroundColor
        navBar.tintColor = HighlightModel.sharedInstance.invertColor((navBar.barTintColor!))
        
        textView.textColor = navBar.tintColor.withAlphaComponent(0.5)
        textView.backgroundColor = HighlightModel.sharedInstance.highlightr.theme.themeBackgroundColor
    }
    
    func configureView() {
        if let detail = filePath {
            if let textView = textView {
                updateColors()
                
                let content = try! String(contentsOfFile: detail)
                
                textView.text = content
                var language = "cpp"
                HighlightModel.sharedInstance.textStorage.language = language
                
                let fileName = (detail as NSString).lastPathComponent
                let components = fileName.components(separatedBy: ".")
                if components.count > 1 {
                    language = components[components.count-1].lowercased()
                } else if components.count == 1 {
                    language = components[0].lowercased()
                }
                
                if language == "html" {
                    barButtonItem = UIBarButtonItem(title: "Web", style: .done, target: self, action: #selector(self.openUrl))
                    self.navigationItem.rightBarButtonItem = barButtonItem
                } else if language == "sh" {
                    language = "bash"
                } else if language == "mk" {
                    language = "makefile"
                }
                
                let languages = HighlightModel.sharedInstance.highlightr.supportedLanguages().sorted()
                if languages.contains(language) {
                    HighlightModel.sharedInstance.textStorage.language = language
                }
                
                updateColors()
            }
        }
    }
    
    func openUrl() {
        textView.isHidden = !textView.isHidden
        webView.isHidden = !textView.isHidden
        if let webView = webView {
            let url = URL(string: filePath)
            let request = URLRequest(url: url!)
            webView.loadRequest(request)
        }
    }
}
