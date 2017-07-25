//
//  MainViewController.swift
//  ioccc
//
//  Created by iOS Dev Log on 2017/7/22.
//  Copyright © 2017年 iOSDevLog. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import SafariServices

class MainViewController: UIViewController {
    @IBOutlet weak var returnBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let rootPath: String = "/SourceCode"
    var currentPath: String = ""
    var files: [String]? = nil
    var dirs: [String]? = nil
    let inset: CGFloat = 10.0
    
    var cellWidth: CGFloat = 0
    var cellHeight: CGFloat = 100
    let itemCountPerRow = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        NotificationCenter.default.addObserver(self, selector: #selector(self.orientation(noti:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        setupData(dir: rootPath)
    }
    
    @IBAction func info(_ sender: UIButton) {
        let url = URL(string: "http://ioccc.org")
        if #available(iOS 9.0, *) {
            let safariViewController = SFSafariViewController(url: url!)
            self.show(safariViewController, sender: nil)
        } else {
            if UIApplication.shared.canOpenURL(url!) {
                UIApplication.shared.openURL(url!)
            }
        }
    }
    
    func orientation(noti: NSNotification) {
        reloadCellWidth()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        reloadCellWidth()
    }
    
    func reloadCellWidth() {
        cellWidth = (collectionView.bounds.size.width - CGFloat(itemCountPerRow+1)*inset) / CGFloat(itemCountPerRow)
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
    }
    
    @IBAction func returnLastDir(_ sender: UIBarButtonItem) {
        setupData(dir: nil)
    }
    
    @IBAction func pickTheme(_ sender: UIBarButtonItem) {
        let themes = HighlightModel.sharedInstance.highlightr.availableThemes()
        let indexOrNil = themes.index(of: HighlightModel.sharedInstance.theme)
        let index = (indexOrNil == nil) ? 0 : indexOrNil!
        
        ActionSheetStringPicker.show(withTitle: "Pick a Theme",
                                     rows: themes,
                                     initialSelection: index,
                                     doneBlock:
            {
                picker, index, value in
                let theme = value! as! String
                HighlightModel.sharedInstance.textStorage.highlightr.setTheme(to: theme)
                HighlightModel.sharedInstance.theme = theme
                self.updateColors()
        },
                                     cancel: nil,
                                     origin: sender)
        
    }
    
    func updateColors() {
        let navBar = self.navigationController!.navigationBar
        navBar.barTintColor = HighlightModel.sharedInstance.highlightr.theme.themeBackgroundColor
        navBar.tintColor = HighlightModel.sharedInstance.invertColor((navBar.barTintColor!))
        self.collectionView.backgroundColor = navBar.tintColor.withAlphaComponent(0.5)
        self.collectionView.reloadData()
    }
    
    func setupData(dir: String?) {
        if dir == nil {
            guard currentPath != rootPath else {
                return
            }
            currentPath = (currentPath as NSString).deletingLastPathComponent
        } else {
            if currentPath == "" {
                currentPath = dir!
            } else {
                currentPath = currentPath + "/" + dir!
            }
        }
        
        returnBarButtonItem.isEnabled = (currentPath != rootPath)
        
        let resourcePath: String = (Bundle.main.resourcePath! as NSString).appendingPathComponent(currentPath)
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
            
            files = [String]()
            dirs = [String]()
            for content in contents {
                let filePath = (resourcePath as NSString).appendingPathComponent(content)
                var isDir : ObjCBool = false
                let isExist = FileManager.default.fileExists(atPath: filePath, isDirectory: &isDir)
                if isExist {
                    if isDir.boolValue {
                        self.dirs?.append(content)
                    } else {
                        self.files?.append(content)
                    }
                }
            }
            
            self.collectionView.reloadData()
        } catch let e {
            print(e)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CodeViewControllerSegue" {
            let file = sender as! String
            let vc = segue.destination as! CodeViewController
            vc.title = file
            let resourcePath = Bundle.main.resourcePath?.appending("\(currentPath)/").appending(file)
            vc.filePath = resourcePath
        }
    }
}

extension MainViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return (files?.count) ?? 0
        } else if section == 1 {
            return (dirs?.count) ?? 0
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainCollectionViewCell", for: indexPath) as! MainCollectionViewCell
        var text: String!
        let section = indexPath.section
        if section == 0 {
            text = files?[indexPath.item]
            cell.label.backgroundColor = .blue
        } else if section == 1 {
            text = dirs?[indexPath.item]
            cell.label.backgroundColor = .yellow
        }
        cell.label.text = text
        cell.label.layer.cornerRadius = 10
        cell.label.layer.masksToBounds = true
        
        return cell
    }
}

extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let section = indexPath.section
        if section == 0 {
            self.performSegue(withIdentifier: "CodeViewControllerSegue", sender:
                files?[indexPath.item])
        } else {
            let dir = dirs?[indexPath.item]
            self.setupData(dir: dir)
            self.title = dir
        }
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeight)
    }
}
