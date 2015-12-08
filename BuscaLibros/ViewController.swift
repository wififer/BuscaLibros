//
//  ViewController.swift
//  BuscaLibros
//
//  Created by wififer on 06/12/15.
//  Copyright © 2015 wififer. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var resultadosTV: UITextView!
    
    // https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:978-84-376-0494-7
    
    let urlBase = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let isbn = searchBar.text
        let url:NSURL = NSURL(string: urlBase+isbn!)!
        let session = NSURLSession.sharedSession()
    if Reachability.isConnectedToNetwork() {
        let task = session.downloadTaskWithURL(url) {
            (
            let location, let response, let error) in
            
            guard let _:NSURL = location, let _:NSURLResponse = response  where error == nil else {
                print("error")
            return
                
            }
            
            if   let data = NSData(contentsOfURL: location!) {
                dispatch_async(dispatch_get_main_queue(), {
                    let texto = NSString(data: data, encoding: NSUTF8StringEncoding)
                    self.resultadosTV.text = texto as! String
                    self.searchBar.endEditing(true)
                })
            }
        }
        task.resume()
    }else {
        print("Internet connection not available")
        let alertController = UIAlertController(title: "Atención!", message:
            "No hay conexión a internet", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
        
    
}
    
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
         self.searchBar.endEditing(true)
    }


}

