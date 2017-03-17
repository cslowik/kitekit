//
//  ViewController.swift
//  Device-iOSKiteKitExample
//

import UIKit

import AVFoundation
import JavaScriptCore
import MobileCoreServices
import KiteKit
import Alamofire
import Zip
import SnapKit
import PMAlertController

class PlayerVC: UIViewController {
    
    var kiteViewController: KitePresentationViewController?
    var url: URL = URL(string: "https://www.dropbox.com/sh/09nzxurf7qc6o6z/AADxhh4uT-utdygjjNsHLOZSa?dl=0")!
    var name = ""
    var isNew = false
    var filename = "temp"
    var kiteDocument: KiteDocument?
    var unzipDirectory: URL?
    let runner = KiteRunner.runner
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blueBG
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showMenu))
        tap.numberOfTouchesRequired = 2
        tap.numberOfTapsRequired = 2
        
        view.addGestureRecognizer(tap)
        
        // test for dropbox
        url.checkLink()
        
        Alamofire.download(url, to: destination).response { response in
            if response.error == nil {
                do {
                    let filePath = response.destinationURL!
                    self.unzipDirectory = try Zip.quickUnzipFile(filePath) // Unzip
                    
                    self.kiteDocument = KiteDocument(fileURL: self.unzipDirectory!)
                    
                    // Create a KitePresentationViewController to present the view
                    guard let kitePresentationViewController = KitePresentationViewController(kiteDocument: self.kiteDocument!) else {
                        self.unableToLoad()
                        return
                    }
                    kitePresentationViewController.view.alpha = 0
                    bookmarkCheck: if self.isNew {
                        guard self.runner.bookmarks != nil  else {
                            self.runner.bookmarks = [["name":self.name, "url":self.url]]
                            break bookmarkCheck
                        }
                        self.runner.bookmarks!.append(["name":self.name, "url":self.url])
                    }
                    // Hold on to a strong reference to the view controller
                    self.kiteViewController = kitePresentationViewController
                    
                    // Add the KitePresentationView to the view hierarchy
                    self.view.addSubview(kitePresentationViewController.view)
                    UIView.animate(withDuration: 0.5, animations: { 
                        kitePresentationViewController.view.alpha = 1
                    })
                    
                    // Start the document playback
                    self.kiteViewController?.startPresenting()
                }
                catch {
                    self.unableToLoad()
                }
            } else {
                self.unableToLoad()
            }
        }
    }
    
    func showMenu() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let exitAction = UIAlertAction(title: "Exit Prototype", style: .destructive) { _ in self.exitPrototype() }
        let restartAction = UIAlertAction(title: "Restart Prototype", style: .default) { _ in self.startOver() }
        alertController.addAction(cancelAction)
        alertController.addAction(restartAction)
        alertController.addAction(exitAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func exitPrototype() {
        dismiss(animated: true, completion: nil)
    }
    
    func startOver() {
        kiteViewController?.startPresenting()
    }
    
    func unableToLoad() {
        let alertVC = PMAlertController(title: "Error", description: "Unable to load that kite. Are you sure the link is correct?", image: nil, style: .alert)
        alertVC.addAction(PMAlertAction(title: "Darn!", style: .default, action: {() in
            self.dismiss(animated: true, completion: {
                self.exitPrototype()
            })
        }))
        present(alertVC, animated: true, completion: nil)
    }
    
    func showFirstTimeAlert() {
        let alertVC = PMAlertController(title: "Instructions", description: "To bring up the playback menu, double two-finger tap.", image: nil, style: .alert)
        alertVC.addAction(PMAlertAction(title: "Got it!", style: .default))
        present(alertVC, animated: true, completion: nil)
    }
}
